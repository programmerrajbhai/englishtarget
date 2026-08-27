import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'learning_category.dart';

abstract final class HomeData {
  static const List<LearningCategory> categories =
  <LearningCategory>[
    LearningCategory(
      title: 'Learn Rules',
      subtitle: 'নিয়ম বুঝে শিখুন',
      icon: Icons.menu_book_rounded,
      color: AppColors.primary,
      progress: 0.45,
    ),
    LearningCategory(
      title: 'Basic Sentences',
      subtitle: 'প্রয়োজনীয় বাক্য শিখুন',
      icon: Icons.chat_bubble_rounded,
      color: AppColors.blue,
      progress: 0.30,
    ),
    LearningCategory(
      title: 'Question Making',
      subtitle: 'সঠিক প্রশ্ন তৈরি করুন',
      icon: Icons.quiz_rounded,
      color: AppColors.purple,
      progress: 0.0,
    ),
    LearningCategory(
      title: 'Daily Challenge',
      subtitle: 'আজকের ১০টি প্রশ্ন',
      icon: Icons.emoji_events_rounded,
      color: AppColors.amber,
      progress: 0.0,
    ),
  ];
}