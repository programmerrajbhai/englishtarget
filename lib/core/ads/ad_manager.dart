import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // Singleton instance
  static final AdManager instance = AdManager._init();
  AdManager._init();

  // --- Cooldown Tracking ---
  DateTime? _lastAppOpenAdTime;
  DateTime? _lastInterstitialAdTime;
  bool _isShowingAd = false; // কোনো অ্যাড চলাকালীন অন্য অ্যাড ব্লক করার জন্য

  // --- Ad Instances ---
  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  // --- Ad Unit IDs (এখানে টেস্টিং আইডি দেওয়া আছে, প্রোডাকশনে আসল আইডি বসাবেন) ---
  String get appOpenAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/9257395921';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/5532087541';
    return '';
  }

  String get interstitialAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910';
    return '';
  }

  String get rewardedAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/5224354917';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/1712485313';
    return '';
  }

  // --- Initialization ---
  Future<void> initialize() async {
    await MobileAds.instance.initialize();

    // স্টার্টআপেই সব অ্যাড প্রি-লোড করে রাখা হচ্ছে (High Fill Rate এর জন্য)
    loadAppOpenAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  // ==========================================
  // APP OPEN AD LOGIC
// ==========================================
  // APP OPEN AD LOGIC
  // ==========================================
  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
      // orientation: AppOpenAd.orientationPortrait, <-- এই লাইনটি রিমুভ করা হয়েছে
    );
  }



  void showAppOpenAdIfAvailable() {
    if (_isShowingAd) return;
    if (_appOpenAd == null) {
      loadAppOpenAd();
      return;
    }

    // ৩ মিনিটের কুলডাউন লজিক
    if (_lastAppOpenAdTime != null) {
      final difference = DateTime.now().difference(_lastAppOpenAdTime!);
      if (difference.inMinutes < 3) {
        debugPrint('AppOpenAd in cooldown. Skipping.');
        return;
      }
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd(); // ফেইল হলে আবার লোড করবে
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _lastAppOpenAdTime = DateTime.now(); // কুলডাউন টাইমার রিসেট
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd(); // পরবর্তী বারের জন্য প্রি-লোড
      },
    );

    _appOpenAd!.show();
  }

  // ==========================================
  // INTERSTITIAL AD LOGIC
  // ==========================================
  void loadInterstitialAd() {
    if (_interstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd({required VoidCallback onAdDismissed}) {
    if (_isShowingAd) {
      onAdDismissed();
      return;
    }

    // ৬০ সেকেন্ডের কুলডাউন লজিক
    if (_lastInterstitialAdTime != null) {
      final difference = DateTime.now().difference(_lastInterstitialAdTime!);
      if (difference.inSeconds < 60) {
        debugPrint('InterstitialAd in cooldown. Skipping.');
        onAdDismissed(); // অ্যাড না দেখালেও ইউজারকে পরের স্ক্রিনে পাঠিয়ে দেবে
        return;
      }
    }

    if (_interstitialAd == null) {
      debugPrint('InterstitialAd not ready yet.');
      loadInterstitialAd();
      onAdDismissed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdDismissed();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _lastInterstitialAdTime = DateTime.now(); // কুলডাউন টাইমার রিসেট
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // পরবর্তী লেসনের জন্য সাথে সাথে প্রি-লোড
        onAdDismissed(); // অ্যাড শেষ হলে নেক্সট একশন কল হবে
      },
    );

    _interstitialAd!.show();
  }

  // ==========================================
  // REWARDED AD LOGIC
  // ==========================================
  void loadRewardedAd() {
    if (_rewardedAd != null || _isRewardedLoading) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(int amount) onUserEarnedReward,
    required VoidCallback onAdDismissed,
  }) {
    if (_isShowingAd) return;

    if (_rewardedAd == null) {
      debugPrint('RewardedAd not ready yet.');
      loadRewardedAd();
      onAdDismissed();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdDismissed();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // পরবর্তী বারের জন্য প্রি-লোড
        onAdDismissed();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onUserEarnedReward(reward.amount.toInt());
      },
    );
  }
}