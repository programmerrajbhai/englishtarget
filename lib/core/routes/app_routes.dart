import 'package:flutter/material.dart';

import '../../features/basic_sentences/screens/basic_sentences_screen.dart';
import '../../features/daily_challenge/screens/daily_challenge_screen.dart';
import '../../features/home/screens/main_navigation_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/progress/screens/achievements_screen.dart';
import '../../features/question_making/screens/question_making_screen.dart';
import '../../features/rules/screens/rules_list_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';

  static const String onboarding = '/onboarding';

  static const String home = '/home';

  static const String rules = '/rules';

  static const String basicSentences = '/basic-sentences';

  static const String questionMaking = '/question-making';

  static const String dailyChallenge = '/daily-challenge';

  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(
      RouteSettings routeSettings,
      ) {
    switch (routeSettings.name) {
      case splash:
        return _buildRoute(
          const SplashScreen(),
          routeSettings,
        );

      case onboarding:
        return _buildRoute(
          const OnboardingScreen(),
          routeSettings,
        );

      case home:
        return _buildRoute(
          const MainNavigationScreen(),
          routeSettings,
        );

      case rules:
        return _buildRoute(
          const RulesListScreen(),
          routeSettings,
        );

      case basicSentences:
        return _buildRoute(
          const BasicSentencesScreen(),
          routeSettings,
        );

      case questionMaking:
        return _buildRoute(
          const QuestionMakingScreen(),
          routeSettings,
        );

      case dailyChallenge:
        return _buildRoute(
          const DailyChallengeScreen(),
          routeSettings,
        );

      case settings:
        return _buildRoute(
          const SettingsScreen(),
          routeSettings,
        );

      default:
        return _buildRoute(
          const SplashScreen(),
          routeSettings,
        );
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
      Widget screen,
      RouteSettings routeSettings,
      ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => screen,
      settings: routeSettings,
    );
  }
}