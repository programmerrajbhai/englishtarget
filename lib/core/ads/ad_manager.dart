import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_config_service.dart';
import 'ad_helper.dart';

class AdManager with WidgetsBindingObserver {
  static const String _lastAppOpenKey = 'ads_last_app_open_shown_at';
  static const String _lastInterstitialKey = 'ads_last_interstitial_shown_at';

  // সেফ এবং হাই-ইনকাম Cooldown ও Background রুল
  static const int _interstitialCooldownSeconds = 75; // ১ মিনিট ১৫ সেকেন্ড
  static const int _appOpenCooldownMinutes = 15; // ১৫ মিনিট
  static const int _minBackgroundSecondsForAppOpen = 40;
  static const int _maxRetryAttempts = 3;

  AdManager._();
  static final AdManager instance = AdManager._();

  bool _initialized = false;
  bool _isShowingAd = false;
  bool _suppressNextAppOpen = false;
  bool _loadingAppOpen = false;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;

  int _appOpenRetryCount = 0;
  int _interstitialRetryCount = 0;
  int _rewardedRetryCount = 0;

  Timer? _appOpenRetryTimer;
  Timer? _interstitialRetryTimer;
  Timer? _rewardedRetryTimer;

  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  DateTime? _appOpenLoadedAt;
  DateTime? _lastAppOpenShownAt;
  DateTime? _lastInterstitialShownAt;
  DateTime? _pausedAt;

  bool get _canRequest =>
      _initialized && Platform.isAndroid && AdConfigService.instance.showAds;

  /// Share ডায়ালগ বা Permission পপ-আপের আগে কল করলে ফেরার সময় App Open Ad আসবে না
  void suppressNextAppOpenAd() {
    _suppressNextAppOpen = true;
  }

  Future<void> initialize() async {
    if (!Platform.isAndroid || _initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final appOpenMillis = prefs.getInt(_lastAppOpenKey);
      final interstitialMillis = prefs.getInt(_lastInterstitialKey);
      if (appOpenMillis != null) {
        _lastAppOpenShownAt =
            DateTime.fromMillisecondsSinceEpoch(appOpenMillis);
      }
      if (interstitialMillis != null) {
        _lastInterstitialShownAt =
            DateTime.fromMillisecondsSinceEpoch(interstitialMillis);
      }
    } catch (error) {
      debugPrint('Ad cooldown restore failed: $error');
    }

    await MobileAds.instance.initialize();
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    AdConfigService.instance.showAdsNotifier.addListener(_onConfigChanged);
    _onConfigChanged();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (!_isShowingAd) {
        _pausedAt = DateTime.now();
      }
    } else if (state == AppLifecycleState.resumed) {
      _handleAppResumed();
    }
  }

  void _handleAppResumed() {
    if (_suppressNextAppOpen) {
      _suppressNextAppOpen = false;
      _pausedAt = null;
      return;
    }

    if (_isShowingAd) {
      _pausedAt = null;
      return;
    }

    final pausedAt = _pausedAt;
    _pausedAt = null;

    if (pausedAt == null) return;

    final int awaySeconds = DateTime.now().difference(pausedAt).inSeconds;
    if (awaySeconds >= _minBackgroundSecondsForAppOpen) {
      showAppOpenAdIfAvailable();
    }
  }

  void _rememberShownAt(String key, DateTime time) {
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(key, time.millisecondsSinceEpoch);
      } catch (error) {
        debugPrint('Ad cooldown save failed: $error');
      }
    }());
  }

  void _onConfigChanged() {
    if (!_canRequest) {
      _appOpenRetryTimer?.cancel();
      _interstitialRetryTimer?.cancel();
      _rewardedRetryTimer?.cancel();
      _appOpenAd?.dispose();
      _interstitialAd?.dispose();
      _rewardedAd?.dispose();
      _appOpenAd = null;
      _interstitialAd = null;
      _rewardedAd = null;
      _appOpenLoadedAt = null;
      return;
    }
    loadAppOpenAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  void loadAppOpenAd() {
    if (!_canRequest || _loadingAppOpen || _appOpenAd != null) return;
    _loadingAppOpen = true;
    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingAppOpen = false;
          _appOpenRetryCount = 0;
          if (!_canRequest) {
            ad.dispose();
            return;
          }
          _appOpenAd = ad;
          _appOpenLoadedAt = DateTime.now();
          debugPrint('AppOpenAd loaded.');
        },
        onAdFailedToLoad: (error) {
          _loadingAppOpen = false;
          debugPrint('AppOpenAd failed: ${error.code} ${error.message}');
          if (_appOpenRetryCount < _maxRetryAttempts && _canRequest) {
            final delay = Duration(seconds: 15 << _appOpenRetryCount);
            _appOpenRetryCount++;
            _appOpenRetryTimer?.cancel();
            _appOpenRetryTimer = Timer(delay, loadAppOpenAd);
          }
        },
      ),
    );
  }

  void showAppOpenAdIfAvailable() {
    if (!_canRequest || _isShowingAd) return;

    final lastShown = _lastAppOpenShownAt;
    if (lastShown != null &&
        DateTime.now().difference(lastShown).inMinutes <
            _appOpenCooldownMinutes) {
      return;
    }

    final loadedAt = _appOpenLoadedAt;
    if (loadedAt != null && DateTime.now().difference(loadedAt).inHours >= 4) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _appOpenLoadedAt = null;
    }

    final ad = _appOpenAd;
    if (ad == null) {
      _appOpenRetryCount = 0;
      loadAppOpenAd();
      return;
    }
    _appOpenAd = null;
    _appOpenLoadedAt = null;
    _isShowingAd = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastAppOpenShownAt = DateTime.now();
        _rememberShownAt(_lastAppOpenKey, _lastAppOpenShownAt!);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        debugPrint('AppOpenAd show failed: $error');
        ad.dispose();
        loadAppOpenAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        loadAppOpenAd();
      },
    );
    ad.show();
  }

  void loadInterstitialAd() {
    if (!_canRequest || _loadingInterstitial || _interstitialAd != null) {
      return;
    }
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitialRetryCount = 0;
          if (!_canRequest) {
            ad.dispose();
            return;
          }
          _interstitialAd = ad;
          debugPrint('InterstitialAd loaded.');
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          debugPrint('InterstitialAd failed: ${error.code} ${error.message}');
          if (_interstitialRetryCount < _maxRetryAttempts && _canRequest) {
            final delay = Duration(seconds: 15 << _interstitialRetryCount);
            _interstitialRetryCount++;
            _interstitialRetryTimer?.cancel();
            _interstitialRetryTimer = Timer(delay, loadInterstitialAd);
          }
        },
      ),
    );
  }

  void showInterstitialAd({required VoidCallback onAdDismissed}) {
    if (!_canRequest || _isShowingAd) {
      onAdDismissed();
      return;
    }
    final lastShown = _lastInterstitialShownAt;
    if (lastShown != null &&
        DateTime.now().difference(lastShown).inSeconds <
            _interstitialCooldownSeconds) {
      onAdDismissed();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      _interstitialRetryCount = 0;
      loadInterstitialAd();
      onAdDismissed();
      return;
    }
    _interstitialAd = null;
    _isShowingAd = true;
    _suppressNextAppOpen = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastInterstitialShownAt = DateTime.now();
        _rememberShownAt(_lastInterstitialKey, _lastInterstitialShownAt!);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        _suppressNextAppOpen = false;
        debugPrint('InterstitialAd show failed: $error');
        ad.dispose();
        loadInterstitialAd();
        onAdDismissed();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _suppressNextAppOpen = false;
        ad.dispose();
        loadInterstitialAd();
        onAdDismissed();
      },
    );
    ad.show();
  }

  void loadRewardedAd() {
    if (!_canRequest || _loadingRewarded || _rewardedAd != null) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingRewarded = false;
          _rewardedRetryCount = 0;
          if (!_canRequest) {
            ad.dispose();
            return;
          }
          _rewardedAd = ad;
          debugPrint('RewardedAd loaded.');
        },
        onAdFailedToLoad: (error) {
          _loadingRewarded = false;
          debugPrint('RewardedAd failed: ${error.code} ${error.message}');
          if (_rewardedRetryCount < _maxRetryAttempts && _canRequest) {
            final delay = Duration(seconds: 15 << _rewardedRetryCount);
            _rewardedRetryCount++;
            _rewardedRetryTimer?.cancel();
            _rewardedRetryTimer = Timer(delay, loadRewardedAd);
          }
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(int amount) onUserEarnedReward,
    required VoidCallback onAdDismissed,
  }) {
    if (!_canRequest || _isShowingAd) {
      onAdDismissed();
      return;
    }
    final ad = _rewardedAd;
    if (ad == null) {
      _rewardedRetryCount = 0;
      loadRewardedAd();
      onAdDismissed();
      return;
    }
    _rewardedAd = null;
    _isShowingAd = true;
    _suppressNextAppOpen = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        _suppressNextAppOpen = false;
        debugPrint('RewardedAd show failed: $error');
        ad.dispose();
        loadRewardedAd();
        onAdDismissed();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _suppressNextAppOpen = false;
        ad.dispose();
        loadRewardedAd();
        onAdDismissed();
      },
    );
    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onUserEarnedReward(reward.amount.toInt());
      },
    );
  }
}