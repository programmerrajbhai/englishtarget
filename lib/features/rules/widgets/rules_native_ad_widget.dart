import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/ads/ad_config_service.dart';
import '../../../core/ads/ad_helper.dart';

class RulesNativeAdWidget extends StatefulWidget {
  const RulesNativeAdWidget({super.key});

  @override
  State<RulesNativeAdWidget> createState() => _RulesNativeAdWidgetState();
}

class _RulesNativeAdWidgetState extends State<RulesNativeAdWidget> {
  NativeAd? _ad;
  Timer? _retryTimer;
  bool _loading = false;
  bool _loaded = false;
  int _retryCount = 0;

  bool get _enabled => Platform.isAndroid && AdConfigService.instance.showAds;

  @override
  void initState() {
    super.initState();
    AdConfigService.instance.showAdsNotifier.addListener(_syncAd);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncAd());
  }

  void _syncAd() {
    if (!_enabled) {
      _retryTimer?.cancel();
      _retryTimer = null;

      final oldAd = _ad;
      _ad = null;
      _loading = false;
      _loaded = false;
      oldAd?.dispose();

      if (mounted) setState(() {});
      return;
    }

    if (_ad == null && !_loading) _loadAd();
  }

  void _loadAd() {
    if (!_enabled || _loading || !mounted) return;

    _loading = true;

    late final NativeAd ad;
    ad = NativeAd(
      adUnitId: AdHelper.rulesNativeAdUnitId,
      factoryId: 'rulesNativeAd',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted || !_enabled || !identical(ad, loadedAd)) {
            loadedAd.dispose();
            return;
          }

          _retryCount = 0;
          _loading = false;
          _loaded = true;
          setState(() {});
        },
        onAdFailedToLoad: (failedAd, error) {
          debugPrint(
            'Rules native ad failed: '
            '${error.code} ${error.message}',
          );

          failedAd.dispose();
          if (!mounted || !identical(_ad, failedAd)) return;

          _ad = null;
          _loading = false;
          _loaded = false;
          setState(() {});
          _scheduleRetry();
        },
      ),
    );

    _ad = ad;
    ad.load();
  }

  void _scheduleRetry() {
    if (!_enabled || !mounted) return;

    final seconds = (60 * (1 << _retryCount)).clamp(60, 300);
    _retryCount = (_retryCount + 1).clamp(0, 3);

    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: seconds), () {
      _retryTimer = null;
      if (mounted && _enabled && _ad == null) _loadAd();
    });
  }

  @override
  void dispose() {
    AdConfigService.instance.showAdsNotifier.removeListener(_syncAd);
    _retryTimer?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_enabled || !_loaded || ad == null) {
      return const SizedBox.shrink();
    }


    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFE2E8EF)),
        ),

        child: SizedBox(
          height: 300,
          width: double.infinity,
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
