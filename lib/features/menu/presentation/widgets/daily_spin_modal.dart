import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';

class DailySpinModal extends StatefulWidget {
  final VoidCallback onRewardClaimed;

  const DailySpinModal({
    super.key,
    required this.onRewardClaimed,
  });

  @override
  State<DailySpinModal> createState() => _DailySpinModalState();
}

class _DailySpinModalState extends State<DailySpinModal>
    with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();
  final StorageService _storage = StorageService();

  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  static const List<int> _prizes = [50, 100, 25, 200, 75, 150, 30, 300];
  static const List<Color> _wedgeColors = [
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF00BCD4),
    Color(0xFFE040FB),
    Color(0xFFFFD700),
  ];

  int _selectedPrizeIndex = 0;
  bool _isSpinning = false;
  bool _hasClaimed = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _startSpin() {
    if (_isSpinning || _hasClaimed) return;

    final rand = Random();
    _selectedPrizeIndex = rand.nextInt(_prizes.length);

    // Calculate rotation angle (e.g. 5 full revolutions + wedge offset)
    final wedgeAngle = (2 * pi) / _prizes.length;
    final targetAngle = (5 * 2 * pi) + (_selectedPrizeIndex * wedgeAngle);

    _spinAnimation = Tween<double>(begin: 0.0, end: targetAngle).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    setState(() {
      _isSpinning = true;
    });

    _audio.playSfx(GameSfx.spin);
    _spinController.forward(from: 0.0).then((_) async {
      final reward = _prizes[_selectedPrizeIndex];
      await _storage.addCoins(reward);
      await _storage.recordDailySpinClaimed();

      _audio.playSfx(GameSfx.win);
      _confettiController.play();

      setState(() {
        _isSpinning = false;
        _hasClaimed = true;
      });

      widget.onRewardClaimed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.gameHeaderBg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.menuWarmAmber, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.menuWarmAmber.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LUCKY WHEEL',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: AppColors.coinGold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _hasClaimed
                      ? 'You won +${_prizes[_selectedPrizeIndex]} Coins!'
                      : 'Spin for free daily coin bonuses!',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: _hasClaimed ? Colors.greenAccent : AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Wheel & Needle
                SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _spinAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: -_spinAnimation.value,
                            child: CustomPaint(
                              size: const Size(250, 250),
                              painter: WheelPainter(
                                prizes: _prizes,
                                colors: _wedgeColors,
                              ),
                            ),
                          );
                        },
                      ),
                      // Center Pin
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.coinGold, width: 4),
                          boxShadow: const [
                            BoxShadow(color: Colors.black45, blurRadius: 6),
                          ],
                        ),
                        child: const Icon(Icons.star, color: AppColors.coinGold, size: 22),
                      ),
                      // Top Pointer Indicator
                      Positioned(
                        top: 0,
                        child: Icon(
                          Icons.arrow_drop_down,
                          size: 40,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Spin Button / Claimed
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isSpinning || _hasClaimed) ? null : _startSpin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coinGold,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      _isSpinning
                          ? 'SPINNING...'
                          : (_hasClaimed ? 'CLAIMED!' : 'SPIN NOW'),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<int> prizes;
  final List<Color> colors;

  WheelPainter({required this.prizes, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final wedgeAngle = (2 * pi) / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final startAngle = i * wedgeAngle;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        wedgeAngle,
        true,
        paint,
      );

      // Draw wedge border
      final strokePaint = Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        wedgeAngle,
        true,
        strokePaint,
      );

      // Draw prize text inside wedge
      canvas.save();
      final textAngle = startAngle + wedgeAngle / 2;
      canvas.translate(
        center.dx + (radius * 0.65) * cos(textAngle),
        center.dy + (radius * 0.65) * sin(textAngle),
      );
      canvas.rotate(textAngle + pi / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${prizes[i]}',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Colors.white,
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
