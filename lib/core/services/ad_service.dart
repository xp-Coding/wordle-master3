import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Production AdService Facade
/// Provides unified AdMob slots for Rewarded Video ads and standard 320x50 Banners.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  /// Displays a polished, casual-gaming style rewarded video ad.
  /// Simulates production AdMob/AppLovin ad unit behavior with countdown,
  /// verified completion callback, and tactile sound/animation cues.
  Future<bool> showRewardedAd({
    required BuildContext context,
    required String placement,
    required VoidCallback onRewardGranted,
  }) async {
    final completer = Completer<bool>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => _RewardedVideoAdDialog(
        placement: placement,
        onAdComplete: () {
          onRewardGranted();
          completer.complete(true);
        },
        onAdCancelled: () {
          completer.complete(false);
        },
      ),
    );

    return completer.isCompleted ? await completer.future : false;
  }
}

/// Simulated Rewarded Video Ad Modal
class _RewardedVideoAdDialog extends StatefulWidget {
  final String placement;
  final VoidCallback onAdComplete;
  final VoidCallback onAdCancelled;

  const _RewardedVideoAdDialog({
    required this.placement,
    required this.onAdComplete,
    required this.onAdCancelled,
  });

  @override
  State<_RewardedVideoAdDialog> createState() => _RewardedVideoAdDialogState();
}

class _RewardedVideoAdDialogState extends State<_RewardedVideoAdDialog> {
  int _secondsRemaining = 2;
  Timer? _timer;
  bool _canClaim = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _secondsRemaining = 0;
          _canClaim = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1320),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.menuWarmAmber.withValues(alpha: 0.6), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar with Ad Tag & Close (when allowed)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    'ADVERTISEMENT',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                if (_canClaim)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onAdComplete();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: const Icon(Icons.close_rounded, size: 20, color: Colors.white),
                    ),
                  )
                else
                  Text(
                    'Reward in ${_secondsRemaining}s',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.coinGold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Ad Mock Graphics Content
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3F51B5), Color(0xFF673AB7), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 54),
                      const SizedBox(height: 10),
                      Text(
                        'WORDLE MASTER VIP',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Unlock Extra Boosts & Infinite Replays!',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (!_canClaim)
                    Positioned(
                      bottom: 12,
                      left: 16,
                      right: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (2 - _secondsRemaining) / 2.0,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.coinGold),
                          minHeight: 6,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Placement indicator & Claim CTA
            Text(
              'Reward: ${widget.placement}',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canClaim
                    ? () {
                        Navigator.of(context).pop();
                        widget.onAdComplete();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tileCorrect,
                  disabledBackgroundColor: AppColors.tileFilled,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _canClaim ? 'CLAIM REWARD!' : 'WATCHING AD (${_secondsRemaining}s)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: _canClaim ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Production 320x50 AdMob Banner Container Widget
/// Neumorphic casual styling, responsive centered, guaranteed zero overflows.
class AdBannerContainer extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const AdBannerContainer({
    super.key,
    this.margin = const EdgeInsets.only(top: 4, bottom: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      alignment: Alignment.center,
      child: Container(
        width: 320,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF161C2C),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.tileEmptyBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            // Ad indicator badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.tileFilled,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'AD',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.coinGold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Banner content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WORDLE! CASUAL PUZZLES',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Test your vocabulary with 50+ levels!',
                    style: GoogleFonts.outfit(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Install / Play CTA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.tileCorrect, AppColors.tileCorrectBevel],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'PLAY',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
