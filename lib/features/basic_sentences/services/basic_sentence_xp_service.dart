import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class BasicSentenceXpService {
  static const String _xpKey = 'basic_sentence_total_xp_v1';
  static const int _initialXp = 0;

  static final ValueNotifier<int> totalXp =
  ValueNotifier<int>(_initialXp);

  static Future<int> load() async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final int xp =
        preferences.getInt(_xpKey) ?? _initialXp;

    if (!preferences.containsKey(_xpKey)) {
      await preferences.setInt(_xpKey, _initialXp);
    }

    totalXp.value = xp;
    return xp;
  }

  static Future<int> addXp(int amount) async {
    if (amount <= 0) {
      return load();
    }

    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final int currentXp =
        preferences.getInt(_xpKey) ?? _initialXp;

    final int updatedXp = currentXp + amount;

    await preferences.setInt(_xpKey, updatedXp);

    totalXp.value = updatedXp;

    return updatedXp;
  }

  static Future<bool> awardTopicCompletionXp(
      String topicId,
      ) async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    const String key = 'basic_sentence_completed_topics_xp_v1';

    final List<String> completedTopics =
        preferences.getStringList(key) ?? <String>[];

    if (completedTopics.contains(topicId)) {
      return false;
    }

    completedTopics.add(topicId);

    await preferences.setStringList(
      key,
      completedTopics,
    );

    await addXp(10);

    return true;
  }
}