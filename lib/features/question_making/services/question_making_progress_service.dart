import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../basic_sentences/services/basic_sentence_xp_service.dart';

abstract final class QuestionMakingProgressService {
  static const String _keyPrefix =
      'question_making_attended_';

  static const int practicesPerTopic = 25;

  static Future<Set<String>> getAttended(
      String topicId,
      ) async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final List<String> saved =
        preferences.getStringList(
          '$_keyPrefix$topicId',
        ) ??
            <String>[];

    return saved.toSet();
  }

  static Future<int> getCount(
      String topicId,
      ) async {
    final Set<String> attended =
    await getAttended(topicId);

    return attended.length;
  }

  static Future<int> markAttended({
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
      return 0;
    }

    await preferences.setStringList(
      key,
      attended.toList(),
    );

    int earnedXp = 1;

    await BasicSentenceXpService.addXp(1);

    if (attended.length >= practicesPerTopic) {
      final bool bonusAdded =
      await BasicSentenceXpService
          .awardTopicCompletionXp(
        'question_making_$topicId',
      );

      if (bonusAdded) {
        earnedXp += 10;
      }
    }

    return earnedXp;
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