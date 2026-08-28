import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../basic_sentences/data/basic_sentences_data.dart';
import '../../basic_sentences/models/basic_sentence_topic.dart';
import '../../basic_sentences/services/basic_sentence_progress_service.dart';
import '../../basic_sentences/services/basic_sentence_xp_service.dart';
import '../../daily_challenge/services/daily_challenge_progress_service.dart';
import '../../question_making/data/question_making_data.dart';
import '../../question_making/services/question_making_progress_service.dart';
import '../../question_making/widgets/question_making_topic.dart';
import '../../rules/models/rule_item.dart';
import '../../rules/models/rule_progress.dart';
import '../../rules/models/rules_data.dart';
import '../../rules/services/rules_progress_service.dart';

class HomeResumeItem {
  final String title;
  final String subtitle;
  final String route;
  final double progress;
  final IconData icon;
  final Color color;

  const HomeResumeItem({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.progress,
    required this.icon,
    required this.color,
  });
}

class HomeDashboardData {
  final int xp;
  final int level;
  final double levelProgress;
  final int xpToNextLevel;

  final int completedLessons;
  final int completedBadges;
  final int todayPractices;

  final int dailyCompleted;
  final int dailyTotal;
  final int dailyStreak;
  final bool dailyXpAwarded;

  final double overallProgress;
  final Map<String, double> categoryProgress;
  final HomeResumeItem resumeItem;

  const HomeDashboardData({
    required this.xp,
    required this.level,
    required this.levelProgress,
    required this.xpToNextLevel,
    required this.completedLessons,
    required this.completedBadges,
    required this.todayPractices,
    required this.dailyCompleted,
    required this.dailyTotal,
    required this.dailyStreak,
    required this.dailyXpAwarded,
    required this.overallProgress,
    required this.categoryProgress,
    required this.resumeItem,
  });
}

abstract final class HomeDashboardService {
  static const int _xpPerLevel = 250;
  static const int _basicPracticeTotal = 25;
  static const int _questionPracticeTotal = 25;

  static Future<HomeDashboardData> load() async {
    final List<BasicSentenceTopic> basicTopics =
        BasicSentencesData.topics;

    final List<QuestionMakingTopic> questionTopics =
        QuestionMakingData.topics;

    final List<dynamic> results =
    await Future.wait<dynamic>([
      Future.wait<int>(
        basicTopics.map(
              (BasicSentenceTopic topic) {
            return BasicSentenceProgressService.getCount(
              topic.id,
            );
          },
        ),
      ),
      Future.wait<int>(
        questionTopics.map(
              (QuestionMakingTopic topic) {
            return QuestionMakingProgressService.getCount(
              topic.id,
            );
          },
        ),
      ),
      RulesProgressService.loadAllProgress(),
      DailyChallengeProgressService.getState(),
      BasicSentenceXpService.load(),
    ]);

    final List<int> basicCounts =
    List<int>.from(results[0] as List<int>);

    final List<int> questionCounts =
    List<int>.from(results[1] as List<int>);

    final Map<String, RuleProgress> ruleProgress =
    Map<String, RuleProgress>.from(
      results[2] as Map<String, RuleProgress>,
    );

    final DailyChallengeState dailyState =
    results[3] as DailyChallengeState;

    final int xp = results[4] as int;

    final int basicPractices = basicCounts.fold<int>(
      0,
          (int total, int value) {
        return total +
            _cap(value, _basicPracticeTotal);
      },
    );

    final int questionPractices =
    questionCounts.fold<int>(
      0,
          (int total, int value) {
        return total +
            _cap(value, _questionPracticeTotal);
      },
    );

    final int ruleSteps = ruleProgress.values.fold<int>(
      0,
          (int total, RuleProgress progress) {
        return total + progress.completedSteps;
      },
    );

    final int dailyPractices =
    _cap(dailyState.completedCount, dailyState.totalCount);

    final int completedLessons =
        basicPractices +
            questionPractices +
            ruleSteps +
            dailyPractices;

    final int totalLessons =
        (basicTopics.length * _basicPracticeTotal) +
            (questionTopics.length * _questionPracticeTotal) +
            (RulesData.rules.length * 3) +
            dailyState.totalCount;

    final int completedBasicTopics = basicCounts
        .where(
          (int count) => count >= _basicPracticeTotal,
    )
        .length;

    final int completedQuestionTopics =
        questionCounts
            .where(
              (int count) =>
          count >= _questionPracticeTotal,
        )
            .length;

    final int completedRules = ruleProgress.values
        .where(
          (RuleProgress progress) => progress.isCompleted,
    )
        .length;

    final int completedBadges =
        completedBasicTopics +
            completedQuestionTopics +
            completedRules +
            (dailyState.isComplete ? 1 : 0);

    final int level = (xp ~/ _xpPerLevel) + 1;

    final int currentLevelStart =
        (level - 1) * _xpPerLevel;

    final int currentLevelXp =
    (xp - currentLevelStart).clamp(0, _xpPerLevel);

    final double levelProgress =
    (currentLevelXp / _xpPerLevel)
        .clamp(0.0, 1.0)
        .toDouble();

    final int xpToNextLevel =
    (level * _xpPerLevel - xp)
        .clamp(0, _xpPerLevel);

    final double overallProgress = totalLessons == 0
        ? 0
        : (completedLessons / totalLessons)
        .clamp(0.0, 1.0)
        .toDouble();

    final int totalRuleSteps =
        RulesData.rules.length * 3;

    final int totalBasicPractices =
        basicTopics.length * _basicPracticeTotal;

    final int totalQuestionPractices =
        questionTopics.length * _questionPracticeTotal;

    final Map<String, double> categoryProgress =
    <String, double>{
      'Learn Rules': totalRuleSteps == 0
          ? 0
          : (ruleSteps / totalRuleSteps)
          .clamp(0.0, 1.0)
          .toDouble(),
      'Basic Sentences': totalBasicPractices == 0
          ? 0
          : (basicPractices / totalBasicPractices)
          .clamp(0.0, 1.0)
          .toDouble(),
      'Question Making': totalQuestionPractices == 0
          ? 0
          : (questionPractices / totalQuestionPractices)
          .clamp(0.0, 1.0)
          .toDouble(),
      'Daily Challenge': dailyState.totalCount == 0
          ? 0
          : (dailyPractices / dailyState.totalCount)
          .clamp(0.0, 1.0)
          .toDouble(),
    };

    final HomeResumeItem resumeItem = _findResumeItem(
      basicTopics: basicTopics,
      basicCounts: basicCounts,
      questionTopics: questionTopics,
      questionCounts: questionCounts,
      ruleProgress: ruleProgress,
      dailyState: dailyState,
    );

    return HomeDashboardData(
      xp: xp,
      level: level,
      levelProgress: levelProgress,
      xpToNextLevel: xpToNextLevel,
      completedLessons: completedLessons,
      completedBadges: completedBadges,
      todayPractices: dailyPractices,
      dailyCompleted: dailyPractices,
      dailyTotal: dailyState.totalCount,
      dailyStreak: dailyState.streak,
      dailyXpAwarded: dailyState.xpAwarded,
      overallProgress: overallProgress,
      categoryProgress:
      Map<String, double>.unmodifiable(
        categoryProgress,
      ),
      resumeItem: resumeItem,
    );
  }

  static HomeResumeItem _findResumeItem({
    required List<BasicSentenceTopic> basicTopics,
    required List<int> basicCounts,
    required List<QuestionMakingTopic> questionTopics,
    required List<int> questionCounts,
    required Map<String, RuleProgress> ruleProgress,
    required DailyChallengeState dailyState,
  }) {
    final List<_ResumeCandidate> candidates =
    <_ResumeCandidate>[];

    for (int index = 0;
    index < basicTopics.length;
    index++) {
      final BasicSentenceTopic topic =
      basicTopics[index];

      final int completed =
      _cap(basicCounts[index], _basicPracticeTotal);

      if (completed < _basicPracticeTotal) {
        candidates.add(
          _ResumeCandidate(
            progress: completed / _basicPracticeTotal,
            item: HomeResumeItem(
              title: topic.title,
              subtitle:
              'Basic Sentences • $completed/25 practices',
              route: AppRoutes.basicSentences,
              progress: completed / _basicPracticeTotal,
              icon: topic.icon,
              color: topic.color,
            ),
          ),
        );
      }
    }

    for (int index = 0;
    index < questionTopics.length;
    index++) {
      final QuestionMakingTopic topic =
      questionTopics[index];

      final int completed =
      _cap(questionCounts[index], _questionPracticeTotal);

      if (completed < _questionPracticeTotal) {
        candidates.add(
          _ResumeCandidate(
            progress: completed / _questionPracticeTotal,
            item: HomeResumeItem(
              title: topic.title,
              subtitle:
              'Question Making • $completed/25 practices',
              route: AppRoutes.questionMaking,
              progress: completed / _questionPracticeTotal,
              icon: topic.icon,
              color: topic.color,
            ),
          ),
        );
      }
    }

    for (final RuleItem rule in RulesData.rules) {
      final RuleProgress progress =
          ruleProgress[rule.id] ?? const RuleProgress();

      if (!progress.isCompleted) {
        candidates.add(
          _ResumeCandidate(
            progress: progress.progress,
            item: HomeResumeItem(
              title: rule.title,
              subtitle:
              'Learn Rules • Step ${progress.completedSteps + 1} of 3',
              route: AppRoutes.rules,
              progress: progress.progress,
              icon: rule.icon,
              color: rule.color,
            ),
          ),
        );
      }
    }

    if (!dailyState.isComplete) {
      final int completed =
      _cap(dailyState.completedCount, dailyState.totalCount);

      candidates.add(
        _ResumeCandidate(
          progress: dailyState.totalCount == 0
              ? 0
              : completed / dailyState.totalCount,
          item: HomeResumeItem(
            title: 'Daily Challenge',
            subtitle:
            'Daily Challenge • $completed/10 completed',
            route: AppRoutes.dailyChallenge,
            progress: dailyState.totalCount == 0
                ? 0
                : completed / dailyState.totalCount,
            icon: Icons.emoji_events_rounded,
            color: Colors.orange,
          ),
        ),
      );
    }

    if (candidates.isEmpty) {
      return const HomeResumeItem(
        title: 'Daily Challenge',
        subtitle: 'Start today’s challenge',
        route: AppRoutes.dailyChallenge,
        progress: 0,
        icon: Icons.emoji_events_rounded,
        color: Colors.orange,
      );
    }

    candidates.sort(
          (_ResumeCandidate first, _ResumeCandidate second) {
        return second.progress.compareTo(first.progress);
      },
    );

    return candidates.first.item;
  }

  static int _cap(int value, int maximum) {
    return value.clamp(0, maximum).toInt();
  }
}

class _ResumeCandidate {
  final double progress;
  final HomeResumeItem item;

  const _ResumeCandidate({
    required this.progress,
    required this.item,
  });
}