import 'question_making_item.dart';

enum QuestionMakingActivityType {
  learn,
  mcq,
  build,
  speak,
}

class QuestionMakingActivity {
  final String id;
  final QuestionMakingActivityType type;
  final QuestionMakingItem question;

  const QuestionMakingActivity({
    required this.id,
    required this.type,
    required this.question,
  });
}