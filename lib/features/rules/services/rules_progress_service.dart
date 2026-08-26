import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/rule_progress.dart';

abstract final class RulesProgressService {
  static const String _storageKey =
      'english_target_rules_progress_v1';

  static final SharedPreferencesAsync _preferences =
  SharedPreferencesAsync();

  static Future<Map<String, RuleProgress>>
  loadAllProgress() async {
    final String? data =
    await _preferences.getString(_storageKey);

    if (data == null || data.isEmpty) {
      return <String, RuleProgress>{};
    }

    try {
      final dynamic decoded = jsonDecode(data);

      if (decoded is! Map<String, dynamic>) {
        return <String, RuleProgress>{};
      }

      return decoded.map(
            (String ruleId, dynamic value) {
          return MapEntry(
            ruleId,
            RuleProgress.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          );
        },
      );
    } catch (_) {
      return <String, RuleProgress>{};
    }
  }

  static Future<RuleProgress> getRuleProgress(
      String ruleId,
      ) async {
    final progress = await loadAllProgress();

    return progress[ruleId] ??
        const RuleProgress();
  }

  static Future<void> _save(
      Map<String, RuleProgress> progress,
      ) async {
    final data = progress.map(
          (String ruleId, RuleProgress value) {
        return MapEntry(ruleId, value.toJson());
      },
    );

    await _preferences.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  static Future<void> _update(
      String ruleId,
      RuleProgress Function(RuleProgress current) update,
      ) async {
    final all = await loadAllProgress();

    final current =
        all[ruleId] ?? const RuleProgress();

    all[ruleId] = update(current);

    await _save(all);
  }

  static Future<void> completeLearn(
      String ruleId,
      ) async {
    await _update(
      ruleId,
          (current) {
        return current.copyWith(
          learnCompleted: true,
        );
      },
    );
  }

  static Future<void> saveTestResult({
    required String ruleId,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    if (totalQuestions <= 0) return;

    final double score =
        correctAnswers / totalQuestions;

    await _update(
      ruleId,
          (current) {
        return current.copyWith(
          testCompleted:
          current.testCompleted ||
              score >= 0.70,
          testCorrectAnswers: correctAnswers,
        );
      },
    );
  }

  static Future<void> saveSpeakingResult({
    required String ruleId,
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    if (totalQuestions <= 0) return;

    await _update(
      ruleId,
          (current) {
        return current.copyWith(
          speakingCorrectAnswers:
          correctAnswers,
        );
      },
    );
  }

  static Future<void> completeSpeaking({
    required String ruleId,
    required int correctAnswers,
  }) async {
    await _update(
      ruleId,
          (current) {
        return current.copyWith(
          speakingCompleted: true,
          speakingCorrectAnswers:
          correctAnswers,
        );
      },
    );
  }

  static bool isRuleUnlocked({
    required int ruleIndex,
    required List<String> orderedRuleIds,
    required Map<String, RuleProgress> progressMap,
  }) {
    if (ruleIndex == 0) {
      return true;
    }

    final String previousId =
    orderedRuleIds[ruleIndex - 1];

    final RuleProgress previous =
        progressMap[previousId] ??
            const RuleProgress();

    return previous.isCompleted;
  }

  static Future<void> resetAllProgress() async {
    await _preferences.remove(_storageKey);
  }
}