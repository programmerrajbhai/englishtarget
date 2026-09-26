import 'dart:io';

abstract final class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6432705880022694/2361322413';
    }
    throw UnsupportedError('iOS banner ad unit ID is not configured.');
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6432705880022694/3371151759';
    }
    throw UnsupportedError('iOS interstitial ad unit ID is not configured.');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6432705880022694/5344427607';
    }
    throw UnsupportedError('iOS rewarded ad unit ID is not configured.');
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6432705880022694/6859699573';
    }
    throw UnsupportedError('iOS app open ad unit ID is not configured.');
  }
}