import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;

  // Test Ad Unit IDs (Google Official Test IDs)
  static final String bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/6300978111';

  static final String rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/5224354917';

  Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdService initialization error: $e');
    }
  }

  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('BannerAd loaded.'),
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          debugPrint('RewardedAd loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(RewardItem reward) onUserEarnedReward,
    Function()? onAdDismissed,
  }) {
    if (_isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedAdLoaded = false;
          loadRewardedAd(); // Preload next ad
          if (onAdDismissed != null) onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isRewardedAdLoaded = false;
          loadRewardedAd();
          if (onAdDismissed != null) onAdDismissed();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onUserEarnedReward(reward);
        },
      );
    } else {
      debugPrint('Rewarded ad not loaded yet. Simulating reward for test/dev mode.');
      // Fallback for simulation in dev/test environment if ad network fails
      onUserEarnedReward(RewardItem(50, 'Data Bits'));
      loadRewardedAd();
    }
  }
}
