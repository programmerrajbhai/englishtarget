import 'package:flutter/material.dart';

enum RuleLevel {
  beginner,
  basic,
  speaking,
}

enum RuleExampleType {
  simple,
  positive,
  negative,
  question,
  conversation,
}

enum RuleTestType {
  multipleChoice,
  fillInTheBlank,
  translation,
  wordArrangement,
  correction,
}

class RuleExample {
  final String bengali;
  final String english;
  final RuleExampleType type;

  // প্রতিটি sentence-এর visual identifier
  final String visualKey;

  const RuleExample({
    required this.bengali,
    required this.english,
    required this.type,
    this.visualKey = 'default',
  });
}

class RuleTest {
  final String id;
  final RuleTestType type;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  const RuleTest({
    required this.id,
    required this.type,
    required this.question,
    this.options = const [],
    required this.correctAnswer,
    required this.explanation,
  });
}

class SpeakingTest {
  final String id;
  final String instruction;
  final String expectedAnswer;
  final List<String> acceptedAnswers;
  final IconData visualIcon;
  final Color visualColor;

  const SpeakingTest({
    required this.id,
    required this.instruction,
    required this.expectedAnswer,
    this.acceptedAnswers = const [],
    this.visualIcon = Icons.mic_rounded,
    this.visualColor = Colors.green,
  });
}

class RuleContent {
  final String id;
  final int order;
  final String title;
  final String shortMeaning;
  final String usage;
  final String formula;
  final String category;
  final RuleLevel level;
  final IconData icon;
  final Color color;
  final List<String> keywords;
  final List<RuleExample> examples;
  final List<RuleTest> tests;
  final List<SpeakingTest> speakingTests;

  const RuleContent({
    required this.id,
    required this.order,
    required this.title,
    required this.shortMeaning,
    required this.usage,
    required this.formula,
    required this.category,
    required this.level,
    required this.icon,
    required this.color,
    this.keywords = const [],
    required this.examples,
    required this.tests,
    required this.speakingTests,
  });

  bool get isContentComplete {
    return examples.length == 15 &&
        tests.length == 10 &&
        speakingTests.length == 5;
  }
}