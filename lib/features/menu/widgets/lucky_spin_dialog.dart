import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/game_storage.dart';
import '../../../core/theme/app_colors.dart';

/// Production Lucky Spin Wheel Dialog
/// Features:
/// - Exact mathematical sector alignment: needle stops dead-center on prize sectors
/// - Strict 24-hour cooldown tracked in SharedPreferences
/// - Rewarded Video Ad gate for extra spins while on cooldown
/// - Claim 2x with Ad CTA button alongside top-right close icon
class LuckySpinDialog extends StatefulWidget {
  final VoidCallback onRewardClaimed;

  const LuckySpinDialog({
    super.key,
    required this.onRewardClaimed,
  });

  @override
  State<LuckySpinDialog> createState() => _LuckySpinDialogState();
}

class _LuckySpinDialogState extends State<LuckySpinDialog>
    with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  final GameStorage _storage = GameStorage();
  final AdService _adService = AdService();

  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  late ConfettiController _confettiController;
  Timer? _countdownTimer;

  static const List<int> _prizes = [50, 100, 25, 200, 75, 150, 30, 500];
  static const List<Color> _wedgeColors = [
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF00BCD4), // Cyan
    Color(0xFF673AB7), // Deep Purple
    Color(0xFFFFD700), // Gold (Grand Prize 500)
  ];

  int _selectedPrizeIndex = 0;
  bool _isSpinning = false;
  bool _hasLanded = false;
  bool _hasClaimed = false;
  double _currentWheelAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    );

    // Periodically tick countdown
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _spinController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  String _formatRemainingTime(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _handleSpinPress() async {
    if (_isSpinning || _hasClaimed) return;

    final canFree = _storage.canFreeSpin;
    if (!canFree) {
      // Must watch rewarded ad to get an extra spin while on cooldown
      final watched = await _adService.showRewardedAd(
        context: context,
        placement: 'Extra Lucky Spin',
        onRewardGranted: () {},
      );
      if (!watched) return;
    }

    _executeSpin();
  }

  void _executeSpin() {
    final rand = Random();
    _selectedPrizeIndex = rand.nextInt(_prizes.length);

    // EXACT MATHEMATICAL SECTOR OFFSET:
    // With 8 wedges, wedgeAngle is 2*pi / 8.
    // The top pointer rests at angle -pi/2.
    // In our painter, wedge i's center is drawn at (-pi/2 + i * wedgeAngle).
    // Rotating clockwise by angle alpha brings wedge i to the top if:
    // alpha = (Rotations * 2*pi) - (i * wedgeAngle)
    const int fullRotations = 6;
    final wedgeAngle = (2 * pi) / _prizes.length;
    final targetAngle = (fullRotations * 2 * pi) - (_selectedPrizeIndex * wedgeAngle);

    final startAngle = _currentWheelAngle % (2 * pi);
    final endAngle = startAngle + targetAngle;

    _spinAnimation = Tween<double>(begin: startAngle, end: endAngle).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    setState(() {
      _isSpinning = true;
      _hasLanded = false;
    });

    _audio.playSfx(GameSfx.spin);
    _spinController.forward(from: 0.0).then((_) async {
      _currentWheelAngle = endAngle;

      // If it was a free spin, record timestamp
      if (_storage.canFreeSpin) {
        await _storage.recordFreeSpinUsed();
      }

      _audio.playSfx(GameSfx.win);
      _confettiController.play();

      setState(() {
        _isSpinning = false;
        _hasLanded = true;
      });
    });
  }

  Future<void> _claimStandardReward() async {
    if (_hasClaimed) return;
    final prize = _prizes[_selectedPrizeIndex];
    await _storage.addCoins(prize);
    _audio.playSfx(GameSfx.coin);

    setState(() {
      _hasClaimed = true;
    });

    widget.onRewardClaimed();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _claimDoubleRewardWithAd() async {
    if (_hasClaimed) return;
    final prize = _prizes[_selectedPrizeIndex];

    final watched = await _adService.showRewardedAd(
      context: context,
      placement: 'Lucky Spin 2x Multiplier',
      onRewardGranted: () {},
    );

    if (!watched) return;

    final doublePrize = prize * 2;
    await _storage.addCoins(doublePrize);
    _audio.playSfx(GameSfx.win);
    _confettiController.play();

    setState(() {
      _hasClaimed = true;
    });

    widget.onRewardClaimed();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Claimed 2X Bonus: +$doublePrize Coins!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.tileCorrect,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canFree = _storage.canFreeSpin;
    final remainingTime = _storage.timeUntilNextFreeSpin;
    final wonPrize = _prizes[_selectedPrizeIndex];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.gameHeaderBg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.menuWarmAmber, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.menuWarmAmber.withValues(alpha: 0.35),
                  blurRadius: 25,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Title & Top-Right Close Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      'LUCKY WHEEL',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppColors.coinGold,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isSpinning ? null : () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Subtitle / Status
                if (_hasLanded) ...[
                  Text(
                    'YOU WON +$wonPrize COINS!',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.greenAccent,
                      letterSpacing: 1.0,
                    ),
                  ),
                ] else ...[
                  Text(
                    canFree
                        ? '1 Free Daily Spin Available!'
                        : 'Free spin in ${_formatRemainingTime(remainingTime)}',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: canFree ? Colors.greenAccent : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 18),

                // Wheel & Precise Needle Indicator
                SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Spinning Wheel Canvas
                      AnimatedBuilder(
                        animation: _spinAnimation,
                        builder: (context, child) {
                          final angle = _isSpinning
                              ? _spinAnimation.value
                              : _currentWheelAngle;
                          return Transform.rotate(
                            angle: angle,
                            child: CustomPaint(
                              size: const Size(250, 250),
                              painter: _PreciseWheelPainter(
                                prizes: _prizes,
                                colors: _wedgeColors,
                              ),
                            ),
                          );
                        },
                      ),

                      // Center Metallic Hub
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.coinGold, width: 4),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.star_rounded, color: AppColors.coinGold, size: 26),
                      ),

                      // Top Needle Pointer (Precisely points down at top wedge)
                      Positioned(
                        top: -4,
                        child: CustomPaint(
                          size: const Size(26, 32),
                          painter: _NeedlePointerPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Action Area: Landing CTAs or Spin Button
                if (_hasLanded) ...[
                  // Claim 2x With Ad Button (Primary Lion Studios CTA)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _hasClaimed ? null : _claimDoubleRewardWithAd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.menuWarmAmber,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.ondemand_video_rounded, color: AppColors.textDark, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'CLAIM 2X WITH AD (+${wonPrize * 2})',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Standard Claim Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _hasClaimed ? null : _claimStandardReward,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.tileFilledBorder, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Claim +$wonPrize Coins',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Spin Now / Spin With Ad Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSpinning ? null : _handleSpinPress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canFree ? AppColors.coinGold : AppColors.tileCorrect,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!canFree) ...[
                            const Icon(Icons.ondemand_video_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _isSpinning
                                ? 'SPINNING...'
                                : (canFree ? 'FREE SPIN' : 'SPIN WITH AD'),
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: canFree ? AppColors.textDark : Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Confetti Burst
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.yellow,
                Colors.orange,
                Colors.pink,
                Colors.green,
                Colors.cyan,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Precise Wheel Painter
/// Draws wedges such that sector 0 is centered exactly at angle -pi/2 (top).
class _PreciseWheelPainter extends CustomPainter {
  final List<int> prizes;
  final List<Color> colors;

  _PreciseWheelPainter({required this.prizes, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final wedgeAngle = (2 * pi) / prizes.length;

    // Outer rim shadow & ring
    final rimPaint = Paint()
      ..color = const Color(0xFF281E48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 4, rimPaint);

    for (int i = 0; i < prizes.length; i++) {
      // Sector i centered at -pi/2 + (i * wedgeAngle)
      final centerAngle = -pi / 2 + (i * wedgeAngle);
      final startAngle = centerAngle - (wedgeAngle / 2);

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        startAngle,
        wedgeAngle,
        true,
        paint,
      );

      // Dividing border line
      final borderPaint = Paint()
        ..color = Colors.white38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        startAngle,
        wedgeAngle,
        true,
        borderPaint,
      );

      // Draw Prize Number dead-center in the wedge
      canvas.save();
      final textDistance = radius * 0.62;
      canvas.translate(
        center.dx + textDistance * cos(centerAngle),
        center.dy + textDistance * sin(centerAngle),
      );
      // Rotate text to face inward toward center
      canvas.rotate(centerAngle + pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${prizes[i]}',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: const [
              Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Precise Needle Pointer Painter
class _NeedlePointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black45
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path()
      ..moveTo(size.width / 2, size.height) // tip pointing down
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Accent inner pin
    final goldPaint = Paint()
      ..color = AppColors.coinGold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, 6), 4, goldPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
