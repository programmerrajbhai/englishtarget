import 'package:flutter/material.dart';

class QuestionMakingItem {
  final String id;
  final String bengali;
  final String english;
  final String explanation;
  final String visualKey;
  final IconData icon;
  final Color color;

  const QuestionMakingItem({
    required this.id,
    required this.bengali,
    required this.english,
    required this.explanation,
    this.visualKey = 'question',
    this.icon = Icons.help_outline_rounded,
    this.color = Colors.green,
  });

  List<String> get words {
    return english
        .trim()
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .toList(growable: false);
  }
}