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
    final encodedData =
    await _preferences.getString(_storageKey);

    if (encodedData == null || encodedData.isEmpty) {
      return {};
    }

    try {
      final decodedData = jsonDecode(encodedData);

      if (decodedData is! Map<String, dynamic>) {
        return {};
      }

      return decodedData.map(
            (ruleId, progressData) {
          final json = Map<String, dynamic>.from(
            progressData as Map,
          );

          return MapEntry(
            ruleId,
            RuleProgress.fromJson(json),
          );
        },
      );
    } catch (_) {
      return {};
    }
  }

  static Future<RuleProgress> getRuleProgress(
      String ruleId,
      ) async {
    final allProgress = await loadAllProgress();

    return allProgress[ruleId] ??
        const RuleProgress();
  }

  static Future<void> _saveAllProgress(
      Map<String, RuleProgress> allProgress,
      ) async {
    final jsonMap = allProgress.map(
          (ruleId, progress) {
        return MapEntry(
          ruleId,
          progress.toJson(),
        );
      },
    );

    await _preferences.setString(
      _storageKey,
      jsonEncode(jsonMap),
    );
  }

  static Future<void> _updateRule(
      String ruleId,
      RuleProgress Function(
          RuleProgress currentProgress,
          ) update,
      ) async {
    final allProgress = await loadAllProgress();

    final currentProgress =
        allProgress[ruleId] ??
            const RuleProgress();

    allProgress[ruleId] = update(currentProgress);

    await _saveAllProgress(allProgress);
  }

  static Future<void> completeLearn(
      String ruleId,
      ) async {
    await _updateRule(
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

    final percentage =
        correctAnswers / totalQuestions;

    final passed = percentage >= 0.70;

    await _updateRule(
      ruleId,
          (current) {
        return current.copyWith(
          testCompleted:
          current.testCompleted || passed,
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

    final percentage =
        correctAnswers / totalQuestions;

    final passed = percentage >= 0.60;

    await _updateRule(
      ruleId,
          (current) {
        return current.copyWith(
          speakingCompleted:
          current.speakingCompleted || passed,
          speakingCorrectAnswers: correctAnswers,
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

    final previousRuleId =
    orderedRuleIds[ruleIndex - 1];

    final previousProgress =
        progressMap[previousRuleId] ??
            const RuleProgress();

    return previousProgress.isCompleted;
  }

  static Future<void> resetAllProgress() async {
    await _preferences.remove(_storageKey);
  }
}