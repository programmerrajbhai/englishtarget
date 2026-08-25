import 'package:flutter/foundation.dart';

import '../models/rule_progress.dart';
import '../services/rules_progress_service.dart';

class RuleLearningController extends ChangeNotifier {
  final String ruleId;

  RuleLearningController({
    required this.ruleId,
  });

  RuleProgress _progress = const RuleProgress();
  bool _isLoading = false;
  String? _errorMessage;

  RuleProgress get progress => _progress;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get canTakeTest {
    return _progress.learnCompleted;
  }

  bool get canTakeSpeakingTest {
    return _progress.learnCompleted &&
        _progress.testCompleted;
  }

  bool get isRuleCompleted {
    return _progress.isCompleted;
  }

  Future<void> initialize() async {
    _setLoading(true);

    try {
      _progress =
      await RulesProgressService.getRuleProgress(
        ruleId,
      );

      _errorMessage = null;
    } catch (_) {
      _errorMessage =
      'Progress load করা সম্ভব হয়নি।';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeLearning() async {
    _setLoading(true);

    try {
      await RulesProgressService.completeLearn(
        ruleId,
      );

      await _reloadProgress();

      _errorMessage = null;

      return _progress.learnCompleted;
    } catch (_) {
      _errorMessage =
      'Learning progress save করা সম্ভব হয়নি।';

      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<TestSubmissionResult> submitTest({
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    if (!_progress.learnCompleted) {
      return const TestSubmissionResult(
        passed: false,
        correctAnswers: 0,
        totalQuestions: 0,
        message:
        'আগে Rule-এর learning section complete করুন।',
      );
    }

    if (totalQuestions <= 0) {
      return const TestSubmissionResult(
        passed: false,
        correctAnswers: 0,
        totalQuestions: 0,
        message:
        'Test-এ কোনো question পাওয়া যায়নি।',
      );
    }

    _setLoading(true);

    try {
      await RulesProgressService.saveTestResult(
        ruleId: ruleId,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
      );

      await _reloadProgress();

      final passed = _progress.testCompleted;

      _errorMessage = null;

      return TestSubmissionResult(
        passed: passed,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        message: passed
            ? 'Test passed successfully!'
            : 'Test pass করতে কমপক্ষে 70% score প্রয়োজন।',
      );
    } catch (_) {
      _errorMessage =
      'Test result save করা সম্ভব হয়নি।';

      return TestSubmissionResult(
        passed: false,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        message:
        'Test result save করা সম্ভব হয়নি।',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<SpeakingSubmissionResult>
  submitSpeakingTest({
    required int correctAnswers,
    required int totalQuestions,
  }) async {
    if (!_progress.testCompleted) {
      return const SpeakingSubmissionResult(
        passed: false,
        correctAnswers: 0,
        totalQuestions: 0,
        message:
        'আগে Rule Test pass করুন।',
      );
    }

    if (totalQuestions <= 0) {
      return const SpeakingSubmissionResult(
        passed: false,
        correctAnswers: 0,
        totalQuestions: 0,
        message:
        'Speaking test পাওয়া যায়নি।',
      );
    }

    _setLoading(true);

    try {
      await RulesProgressService.saveSpeakingResult(
        ruleId: ruleId,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
      );

      await _reloadProgress();

      final passed =
          _progress.speakingCompleted;

      _errorMessage = null;

      return SpeakingSubmissionResult(
        passed: passed,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        message: passed
            ? 'Speaking test passed!'
            : 'Speaking test pass করতে কমপক্ষে 60% score প্রয়োজন।',
      );
    } catch (_) {
      _errorMessage =
      'Speaking result save করা সম্ভব হয়নি।';

      return SpeakingSubmissionResult(
        passed: false,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        message:
        'Speaking result save করা সম্ভব হয়নি।',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshProgress() async {
    _setLoading(true);

    try {
      await _reloadProgress();
      _errorMessage = null;
    } catch (_) {
      _errorMessage =
      'Progress refresh করা সম্ভব হয়নি।';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _reloadProgress() async {
    _progress =
    await RulesProgressService.getRuleProgress(
      ruleId,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

class TestSubmissionResult {
  final bool passed;
  final int correctAnswers;
  final int totalQuestions;
  final String message;

  const TestSubmissionResult({
    required this.passed,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.message,
  });

  int get percentage {
    if (totalQuestions <= 0) return 0;

    return ((correctAnswers / totalQuestions) * 100)
        .round();
  }
}

class SpeakingSubmissionResult {
  final bool passed;
  final int correctAnswers;
  final int totalQuestions;
  final String message;

  const SpeakingSubmissionResult({
    required this.passed,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.message,
  });

  int get percentage {
    if (totalQuestions <= 0) return 0;

    return ((correctAnswers / totalQuestions) * 100)
        .round();
  }
}