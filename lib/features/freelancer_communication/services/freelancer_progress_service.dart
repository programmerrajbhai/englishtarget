import 'package:shared_preferences/shared_preferences.dart';

abstract final class FreelancerProgressService {
  static const String _completedKey = 'freelancer_completed_lessons_v1';
  static const String _scorePrefix = 'freelancer_best_score_v1_';

  static Future<Set<int>> completedLessons() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> values =
        preferences.getStringList(_completedKey) ?? <String>[];
    return values.map(int.tryParse).whereType<int>().toSet();
  }

  static Future<void> completeLesson(int lessonId, int score) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final Set<int> completed =
        (preferences.getStringList(_completedKey) ?? <String>[])
            .map(int.tryParse)
            .whereType<int>()
            .toSet()
          ..add(lessonId);

    await preferences.setStringList(
      _completedKey,
      completed.map((int id) => id.toString()).toList()..sort(),
    );

    final int oldScore = preferences.getInt('$_scorePrefix$lessonId') ?? 0;
    if (score > oldScore) {
      await preferences.setInt('$_scorePrefix$lessonId', score);
    }
  }

  static Future<int> bestScore(int lessonId) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt('$_scorePrefix$lessonId') ?? 0;
  }
}
