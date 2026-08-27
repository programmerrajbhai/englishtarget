class DailyChallengeItem {
  final String id;
  final DailyChallengeItemType type;
  final String bengali;
  final String english;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const DailyChallengeItem({
    required this.id,
    required this.type,
    required this.bengali,
    required this.english,
    this.options = const <String>[],
    this.correctAnswer = '',
    this.explanation = '',
  });

  List<String> get words {
    return english
        .trim()
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .toList(growable: false);
  }
}

enum DailyChallengeItemType {
  rule,
  basicSentence,
  questionMaking,
  speaking,
}