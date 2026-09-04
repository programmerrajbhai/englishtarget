import 'package:flutter/material.dart';

import 'app.dart';
import 'core/ads/ad_manager.dart';
import 'core/ads/ad_config_service.dart'; // যুক্ত করা হয়েছে

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // অ্যাপ চালুর সাথে সাথেই ব্যাকগ্রাউন্ড মনিটরিং শুরু হয়ে যাবে
  AdConfigService.instance.startMonitoring();

  AdManager.instance.initialize();

  runApp(const EnglishTargetApp());
}