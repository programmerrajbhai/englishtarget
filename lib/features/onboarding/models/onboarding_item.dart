
import 'package:flutter/material.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData mainIcon;
  final IconData firstIcon;
  final IconData secondIcon;
  final IconData thirdIcon;
  final Color accentColor;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.mainIcon,
    required this.firstIcon,
    required this.secondIcon,
    required this.thirdIcon,
    required this.accentColor,
  });
}