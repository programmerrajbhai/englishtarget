import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_config_service.dart';
import 'ad_helper.dart';

class AdManager {
  static const String _lastAppOpenKey = 'ads_last_app_open_shown_at';
  static const String _lastInterstitialKey = 'ads_last_interstitial_shown_at';

  AdManager._();
  static final AdManager instance = AdManager._();

  bool _initialized = false;
  bool _isShowingAd = false;
  bool _loadingAppOpen = false;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;

  AppOpenAd? _appOpenAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  DateTime? _appOpenLoadedAt;
  DateTime? _lastAppOpenShownAt;
  DateTime? _lastInterstitialShownAt;

  bool get _canRequest =>
      _initialized && Platform.isAndroid && AdConfigService.instance.showAds;

  Future<void> initialize() async {
    if (!Platform.isAndroid || _initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final appOpenMillis = prefs.getInt(_lastAppOpenKey);
      final interstitialMillis = prefs.getInt(_lastInterstitialKey);
      if (appOpenMillis != null) {
        _lastAppOpenShownAt = DateTime.fromMillisecondsSinceEpoch(appOpenMillis);
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
    AdConfigService.instance.showAdsNotifier.addListener(_onConfigChanged);
    _onConfigChanged();
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
        },
      ),
    );
  }

  void showAppOpenAdIfAvailable() {
    if (!_canRequest || _isShowingAd) return;

    final lastShown = _lastAppOpenShownAt;
    if (lastShown != null &&
        DateTime.now().difference(lastShown).inMinutes < 15) {
      return;
    }

    final loadedAt = _appOpenLoadedAt;
    if (loadedAt != null &&
        DateTime.now().difference(loadedAt).inHours >= 4) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _appOpenLoadedAt = null;
    }

    final ad = _appOpenAd;
    if (ad == null) {
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
        DateTime.now().difference(lastShown).inMinutes < 3) {
      onAdDismissed();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      loadInterstitialAd();
      onAdDismissed();
      return;
    }
    _interstitialAd = null;
    _isShowingAd = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastInterstitialShownAt = DateTime.now();
        _rememberShownAt(_lastInterstitialKey, _lastInterstitialShownAt!);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        debugPrint('InterstitialAd show failed: $error');
        ad.dispose();
        loadInterstitialAd();
        onAdDismissed();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
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
      loadRewardedAd();
      onAdDismissed();
      return;
    }
    _rewardedAd = null;
    _isShowingAd = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        debugPrint('RewardedAd show failed: $error');
        ad.dispose();
        loadRewardedAd();
        onAdDismissed();
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
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
