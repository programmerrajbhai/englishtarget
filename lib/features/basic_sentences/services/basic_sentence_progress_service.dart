import 'package:shared_preferences/shared_preferences.dart';

import 'basic_sentence_xp_service.dart';

abstract final class BasicSentenceProgressService {
  static const String _keyPrefix =
      'basic_sentence_attended_';

  static const int practicesPerTopic = 25;

  static Future<Set<String>> getAttended(
      String topicId,
      ) async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final List<String> values =
        preferences.getStringList(
          '$_keyPrefix$topicId',
        ) ??
            <String>[];

    return values.toSet();
  }

  static Future<int> getCount(
      String topicId,
      ) async {
    final Set<String> attended =
    await getAttended(topicId);

    return attended.length;
  }

  static Future<void> markAttended({
    required String topicId,
    required String activityId,
  }) async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final String key = '$_keyPrefix$topicId';

    final Set<String> attended =
    (preferences.getStringList(key) ?? <String>[])
        .toSet();

    final bool isNewPractice =
    attended.add(activityId);

    if (!isNewPractice) {
      return;
    }

    await preferences.setStringList(
      key,
      attended.toList(),
    );

    // প্রতিটি নতুন practice-এর জন্য 1 XP
    await BasicSentenceXpService.addXp(1);

    // Topic-এর 25 practice complete হলে অতিরিক্ত 10 XP
    if (attended.length >= practicesPerTopic) {
      await BasicSentenceXpService.awardTopicCompletionXp(
        topicId,
      );
    }
  }

  static Future<void> clearTopic(
      String topicId,
      ) async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    await preferences.remove(
      '$_keyPrefix$topicId',
    );
  }
}