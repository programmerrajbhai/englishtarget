import 'dart:math';

import '../models/basic_sentence.dart';
import '../models/basic_sentence_activity.dart';
import '../models/basic_sentence_topic.dart';

abstract final class BasicSentenceFunnel {
  static const int learnCount = 10;
  static const int buildCount = 10;
  static const int speakCount = 5;

  static List<BasicSentenceActivity> createSession(
      BasicSentenceTopic topic,
      ) {
    final Random random = Random();

    final List<BasicSentenceActivity> activities =
    <BasicSentenceActivity>[
      ..._createActivities(
        topic.learnSentences,
        BasicSentenceActivityType.learn,
        learnCount,
        random,
      ),
      ..._createActivities(
        topic.buildSentences,
        BasicSentenceActivityType.build,
        buildCount,
        random,
      ),
      ..._createActivities(
        topic.speakSentences,
        BasicSentenceActivityType.speak,
        speakCount,
        random,
      ),
    ];

    activities.shuffle(random);

    return activities;
  }

  static List<BasicSentenceActivity> _createActivities(
      List<BasicSentence> source,
      BasicSentenceActivityType type,
      int count,
      Random random,
      ) {
    final List<BasicSentence> sentences =
    List<BasicSentence>.from(source);

    sentences.shuffle(random);

    return sentences
        .take(count)
        .map(
          (BasicSentence sentence) => BasicSentenceActivity(
        id: '${type.name}_${sentence.id}',
        type: type,
        sentence: sentence,
      ),
    )
        .toList(growable: false);
  }
}