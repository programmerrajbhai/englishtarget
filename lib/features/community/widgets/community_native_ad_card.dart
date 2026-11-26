import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/ads/ad_config_service.dart';
import '../../../core/ads/ad_helper.dart';

class CommunityNativeAdCard extends StatefulWidget {
  const CommunityNativeAdCard({super.key});

  @override
  State<CommunityNativeAdCard> createState() => _CommunityNativeAdCardState();
}

class _CommunityNativeAdCardState extends State<CommunityNativeAdCard>
    with AutomaticKeepAliveClientMixin {
  static const Color _green = Color(0xFF008B48);
  static const Color _ink = Color(0xFF102038);
  static const Color _mint = Color(0xFFE4F6EF);

  NativeAd? _nativeAd;
  Timer? _retryTimer;

  bool _isLoading = false;
  bool _isLoaded = false;
  int _retryCount = 0;

  bool get _adsEnabled =>
      Platform.isAndroid && AdConfigService.instance.showAds;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    AdConfigService.instance.showAdsNotifier.addListener(_onConfigChanged);
    _loadAd();
  }

  void _onConfigChanged() {
    if (!mounted) return;
    if (!_adsEnabled) {
      _disposeAd();
    } else if (_nativeAd == null && !_isLoading) {
      _loadAd();
    }
  }

  void _disposeAd() {
    _retryTimer?.cancel();
    _retryTimer = null;
    final oldAd = _nativeAd;
    _nativeAd = null;
    _isLoading = false;
    _isLoaded = false;
    oldAd?.dispose();
    if (mounted) setState(() {});
  }

  void _loadAd() {
    if (!_adsEnabled || _isLoading || _nativeAd != null) return;

    _isLoading = true;

    final ad = NativeAd(
      adUnitId: AdHelper.rulesNativeAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 16.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: _green,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: _ink,
          style: NativeTemplateFontStyle.bold,
          size: 15.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF64748B),
          style: NativeTemplateFontStyle.normal,
          size: 13.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF64748B),
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (Ad loadedAd) {
          if (!mounted || !_adsEnabled) {
            loadedAd.dispose();
            return;
          }
          setState(() {
            _nativeAd = loadedAd as NativeAd;
            _isLoading = false;
            _isLoaded = true;
            _retryCount = 0;
          });
        },
        onAdFailedToLoad: (Ad failedAd, LoadAdError error) {
          debugPrint(
            'CommunityNativeAd failed: code=${error.code}, message=${error.message}',
          );
          failedAd.dispose();
          if (!mounted) return;
          setState(() {
            _nativeAd = null;
            _isLoading = false;
            _isLoaded = false;
          });
          _scheduleRetry();
        },
      ),
    );

    ad.load();
  }

  void _scheduleRetry() {
    if (!mounted || !_adsEnabled || _retryCount >= 2) return;
    final delay = Duration(seconds: 20 << _retryCount);
    _retryCount++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      _loadAd();
    });
  }

  @override
  void dispose() {
    AdConfigService.instance.showAdsNotifier.removeListener(_onConfigChanged);
    _retryTimer?.cancel();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_adsEnabled || !_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFD5EDE3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: _mint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Sponsored · Ad',
                style: TextStyle(
                  color: _green,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 330,
              width: double.infinity,
              child: AdWidget(ad: _nativeAd!),
            ),
          ],
        ),
      ),
    );
  }
}