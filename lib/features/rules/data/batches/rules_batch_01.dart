import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../models/rule_content.dart';

abstract final class Batch01Rules {
  static const List<RuleContent> rules = [
    _subjectPronouns,
  ];

  static const RuleContent _subjectPronouns = RuleContent(
    id: 'subject_pronouns',
    order: 1,
    title: 'Subject Pronouns',
    shortMeaning: 'I, You, He, She, It, We, They',
    usage:
    'Sentence-এ কে কাজ করছে বা কার সম্পর্কে বলা হচ্ছে, সেটি বোঝাতে Subject Pronoun ব্যবহার হয়।',
    formula: 'Subject Pronoun + Verb + Object',
    category: 'Foundation',
    level: RuleLevel.beginner,
    icon: Icons.person_rounded,
    color: AppColors.primary,
    keywords: [
      'I',
      'You',
      'He',
      'She',
      'It',
      'We',
      'They',
    ],
    examples: [
      RuleExample(
        bengali: 'আমি একজন ছাত্র।',
        english: 'I am a student.',
        type: RuleExampleType.simple,
      ),
      RuleExample(
        bengali: 'আমি ইংরেজি শিখি।',
        english: 'I learn English.',
        type: RuleExampleType.simple,
      ),
      RuleExample(
        bengali: 'তুমি আমার বন্ধু।',
        english: 'You are my friend.',
        type: RuleExampleType.simple,
      ),
      RuleExample(
        bengali: 'তুমি ভালো English বলো।',
        english: 'You speak English well.',
        type: RuleExampleType.positive,
      ),
      RuleExample(
        bengali: 'সে একজন ছেলে।',
        english: 'He is a boy.',
        type: RuleExampleType.simple,
      ),
      RuleExample(
        bengali: 'সে প্রতিদিন কাজ করে।',
        english: 'He works every day.',
        type: RuleExampleType.positive,
      ),
      RuleExample(
        bengali: 'সে একজন মেয়ে।',
        english: 'She is a girl.',
        type: RuleExampleType.simple,
      ),
      RuleExample(
        bengali: 'সে সুন্দর গান গায়।',
        english: 'She sings beautifully.',
        type: RuleExampleType.positive,
      ),
      RuleExample(
        bengali: 'এটি আমার ফোন।',
        english: 'It is my phone.',
        type: RuleExampleType.simple,
      ),
      RuleExample(
        bengali: 'এটি ভালো কাজ করে।',
        english: 'It works well.',
        type: RuleExampleType.positive,
      ),
      RuleExample(
        bengali: 'আমরা বাংলাদেশে থাকি।',
        english: 'We live in Bangladesh.',
        type: RuleExampleType.positive,
      ),
      RuleExample(
        bengali: 'আমরা একসঙ্গে English শিখি।',
        english: 'We learn English together.',
        type: RuleExampleType.positive,
      ),
      RuleExample(
        bengali: 'তারা আমার বন্ধু।',
        english: 'They are my friends.',
        type: RuleExampleType.simple,
      ),
      RuleExample(
        bengali: 'তারা মাঠে খেলে।',
        english: 'They play in the field.',
        type: RuleExampleType.positive,
      ),
      RuleExample(
        bengali: 'আমরা প্রস্তুত, কিন্তু তারা প্রস্তুত নয়।',
        english:
        'We are ready, but they are not ready.',
        type: RuleExampleType.negative,
      ),
    ],
    tests: [
      RuleTest(
        id: 'subject_pronouns_test_01',
        type: RuleTestType.multipleChoice,
        question:
        'Rahim is my brother. ___ is a student.',
        options: [
          'She',
          'He',
          'It',
        ],
        correctAnswer: 'He',
        explanation:
        'Rahim একজন ছেলে, তাই তার পরিবর্তে He ব্যবহার হবে।',
      ),
      RuleTest(
        id: 'subject_pronouns_test_02',
        type: RuleTestType.multipleChoice,
        question:
        'Mina is a teacher. ___ teaches English.',
        options: [
          'She',
          'He',
          'They',
        ],
        correctAnswer: 'She',
        explanation:
        'Mina একজন মেয়ে, তাই তার পরিবর্তে She ব্যবহার হবে।',
      ),
      RuleTest(
        id: 'subject_pronouns_test_03',
        type: RuleTestType.multipleChoice,
        question:
        'The phone is new. ___ works well.',
        options: [
          'He',
          'It',
          'We',
        ],
        correctAnswer: 'It',
        explanation:
        'Phone একটি বস্তু, তাই It ব্যবহার হবে।',
      ),
      RuleTest(
        id: 'subject_pronouns_test_04',
        type: RuleTestType.fillInTheBlank,
        question:
        'Karim and I are friends. ___ study together.',
        correctAnswer: 'We',
        explanation:
        'নিজেকে এবং অন্য একজনকে একসঙ্গে বোঝাতে We ব্যবহার হয়।',
      ),
      RuleTest(
        id: 'subject_pronouns_test_05',
        type: RuleTestType.fillInTheBlank,
        question:
        'Rina and Mina live here. ___ are sisters.',
        correctAnswer: 'They',
        explanation:
        'একাধিক ব্যক্তির পরিবর্তে They ব্যবহার হয়।',
      ),
      RuleTest(
        id: 'subject_pronouns_test_06',
        type: RuleTestType.translation,
        question: 'আমি English শিখি।',
        options: [
          'He learns English.',
          'I learn English.',
          'They learn English.',
        ],
        correctAnswer: 'I learn English.',
        explanation:
        'আমি বোঝাতে Subject হিসেবে I ব্যবহার হয়।',
      ),
      RuleTest(
        id: 'subject_pronouns_test_07',
        type: RuleTestType.wordArrangement,
        question: 'are / We / ready',
        correctAnswer: 'We are ready.',
        explanation:
        'সঠিক order হলো Subject + am/is/are + description।',
      ),
      RuleTest(
        id: 'subject_pronouns_test_08',
        type: RuleTestType.wordArrangement,
        question: 'football / They / play',
        correctAnswer: 'They play football.',
        explanation:
        'সঠিক order হলো Subject + Verb + Object।',
      ),
      RuleTest(
        id: 'subject_pronouns_test_09',
        type: RuleTestType.correction,
        question:
        'Rina is my sister. He is kind.',
        correctAnswer:
        'Rina is my sister. She is kind.',
        explanation:
        'Rina একজন মেয়ে, তাই He-এর পরিবর্তে She হবে।',
      ),
      RuleTest(
        id: 'subject_pronouns_test_10',
        type: RuleTestType.translation,
        question:
        'আমার বইটি নতুন। এটি সুন্দর।',
        correctAnswer:
        'My book is new. It is beautiful.',
        explanation:
        'Book একটি বস্তু, তাই দ্বিতীয় sentence-এ It ব্যবহার হয়।',
      ),
    ],
    speakingTests: [
      SpeakingTest(
        id: 'subject_pronouns_speaking_01',
        instruction:
        'বলুন: আমি একজন developer।',
        expectedAnswer:
        'I am a developer.',
        acceptedAnswers: [
          'I am a developer',
          'I am a developer.',
        ],
        visualIcon: Icons.code_rounded,
        visualColor: AppColors.primary,
      ),
      SpeakingTest(
        id: 'subject_pronouns_speaking_02',
        instruction:
        'বলুন: সে প্রতিদিন কাজ করে।',
        expectedAnswer:
        'He works every day.',
        acceptedAnswers: [
          'He works every day',
          'He works every day.',
        ],
        visualIcon: Icons.work_rounded,
        visualColor: AppColors.blue,
      ),
      SpeakingTest(
        id: 'subject_pronouns_speaking_03',
        instruction:
        'একজন মেয়েকে দেখে বলুন: সে একজন ছাত্রী।',
        expectedAnswer:
        'She is a student.',
        acceptedAnswers: [
          'She is a student',
          'She is a student.',
        ],
        visualIcon: Icons.school_rounded,
        visualColor: AppColors.purple,
      ),
      SpeakingTest(
        id: 'subject_pronouns_speaking_04',
        instruction:
        'Question: Who are they?',
        expectedAnswer:
        'They are my friends.',
        acceptedAnswers: [
          'They are my friends',
          'They are my friends.',
        ],
        visualIcon: Icons.groups_rounded,
        visualColor: AppColors.amber,
      ),
      SpeakingTest(
        id: 'subject_pronouns_speaking_05',
        instruction:
        'বলুন: আমরা একসঙ্গে English শিখি।',
        expectedAnswer:
        'We learn English together.',
        acceptedAnswers: [
          'We learn English together',
          'We learn English together.',
        ],
        visualIcon: Icons.menu_book_rounded,
        visualColor: AppColors.primary,
      ),
    ],
  );
}