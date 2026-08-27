import 'package:flutter/material.dart';

class BasicSentenceTopic {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int sentenceCount;
  final int completedSentences;

  const BasicSentenceTopic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.sentenceCount = 15,
    this.completedSentences = 0,
  });

  double get progress {
    if (sentenceCount <= 0) {
      return 0;
    }

    return (completedSentences / sentenceCount)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  bool get isCompleted {
    return completedSentences >= sentenceCount;
  }

  bool get isStarted {
    return completedSentences > 0 && !isCompleted;
  }
}