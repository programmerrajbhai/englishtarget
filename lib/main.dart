import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // এই প্যাকেজটি ইমপোর্ট করুন

import 'app.dart';
import 'core/ads/ad_manager.dart';
import 'core/ads/ad_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Edge-to-Edge UI Fix ---
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // ---------------------------

  AdConfigService.instance.startMonitoring();
  AdManager.instance.initialize();

  runApp(const EnglishTargetApp());


}