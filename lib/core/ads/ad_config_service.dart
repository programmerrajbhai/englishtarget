import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdConfigService {
  static final AdConfigService instance = AdConfigService._init();
  AdConfigService._init();

  final ValueNotifier<bool> showAdsNotifier = ValueNotifier<bool>(true);

  bool get showAds => showAdsNotifier.value;

  final String _configUrl = 'https://willkoservices.com/ads_controllers/ads_config.json';
  Timer? _pollingTimer;

  // ব্যাকগ্রাউন্ডে অনবরত চেক করার জন্য
  void startMonitoring() {
    fetchAdSettings(); // প্রথমবার চেক
    _pollingTimer?.cancel();

    // প্রতি ১০ সেকেন্ড পরপর সার্ভার চেক করবে (অ্যাডমিন প্যানেল থেকে চেঞ্জ করলে ১০ সেকেন্ডের মধ্যে অ্যাপে ইফেক্ট পড়বে)
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchAdSettings();
    });
  }

  Future<void> fetchAdSettings() async {
    try {
      final url = '$_configUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data['show_ads'] != null) {
          final bool serverStatus = data['show_ads'] as bool;

          // যদি সার্ভারের স্ট্যাটাস পরিবর্তন হয়, তবেই UI আপডেট করবে
          if (showAdsNotifier.value != serverStatus) {
            showAdsNotifier.value = serverStatus;
            debugPrint('Ad Status Changed Instantly to: $serverStatus');
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch ad config: $e');
    }
  }
}