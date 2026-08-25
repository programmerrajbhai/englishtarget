import 'package:flutter/material.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_navigation_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/rules/screens/rules_list_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';

  static const String rules = '/rules';

  static Route<dynamic> onGenerateRoute(
      RouteSettings settings,
      ) {
    switch (settings.name) {
      case splash:
        return _buildRoute(
          const SplashScreen(),
          settings,
        );

      case onboarding:
        return _buildRoute(
          const OnboardingScreen(),
          settings,
        );

      case home:
        return _buildRoute(
          const MainNavigationScreen(),
          settings,
        );

      case rules:
        return _buildRoute(
          const RulesListScreen(),
          settings,
        );

      default:
        return _buildRoute(
          const SplashScreen(),
          settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
      Widget screen,
      RouteSettings settings,
      ) {
    return MaterialPageRoute(
      builder: (_) => screen,
      settings: settings,
    );
  }
}