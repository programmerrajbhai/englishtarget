import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/onboarding_item.dart';

class OnboardingIllustration extends StatelessWidget {
  final OnboardingItem item;
  final double size;

  const OnboardingIllustration({
    super.key,
    required this.item,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: item.accentColor.withAlpha(18),
              shape: BoxShape.circle,
            ),
          ),

          Container(
            width: size * 0.58,
            height: size * 0.58,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: item.accentColor.withAlpha(45),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: item.accentColor.withAlpha(28),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              item.mainIcon,
              size: size * 0.32,
              color: item.accentColor,
            ),
          ),

          Positioned(
            top: size * 0.05,
            right: size * 0.08,
            child: _SmallIcon(
              size: size * 0.22,
              icon: item.firstIcon,
              color: AppColors.primary,
            ),
          ),

          Positioned(
            left: size * 0.02,
            bottom: size * 0.14,
            child: _SmallIcon(
              size: size * 0.22,
              icon: item.secondIcon,
              color: AppColors.blue,
            ),
          ),

          Positioned(
            right: size * 0.03,
            bottom: size * 0.08,
            child: _SmallIcon(
              size: size * 0.22,
              icon: item.thirdIcon,
              color: AppColors.amber,
            ),
          ),

          Positioned(
            top: size * 0.12,
            left: size * 0.12,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: size * 0.10,
              color: item.accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallIcon extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color color;

  const _SmallIcon({
    required this.size,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withAlpha(45),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size * 0.50,
        color: color,
      ),
    );
  }
}