class RuleProgress {
  final bool learnCompleted;
  final bool testCompleted;
  final bool speakingCompleted;
  final int testCorrectAnswers;
  final int speakingCorrectAnswers;

  const RuleProgress({
    this.learnCompleted = false,
    this.testCompleted = false,
    this.speakingCompleted = false,
    this.testCorrectAnswers = 0,
    this.speakingCorrectAnswers = 0,
  });

  int get completedSteps {
    int count = 0;

    if (learnCompleted) count++;
    if (testCompleted) count++;
    if (speakingCompleted) count++;

    return count;
  }

  double get progress {
    return completedSteps / 3;
  }

  int get percentage {
    return (progress * 100).round();
  }

  bool get isStarted {
    return completedSteps > 0;
  }

  bool get isCompleted {
    return learnCompleted &&
        testCompleted &&
        speakingCompleted;
  }

  RuleProgress copyWith({
    bool? learnCompleted,
    bool? testCompleted,
    bool? speakingCompleted,
    int? testCorrectAnswers,
    int? speakingCorrectAnswers,
  }) {
    return RuleProgress(
      learnCompleted:
      learnCompleted ?? this.learnCompleted,
      testCompleted:
      testCompleted ?? this.testCompleted,
      speakingCompleted:
      speakingCompleted ?? this.speakingCompleted,
      testCorrectAnswers:
      testCorrectAnswers ?? this.testCorrectAnswers,
      speakingCorrectAnswers:
      speakingCorrectAnswers ??
          this.speakingCorrectAnswers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'learnCompleted': learnCompleted,
      'testCompleted': testCompleted,
      'speakingCompleted': speakingCompleted,
      'testCorrectAnswers': testCorrectAnswers,
      'speakingCorrectAnswers':
      speakingCorrectAnswers,
    };
  }

  factory RuleProgress.fromJson(
      Map<String, dynamic> json,
      ) {
    return RuleProgress(
      learnCompleted:
      json['learnCompleted'] as bool? ?? false,
      testCompleted:
      json['testCompleted'] as bool? ?? false,
      speakingCompleted:
      json['speakingCompleted'] as bool? ?? false,
      testCorrectAnswers:
      json['testCorrectAnswers'] as int? ?? 0,
      speakingCorrectAnswers:
      json['speakingCorrectAnswers'] as int? ?? 0,
    );
  }
}