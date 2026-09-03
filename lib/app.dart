import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/ads/ad_manager.dart'; // যুক্ত করা হয়েছে

class EnglishTargetApp extends StatefulWidget {
  const EnglishTargetApp({super.key});

  @override
  State<EnglishTargetApp> createState() => _EnglishTargetAppState();
}

class _EnglishTargetAppState extends State<EnglishTargetApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // অ্যাপের লাইফসাইকেল ট্র্যাক করা শুরু
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // অ্যাপ বন্ধ হলে ট্র্যাকিং রিমুভ করা
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ইউজার যখনই অ্যাপ ব্যাকগ্রাউন্ড থেকে আবার সামনে আনবে (Resumed)
    if (state == AppLifecycleState.resumed) {
      AdManager.instance.showAppOpenAdIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Target',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}