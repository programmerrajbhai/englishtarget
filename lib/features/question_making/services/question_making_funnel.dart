import 'dart:math';
import '../widgets/question_making_activity.dart';
import '../widgets/question_making_item.dart';
import '../widgets/question_making_topic.dart';

abstract final class QuestionMakingFunnel {
  static const int learnCount = 10;
  static const int buildCount = 10;
  static const int speakCount = 5;

  static List<QuestionMakingActivity> createSession(
      QuestionMakingTopic topic,
      ) {
    if (!topic.hasEnoughQuestions) {
      throw StateError(
        'Topic ${topic.id} must contain at least 25 questions.',
      );
    }

    final Random random = Random();

    final List<QuestionMakingItem> questions =
    List<QuestionMakingItem>.from(topic.questions)
      ..shuffle(random);

    final List<QuestionMakingActivity> activities =
    <QuestionMakingActivity>[
      ..._createActivities(
        topic: topic,
        questions: questions.sublist(0, learnCount),
        type: QuestionMakingActivityType.learn,
      ),
      ..._createActivities(
        topic: topic,
        questions: questions.sublist(
          learnCount,
          learnCount + buildCount,
        ),
        type: QuestionMakingActivityType.build,
      ),
      ..._createActivities(
        topic: topic,
        questions: questions.sublist(
          learnCount + buildCount,
          learnCount + buildCount + speakCount,
        ),
        type: QuestionMakingActivityType.speak,
      ),
    ];

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