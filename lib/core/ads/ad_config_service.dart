import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdConfigService {
  AdConfigService._();
  static final AdConfigService instance = AdConfigService._();

  static const String _configUrl =
      'https://willkoservices.com/ads_controllers/ads_config.json';

  final ValueNotifier<bool> showAdsNotifier = ValueNotifier<bool>(false);
  bool get showAds => showAdsNotifier.value;

  Timer? _timer;
  bool _fetching = false;

  Future<void> initialize() async {
    await fetchAdSettings();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
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
    } catch (error) {
      debugPrint('Ad config request failed: $error');
    } finally {
      _fetching = false;
    }
  }
}
