import 'package:flutter/material.dart';

class LearningCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;

  const LearningCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.progress,
  });
}