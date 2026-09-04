import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/ads/ad_manager.dart';

// --- NEW IMPORTS ---
import 'core/services/update_service.dart';
import 'core/widgets/global_network_wrapper.dart';

class EnglishTargetApp extends StatefulWidget {
  const EnglishTargetApp({super.key});

  @override
  State<EnglishTargetApp> createState() => _EnglishTargetAppState();
}

class _EnglishTargetAppState extends State<EnglishTargetApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // --- 1. CHECK FOR FLEXIBLE IN-APP UPDATE ---
    UpdateService.checkForFlexibleUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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

      // --- 2. WRAP ENTIRE APP TO REQUIRE INTERNET ---
      // MaterialApp-এর builder দিয়ে আমরা পুরো অ্যাপকে ব্লক করতে পারি
      builder: (context, child) {
        return GlobalNetworkWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}