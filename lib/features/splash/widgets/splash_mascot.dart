import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SplashMascot extends StatelessWidget {
  final double size;

  const SplashMascot({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.mint,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withAlpha(35),
                width: 1.5,
              ),
            ),
          ),

          Container(
            width: size * 0.56,
            height: size * 0.56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.school_rounded,
              size: size * 0.34,
              color: AppColors.primary,
            ),
          ),

          Positioned(
            top: size * 0.06,
            right: size * 0.08,
            child: _BubbleIcon(
              size: size * 0.23,
              icon: Icons.mic_rounded,
              color: AppColors.purple,
            ),
          ),

          Positioned(
            left: size * 0.04,
            bottom: size * 0.12,
            child: _BubbleIcon(
              size: size * 0.23,
              icon: Icons.menu_book_rounded,
              color: AppColors.blue,
            ),
          ),

          Positioned(
            right: size * 0.03,
            bottom: size * 0.08,
            child: _BubbleIcon(
              size: size * 0.23,
              icon: Icons.track_changes_rounded,
              color: AppColors.amber,
            ),
          ),

          Positioned(
            left: size * 0.10,
            top: size * 0.09,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: size * 0.10,
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleIcon extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color color;

  const _BubbleIcon({
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
          color: color.withAlpha(55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.52,
      ),
    );
  }
}