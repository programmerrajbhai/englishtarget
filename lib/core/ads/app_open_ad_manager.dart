import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_helper.dart';

class AppOpenAdManager with WidgetsBindingObserver {
  AppOpenAdManager._();
  static final AppOpenAdManager instance = AppOpenAdManager._();

  // ৩টি সেফটি রুল + Google-এর ৪ ঘণ্টার এক্সপায়ারি রুল
  static const Duration _minBackgroundDuration = Duration(seconds: 40);
  static const Duration _cooldownDuration = Duration(minutes: 15);
  static const Duration _maxCacheDuration = Duration(hours: 4);

  AppOpenAd? _appOpenAd;
  DateTime? _adLoadTime;
  DateTime? _pausedTime;
  DateTime? _lastShownTime;

  bool _isLoading = false;
  bool _isShowingAd = false;
  bool _isInitialized = false;

  /// Interstitial / Rewarded অ্যাড চলার সময় বা Share/Permission ডায়ালগের আগে
  /// এটি true করে দিলে অ্যাপে ফেরার সময় App Open Ad আসবে না।
  bool suppressNextResume = false;

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
    loadAd();
  }

  void dispose() {
    if (!_isInitialized) return;
    _isInitialized = false;
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }

  bool get _isAdAvailable {
    if (_appOpenAd == null || _adLoadTime == null) return false;
    final bool isExpired =
        DateTime.now().difference(_adLoadTime!) >= _maxCacheDuration;
    if (isExpired) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      return false;
    }
    return true;
  }

  void loadAd() {
    if (_isLoading || _isAdAvailable) return;

    final String adUnitId;
    try {
      adUnitId = AdHelper.appOpenAdUnitId;
    } catch (_) {
      return;
    }

    _isLoading = true;

    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _appOpenAd = ad;
          _adLoadTime = DateTime.now();
          _isLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoading = false;
          _appOpenAd = null;
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  void _handleAppResumed() {
    // ১. অন্য কোনো অ্যাড, শেয়ার শিট বা পারমিশন ডায়ালগ থেকে ফিরলে ব্লক করো
    if (suppressNextResume) {
      suppressNextResume = false;
      _pausedTime = null;
      return;
    }

    if (_isShowingAd) return;

    // ২. কমপক্ষে ৪০ সেকেন্ড ব্যাকগ্রাউন্ডে ছিল কি না চেক করো
    if (_pausedTime == null) return;
    final Duration awayDuration = DateTime.now().difference(_pausedTime!);
    _pausedTime = null;

    if (awayDuration < _minBackgroundDuration) return;

    // ৩. ১৫ মিনিটের কোল্ডাউন চেক করো
    if (_lastShownTime != null &&
        DateTime.now().difference(_lastShownTime!) < _cooldownDuration) {
      return;
    }

    _showAdIfAvailable();
  }

  void _showAdIfAvailable() {
    if (!_isAdAvailable) {
      loadAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = true;
        _lastShownTime = DateTime.now();
      },
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // পরের বারের জন্য প্রিলোড
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );

    _appOpenAd!.show();
  }
}