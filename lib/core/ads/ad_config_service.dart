import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdConfigService {
  AdConfigService._();
  static final AdConfigService instance = AdConfigService._();

  static const String _configUrl =
      'https://willkoservices.com/ads_controllers/ads_config.json';
  static const String _cachedShowAdsKey = 'cached_show_ads_enabled';

  // ডিফল্ট true রাখা হয়েছে যাতে নেট স্লো হলেও অ্যাপ ওপেনেই অ্যাড লোড শুরু করতে পারে
  final ValueNotifier<bool> showAdsNotifier = ValueNotifier<bool>(true);
  bool get showAds => showAdsNotifier.value;

  Timer? _timer;
  bool _fetching = false;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getBool(_cachedShowAdsKey);
      if (cached != null) {
        showAdsNotifier.value = cached;
      }
    } catch (e) {
      debugPrint('Ad config cache restore failed: $e');
    }

    await fetchAdSettings();
    _timer?.cancel();
    // প্রতি ৩০ সেকেন্ডের বদলে ১৫ মিনিট পরপর চেক করবে (সার্ভার ও ব্যাটারি সেফ)
    _timer = Timer.periodic(const Duration(minutes: 15), (_) {
      unawaited(fetchAdSettings());
    });
  }

  Future<void> fetchAdSettings() async {
    if (_fetching) return;
    _fetching = true;
    try {
      final uri = Uri.parse(_configUrl).replace(
        queryParameters: {'t': DateTime.now().millisecondsSinceEpoch.toString()},
      );
      final response = await http.get(
        uri,
        headers: const {'Cache-Control': 'no-cache'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        debugPrint('Ad config HTTP ${response.statusCode}');
        return;
      }
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic> || data['show_ads'] is! bool) {
        debugPrint('Ad config has no boolean show_ads.');
        return;
      }
      final enabled = data['show_ads'] as bool;
      if (showAdsNotifier.value != enabled) {
        showAdsNotifier.value = enabled;
        debugPrint('Ads enabled: $enabled');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cachedShowAdsKey, enabled);
    } catch (error) {
      debugPrint('Ad config request failed: $error');
    } finally {
      _fetching = false;
    }
  }
}