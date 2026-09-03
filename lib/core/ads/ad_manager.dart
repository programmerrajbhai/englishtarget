import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class AdManager {
  // Singleton instance (যাতে পুরো অ্যাপে একটাই ম্যানেজার থাকে)
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  // Ads variables
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  // Cool-down Timer Logic for Interstitial Ads
  DateTime? _lastInterstitialTime;
  final int _interstitialCooldownSeconds = 45; // ৪৫ সেকেন্ডের আগে অ্যাড আসবে না

  bool _isAppOpenAdShowing = false;

  /// ১. AdMob Initialize করুন (main.dart এ কল করতে হবে)
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    loadInterstitialAd();
    loadRewardedAd();
    loadAppOpenAd();
  }

  /// ================= INTERSTITIAL AD LOGIC ================= ///
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd({required VoidCallback onActionCompleted}) {
    // যদি অ্যাড লোড না থাকে অথবা ৪৫ সেকেন্ডের কুল-ডাউন পার না হয়
    final now = DateTime.now();
    if (_interstitialAd == null ||
        (_lastInterstitialTime != null &&
            now.difference(_lastInterstitialTime!).inSeconds < _interstitialCooldownSeconds)) {
      onActionCompleted(); // অ্যাড ছাড়াই ইউজারকে পরের স্ক্রিনে পাঠিয়ে দিন
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _lastInterstitialTime = DateTime.now(); // অ্যাড দেখার পর টাইম সেভ করা হলো
        loadInterstitialAd(); // পরের বারের জন্য নতুন অ্যাড লোড
        onActionCompleted(); // ইউজারকে পরের স্ক্রিনে পাঠানো
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        onActionCompleted();
      },
    );

    _interstitialAd!.show();
  }

  /// ================= REWARDED AD LOGIC ================= ///
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed to load: $error');
          _rewardedAd = null;
        },
      ),
    );
  }

  void showRewardedAd({
    required VoidCallback onEarnedReward,
    required VoidCallback onClosed,
  }) {
    if (_rewardedAd == null) {
      onClosed();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onClosed();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      onEarnedReward(); // ইউজার পুরো অ্যাড দেখলে এই ফাংশন ফায়ার হবে
    });
  }

  /// ================= APP OPEN AD LOGIC ================= ///
  /// ================= APP OPEN AD LOGIC ================= ///
  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => _appOpenAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('AppOpen Ad failed to load: $error');
          _appOpenAd = null;
        },
      ),
    );
  }




  void showAppOpenAdIfAvailable() {
    if (_appOpenAd == null || _isAppOpenAdShowing) {
      loadAppOpenAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => _isAppOpenAdShowing = true,
      onAdDismissedFullScreenContent: (ad) {
        _isAppOpenAdShowing = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAppOpenAdShowing = false;
        ad.dispose();
        _appOpenAd = null;
      },
    );

    _appOpenAd!.show();
  }
}