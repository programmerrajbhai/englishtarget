import 'package:flutter/material.dart';

class BasicSentence {
  final String id;
  final String bengali;
  final String english;
  final String visualKey;
  final IconData icon;
  final Color color;

  const BasicSentence({
    required this.id,
    required this.bengali,
    required this.english,
    this.visualKey = 'default',
    this.icon = Icons.chat_bubble_rounded,
    this.color = Colors.blue,
  });

  List<String> get words {
    return english
        .replaceAll(RegExp(r'[.!?,]'), '')
        .split(RegExp(r'\s+'))
        .where((String word) => word.trim().isNotEmpty)
        .toList(growable: false);
  }
}