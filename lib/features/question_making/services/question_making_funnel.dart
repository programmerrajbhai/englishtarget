import 'dart:math';

import '../widgets/question_making_activity.dart';
import '../widgets/question_making_item.dart';
import '../widgets/question_making_topic.dart';

abstract final class QuestionMakingFunnel {
  // নতুন রেশিও: ১২টি MCQ, ৫টি Build, ৪টি Speak, ৪টি Learn = ২৫টি
  static const int learnCount = 4;
  static const int mcqCount = 12;
  static const int buildCount = 5;
  static const int speakCount = 4;

  static List<QuestionMakingActivity> createSession(
      QuestionMakingTopic topic,
      ) {
    if (!topic.hasEnoughQuestions) {
      throw StateError(
        'Topic ${topic.id} must contain at least 25 questions.',
      );
    }

    final Random random = Random();

    // টপিকের সবগুলো প্রশ্নকে একসাথে করে শাফেল করা হচ্ছে
    final List<QuestionMakingItem> allQuestions =
    List<QuestionMakingItem>.from(topic.questions)..shuffle(random);

    final List<QuestionMakingActivity> activities = <QuestionMakingActivity>[];
    int currentIndex = 0;

    // Learn Activities (4)
    activities.addAll(
      _createActivities(
        topic: topic,
        questions: allQuestions.sublist(currentIndex, currentIndex += learnCount),
        type: QuestionMakingActivityType.learn,
      ),
    );

    // MCQ Activities (12)
    activities.addAll(
      _createActivities(
        topic: topic,
        questions: allQuestions.sublist(currentIndex, currentIndex += mcqCount),
        type: QuestionMakingActivityType.mcq,
      ),
    );

    // Build Activities (5)
    activities.addAll(
      _createActivities(
        topic: topic,
        questions: allQuestions.sublist(currentIndex, currentIndex += buildCount),
        type: QuestionMakingActivityType.build,
      ),
    );

    // Speak Activities (4)
    activities.addAll(
      _createActivities(
        topic: topic,
        questions: allQuestions.sublist(currentIndex, currentIndex += speakCount),
        type: QuestionMakingActivityType.speak,
      ),
    );

    // পুরো সেশনটিকে আবার শাফেল করা হচ্ছে যেন সব প্রশ্ন মিক্সড অবস্থায় আসে
    activities.shuffle(random);

    return activities;
  }

  static List<QuestionMakingActivity> _createActivities({
    required QuestionMakingTopic topic,
    required List<QuestionMakingItem> questions,
    required QuestionMakingActivityType type,
  }) {
    return questions.map(
          (QuestionMakingItem question) {
        return QuestionMakingActivity(
          id: '${topic.id}_${type.name}_${question.id}',
          type: type,
          question: question,
        );
      },
    ).toList(growable: false);
  }
}