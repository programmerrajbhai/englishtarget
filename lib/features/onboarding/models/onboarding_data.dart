import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'onboarding_item.dart';

abstract final class OnboardingData {
  static const List<OnboardingItem> items = [
    OnboardingItem(
      title: 'Learn English Step by Step',
      description:
      'সহজ নিয়ম ও বাংলা ব্যাখ্যার মাধ্যমে ধাপে ধাপে English শিখুন।',
      mainIcon: Icons.school_rounded,
      firstIcon: Icons.menu_book_rounded,
      secondIcon: Icons.translate_rounded,
      thirdIcon: Icons.lightbulb_rounded,
      accentColor: AppColors.primary,
    ),
    OnboardingItem(
      title: 'Practise Real-Life Sentences',
      description:
      'দৈনন্দিন প্রয়োজনীয় English sentence শুনুন, তৈরি করুন এবং practice করুন।',
      mainIcon: Icons.chat_bubble_rounded,
      firstIcon: Icons.hearing_rounded,
      secondIcon: Icons.edit_note_rounded,
      thirdIcon: Icons.record_voice_over_rounded,
      accentColor: AppColors.blue,
    ),
    OnboardingItem(
      title: 'Speak with Confidence',
      description:
      'Speaking practice, daily challenge ও instant feedback দিয়ে আত্মবিশ্বাস বাড়ান।',
      mainIcon: Icons.mic_rounded,
      firstIcon: Icons.graphic_eq_rounded,
      secondIcon: Icons.emoji_events_rounded,
      thirdIcon: Icons.local_fire_department_rounded,
      accentColor: AppColors.purple,
    ),
  ];
}