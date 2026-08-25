import 'package:flutter/material.dart';

enum RuleLevel {
  beginner,
  elementary,
  preIntermediate,
}

class RuleItem {
  final int serial;
  final String id;
  final String title;
  final String shortMeaning;
  final String explanation;
  final String structure;
  final RuleLevel level;
  final String category;
  final IconData icon;
  final Color color;
  final int totalLessons;
  final double progress;

  const RuleItem({
    required this.serial,
    required this.id,
    required this.title,
    required this.shortMeaning,
    required this.explanation,
    required this.structure,
    required this.level,
    required this.category,
    required this.icon,
    required this.color,
    required this.totalLessons,
    required this.progress,
  });

  String get banglaDescription => shortMeaning;

  bool get isStarted => progress > 0;

  bool get isCompleted => progress >= 1;

  int get progressPercentage {
    return (progress.clamp(0.0, 1.0) * 100).round();
  }

  String get levelLabel {
    switch (level) {
      case RuleLevel.beginner:
        return 'Beginner';
      case RuleLevel.elementary:
        return 'Elementary';
      case RuleLevel.preIntermediate:
        return 'Pre-Intermediate';
    }
  }

  RuleItem copyWith({
    int? serial,
    String? id,
    String? title,
    String? shortMeaning,
    String? explanation,
    String? structure,
    RuleLevel? level,
    String? category,
    IconData? icon,
    Color? color,
    int? totalLessons,
    double? progress,
  }) {
    return RuleItem(
      serial: serial ?? this.serial,
      id: id ?? this.id,
      title: title ?? this.title,
      shortMeaning: shortMeaning ?? this.shortMeaning,
      explanation: explanation ?? this.explanation,
      structure: structure ?? this.structure,
      level: level ?? this.level,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      totalLessons: totalLessons ?? this.totalLessons,
      progress: progress ?? this.progress,
    );
  }
}