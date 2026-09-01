import 'dart:math';

import '../models/basic_sentence.dart';
import '../models/basic_sentence_activity.dart';
import '../models/basic_sentence_topic.dart';

abstract final class BasicSentenceFunnel {
  static const int learnCount = 5;
  static const int mcqCount = 10;
  static const int buildCount = 6;
  static const int speakCount = 4;

  static List<BasicSentenceActivity> createSession(
      BasicSentenceTopic topic,
      ) {
    final Random random = Random();

    // টপিকের সবগুলো বাক্য একসাথে করে শাফেল করা হচ্ছে যেন কোনো বাক্য রিপিট না হয়
    final List<BasicSentence> allSentences = <BasicSentence>[
      ...topic.learnSentences,
      ...topic.buildSentences,
      ...topic.speakSentences,
    ]..shuffle(random);

    final List<BasicSentenceActivity> activities = <BasicSentenceActivity>[];
    int currentIndex = 0;

    // Learn Activities (5)
    for (int i = 0; i < learnCount && currentIndex < allSentences.length; i++, currentIndex++) {
      activities.add(BasicSentenceActivity(
        id: 'learn_${allSentences[currentIndex].id}',
        type: BasicSentenceActivityType.learn,
        sentence: allSentences[currentIndex],
      ));
    }

    // MCQ Activities (10)
    for (int i = 0; i < mcqCount && currentIndex < allSentences.length; i++, currentIndex++) {
      activities.add(BasicSentenceActivity(
        id: 'mcq_${allSentences[currentIndex].id}',
        type: BasicSentenceActivityType.mcq,
        sentence: allSentences[currentIndex],
      ));
    }

    // Build Activities (6)
    for (int i = 0; i < buildCount && currentIndex < allSentences.length; i++, currentIndex++) {
      activities.add(BasicSentenceActivity(
        id: 'build_${allSentences[currentIndex].id}',
        type: BasicSentenceActivityType.build,
        sentence: allSentences[currentIndex],
      ));
    }

    // Speak Activities (4)
    for (int i = 0; i < speakCount && currentIndex < allSentences.length; i++, currentIndex++) {
      activities.add(BasicSentenceActivity(
        id: 'speak_${allSentences[currentIndex].id}',
        type: BasicSentenceActivityType.speak,
        sentence: allSentences[currentIndex],
      ));
    }

    // পুরো সেশনটিকে আবার শাফেল করা হচ্ছে যেন সব মিক্সড অবস্থায় আসে
    activities.shuffle(random);

    return activities;
  }
}