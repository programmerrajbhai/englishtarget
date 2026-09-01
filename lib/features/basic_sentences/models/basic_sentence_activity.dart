import 'basic_sentence.dart';

enum BasicSentenceActivityType {
  learn,
  mcq, // MCQ type added here
  build,
  speak,
}

class BasicSentenceActivity {
  final String id;
  final BasicSentenceActivityType type;
  final BasicSentence sentence;

  const BasicSentenceActivity({
    required this.id,
    required this.type,
    required this.sentence,
  });
}