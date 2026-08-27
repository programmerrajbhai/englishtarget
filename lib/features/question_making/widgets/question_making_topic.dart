import 'package:flutter/material.dart';

import 'question_making_item.dart';

class QuestionMakingTopic {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<QuestionMakingItem> questions;

  const QuestionMakingTopic({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.questions,
  });

  int get totalPractices => 25;

  bool get hasEnoughQuestions =>
      questions.length >= totalPractices;
}