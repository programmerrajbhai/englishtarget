import 'dart:io';

abstract final class AdHelper {
  /// true  = Test Ads (ডেভেলপমেন্ট ও টেস্টিংয়ের জন্য)
  /// false = Live Ads (Play Store রিলিজের জন্য)
  static const bool useTestAds = true;

  static String get bannerAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/9214589741';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-6432705880022694/2361322413';
    }
    throw UnsupportedError('iOS banner ad unit ID is not configured.');
  }

  static String get interstitialAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-6432705880022694/3371151759';
    }
    throw UnsupportedError('iOS interstitial ad unit ID is not configured.');
  }

  static String get rewardedAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/5224354917';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-6432705880022694/5344427607';
    }
    throw UnsupportedError('iOS rewarded ad unit ID is not configured.');
  }

  static String get appOpenAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/9257395921';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-6432705880022694/6859699573';
    }
    throw UnsupportedError('iOS app open ad unit ID is not configured.');
  }

  static String get rulesNativeAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/2247696110';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-6432705880022694/9559021668';
    }
    throw UnsupportedError('Rules native ad is Android-only.');
  }

}