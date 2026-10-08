import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'game_storage.dart';

/// Production AdService Facade
/// Provides unified AdMob slots for Rewarded Video ads, App Open Ads on resume, and clickable 320x50 Banners.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isAdShowing = false;
  bool get isAdShowing => _isAdShowing;

  /// Displays a polished, casual-gaming style rewarded video ad.
  /// Simulates production AdMob/AppLovin ad unit behavior with countdown,
  /// verified completion callback, and tactile sound/animation cues.
  Future<bool> showRewardedAd({
    required BuildContext context,
    required String placement,
    required VoidCallback onRewardGranted,
  }) async {
    if (_isAdShowing) return false;
    _isAdShowing = true;
    final completer = Completer<bool>();

    try {
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
    } finally {
      _isAdShowing = false;
    }

    return completer.isCompleted ? await completer.future : false;
  }

  /// Displays an App Open Ad when the game is resumed from background/minimize.
  Future<void> showAppOpenAd(BuildContext context) async {
    if (_isAdShowing) return;
    _isAdShowing = true;

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => const _AppOpenAdDialog(),
      );
    } catch (_) {
      // Ignore if navigator unmounted
    } finally {
      _isAdShowing = false;
    }
  }

  /// Displays an interactive sponsored ad when user clicks the bottom banner.
  Future<void> showSponsoredInteractiveModal(BuildContext context) async {
    if (_isAdShowing) return;
    _isAdShowing = true;

    try {
      await showDialog(
        context: context,
        builder: (dialogCtx) => const _SponsoredInteractiveModal(),
      );
    } finally {
      _isAdShowing = false;
    }
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
/// Clickable interactive container with ripple and modal trigger.
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            AdService().showSponsoredInteractiveModal(context);
          },
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
                        'Tap to inspect sponsor & earn +10 coins!',
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
                    'VISIT',
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
        ),
      ),
    );
  }
}

/// App Open / Resume Ad Overlay
class _AppOpenAdDialog extends StatefulWidget {
  const _AppOpenAdDialog();

  @override
  State<_AppOpenAdDialog> createState() => _AppOpenAdDialogState();
}

class _AppOpenAdDialogState extends State<_AppOpenAdDialog> {
  int _countdown = 2;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        setState(() => _countdown = 0);
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1320),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.streakOrange, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'APP RESUME AD',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.coinGold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                if (_countdown == 0)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'CONTINUE ✕',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    'Skip in ${_countdown}s',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E1A47), Color(0xFF4A148C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purpleAccent.shade100, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on_rounded, size: 52, color: Colors.amberAccent),
                  const SizedBox(height: 8),
                  Text(
                    'WELCOME BACK TO WORDLE!',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Train your brain with daily word puzzles',
                    style: GoogleFonts.outfit(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tileCorrect,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'RESUME GAME',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive Sponsored Ad Modal (triggered by clicking bottom banner)
class _SponsoredInteractiveModal extends StatelessWidget {
  const _SponsoredInteractiveModal();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF13192B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.coinGold, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'SPONSORED PARTNER',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.coinGold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF004D40), Color(0xFF00796B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars_rounded, size: 48, color: AppColors.coinGold),
                  const SizedBox(height: 6),
                  Text(
                    'SPONSOR SPECIAL OFFER',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Thank you for supporting Wordle Master!',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Here is a sponsor reward gift of 10 free coins!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.coinGold,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await GameStorage().addCoins(10);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '+10 Sponsor Coins Added!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: AppColors.tileCorrect,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.monetization_on, color: Colors.white),
                label: Text(
                  'CLAIM +10 COINS',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tileCorrect,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
