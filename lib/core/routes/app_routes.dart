import 'package:flutter/material.dart';

import '../../features/basic_sentences/screens/basic_sentences_screen.dart';
import '../../features/daily_challenge/screens/daily_challenge_screen.dart';
import '../../features/home/screens/main_navigation_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/question_making/screens/question_making_screen.dart';
import '../../features/rules/screens/rules_list_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

abstract final class AppRoutes {
  static const String splash = '/';

  static const String onboarding = '/onboarding';

  static const String home = '/home';

  static const String rules = '/rules';

  static const String basicSentences =
      '/basic-sentences';

  static const String questionMaking =
      '/question-making';


  static const String dailyChallenge =
      '/daily-challenge';

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

      case basicSentences:
        return _buildRoute(
          const BasicSentencesScreen(),
          settings,
        );

      case questionMaking:
        return _buildRoute(
          const QuestionMakingScreen(),
          settings,
        );

      case dailyChallenge:
        return _buildRoute(
          const DailyChallengeScreen(),
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
    return MaterialPageRoute<dynamic>(
      builder: (_) => screen,
      settings: settings,
    );
  }
}