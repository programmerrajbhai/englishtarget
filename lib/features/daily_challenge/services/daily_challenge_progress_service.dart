import 'package:shared_preferences/shared_preferences.dart';

import '../../basic_sentences/services/basic_sentence_xp_service.dart';

class DailyChallengeState {
  final Set<String> completedIds;
  final Set<String> correctIds;
  final bool xpAwarded;
  final int streak;

  const DailyChallengeState({
    required this.completedIds,
    required this.correctIds,
    required this.xpAwarded,
    required this.streak,
  });

  int get completedCount => completedIds.length;

  int get correctCount => correctIds.length;

  int get totalCount => 10;

  bool get isComplete =>
      completedIds.length >= totalCount;
}

abstract final class DailyChallengeProgressService {
  static const String _dateKey =
      'daily_challenge_date_v1';

  static const String _completedKey =
      'daily_challenge_completed_v1';

  static const String _correctKey =
      'daily_challenge_correct_v1';

  static const String _xpAwardedKey =
      'daily_challenge_xp_awarded_v1';

  static const String _streakKey =
      'daily_challenge_streak_v1';

  static const String _lastCompletedKey =
      'daily_challenge_last_completed_v1';

  static String _todayKey() {
    final DateTime now = DateTime.now();

    final String month =
    now.month.toString().padLeft(2, '0');

    final String day =
    now.day.toString().padLeft(2, '0');

    return '${now.year}-$month-$day';
  }

  static Future<DailyChallengeState> getState() async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final String today = _todayKey();

    final String? savedDate =
    preferences.getString(_dateKey);

    if (savedDate != today) {
      await preferences.setString(
        _dateKey,
        today,
      );

      await preferences.remove(_completedKey);
      await preferences.remove(_correctKey);
      await preferences.remove(_xpAwardedKey);
    }

    final List<String> completed =
        preferences.getStringList(_completedKey) ??
            <String>[];

    final List<String> correct =
        preferences.getStringList(_correctKey) ??
            <String>[];

    final bool xpAwarded =
        preferences.getBool(_xpAwardedKey) ?? false;

    final int streak =
        preferences.getInt(_streakKey) ?? 0;

    return DailyChallengeState(
      completedIds: completed.toSet(),
      correctIds: correct.toSet(),
      xpAwarded: xpAwarded,
      streak: streak,
    );
  }

  static Future<bool> markAnswer({
    required String itemId,
    required bool correct,
  }) async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    await _ensureToday(preferences);

    final Set<String> completed =
    (preferences.getStringList(_completedKey) ??
        <String>[])
        .toSet();

    if (completed.contains(itemId)) {
      return false;
    }

    completed.add(itemId);

    await preferences.setStringList(
      _completedKey,
      completed.toList(),
    );

    if (correct) {
      final Set<String> correctAnswers =
      (preferences.getStringList(_correctKey) ??
          <String>[])
          .toSet();

      correctAnswers.add(itemId);

      await preferences.setStringList(
        _correctKey,
        correctAnswers.toList(),
      );
    }

    return true;
  }

  static Future<bool> completeChallenge() async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    await _ensureToday(preferences);

    final List<String> completed =
        preferences.getStringList(_completedKey) ??
            <String>[];

    if (completed.length < 10) {
      return false;
    }

    final bool alreadyAwarded =
        preferences.getBool(_xpAwardedKey) ?? false;

    if (alreadyAwarded) {
      return false;
    }

    await BasicSentenceXpService.addXp(50);

    await preferences.setBool(
      _xpAwardedKey,
      true,
    );

    await _updateStreak(preferences);

    return true;
  }

  static Future<void> _ensureToday(
      SharedPreferences preferences,
      ) async {
    final String today = _todayKey();

    final String? savedDate =
    preferences.getString(_dateKey);

    if (savedDate == today) {
      return;
    }

    await preferences.setString(
      _dateKey,
      today,
    );

    await preferences.remove(_completedKey);
    await preferences.remove(_correctKey);
    await preferences.remove(_xpAwardedKey);
  }

  static Future<void> _updateStreak(
      SharedPreferences preferences,
      ) async {
    final String today = _todayKey();

    final String? lastCompleted =
    preferences.getString(_lastCompletedKey);

    final int oldStreak =
        preferences.getInt(_streakKey) ?? 0;

    int newStreak = 1;

    if (lastCompleted == today) {
      newStreak = oldStreak;
    } else if (lastCompleted != null &&
        _isYesterday(lastCompleted, today)) {
      newStreak = oldStreak + 1;
    }

    await preferences.setInt(
      _streakKey,
      newStreak,
    );

    await preferences.setString(
      _lastCompletedKey,
      today,
    );
  }

  static bool _isYesterday(
      String previousDate,
      String currentDate,
      ) {
    final DateTime previous =
    DateTime.parse(previousDate);

    final DateTime current =
    DateTime.parse(currentDate);

    final Duration difference =
    current.difference(previous);

    return difference.inDays == 1;
  }
}