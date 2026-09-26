import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  static const String _androidBannerId =
      'ca-app-pub-6432705880022694/2361322413';

  BannerAd? _bannerAd;
  Timer? _retryTimer;

  bool _isLoading = false;
  bool _isLoaded = false;
  int? _requestedWidth;
  int _requestVersion = 0;
  int _retryCount = 0;

  bool get _adsEnabled =>
      Platform.isAndroid && AdConfigService.instance.showAds;

  @override
  void initState() {
    super.initState();
    AdConfigService.instance.showAdsNotifier.addListener(_scheduleSync);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleSync();
  }

  void _scheduleSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncAd();
    });
  }

  void _syncAd() {
    if (!_adsEnabled) {
      _clearAd();
      return;
    }

    final width = MediaQuery.sizeOf(context).width.truncate();
    if (width <= 0) return;

    if (_requestedWidth == width &&
        (_isLoading || _bannerAd != null)) {
      return;
    }

    _loadAd(width);
  }

  void _disposeAfterFrame(BannerAd? ad) {
    if (ad == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ad.dispose();
    });
  }

  void _clearAd() {
    _requestVersion++;
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryCount = 0;

    final oldAd = _bannerAd;
    final wasVisible = _isLoaded;

    _bannerAd = null;
    _isLoading = false;
    _isLoaded = false;
    _requestedWidth = null;

    if (wasVisible && mounted) setState(() {});
    _disposeAfterFrame(oldAd);
  }

  Future<void> _loadAd(int width) async {
    _retryTimer?.cancel();
    _retryTimer = null;

    final version = ++_requestVersion;
    final oldAd = _bannerAd;

    _bannerAd = null;
    _isLoaded = false;
    _isLoading = true;
    _requestedWidth = width;
    setState(() {});
    _disposeAfterFrame(oldAd);

    try {
      final size =
      await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        width,
      );

      if (!mounted || version != _requestVersion || !_adsEnabled) {
        return;
      }

      if (size == null) {
        _isLoading = false;
        debugPrint('BannerAd: adaptive size unavailable.');
        _scheduleRetry();
        return;
      }

      late final BannerAd ad;
      ad = BannerAd(
        adUnitId: _androidBannerId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (loadedAd) {
            if (!mounted ||
                version != _requestVersion ||
                !_adsEnabled ||
                !identical(_bannerAd, loadedAd)) {
              return;
            }

            _isLoading = false;
            _isLoaded = true;
            _retryCount = 0;
            debugPrint('BannerAd loaded successfully.');
            setState(() {});
          },
          onAdFailedToLoad: (failedAd, error) {
            if (version != _requestVersion ||
                !identical(_bannerAd, failedAd)) {
              return;
            }

            debugPrint(
              'BannerAd failed: '
                  'domain=${error.domain}, '
                  'code=${error.code}, '
                  'message=${error.message}, '
                  'responseInfo=${error.responseInfo}',
            );

            _bannerAd = null;
            _isLoading = false;
            _isLoaded = false;
            failedAd.dispose();

            if (mounted) {
              setState(() {});
              _scheduleRetry();
            }
          },
        ),
      );

      _bannerAd = ad;
      await ad.load();
    } catch (error) {
      if (!mounted || version != _requestVersion) return;

      debugPrint('BannerAd load exception: $error');
      final failedAd = _bannerAd;
      _bannerAd = null;
      _isLoading = false;
      _isLoaded = false;
      failedAd?.dispose();
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    if (!mounted || !_adsEnabled || _retryCount >= 3) return;

    final delay = Duration(seconds: 60 << _retryCount);
    _retryCount++;

    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      _scheduleSync();
    });
  }

  @override
  void dispose() {
    AdConfigService.instance.showAdsNotifier.removeListener(_scheduleSync);
    _retryTimer?.cancel();
    _requestVersion++;
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;

    if (!_adsEnabled || !_isLoaded || ad == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Center(
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}