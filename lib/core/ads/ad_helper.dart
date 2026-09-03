import 'dart:io';

abstract final class AdHelper {
  // Banner Ad ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    return ''; // iOS এর জন্য ফাঁকা রাখা হলো
  }

  // Interstitial Ad ID (Full Screen)
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
    return '';
  }

  // Rewarded Video Ad ID
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/5224354917';
    return '';
  }

  // App Open Ad ID
  static String get appOpenAdUnitId {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/9257395921';
    return '';
  }
}