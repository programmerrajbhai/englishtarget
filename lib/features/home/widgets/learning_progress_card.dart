import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class LearningProgressCard extends StatelessWidget {
  const LearningProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(55),
            blurRadius: 26,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: 35,
            bottom: -55,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your learning journey',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    _LevelBadge(),
                  ],
                ),

                const SizedBox(height: 7),

                Text(
                  'Keep going! You’re making great progress.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(205),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 23),

                Row(
                  children: [
                    const _ProgressCircle(),

                    const SizedBox(width: 17),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                '740 XP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '68%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(30),
                            child: LinearProgressIndicator(
                              value: 0.68,
                              minHeight: 8,
                              backgroundColor:
                              Colors.white.withAlpha(50),
                              valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '260 XP until Level 4',
                            style: TextStyle(
                              color: Colors.white.withAlpha(190),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(32),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withAlpha(50),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            color: AppColors.amber,
            size: 18,
          ),
          SizedBox(width: 5),
          Text(
            'Level 3',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCircle extends StatelessWidget {
  const _ProgressCircle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 61,
      height: 61,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: 0.68,
            strokeWidth: 6,
            backgroundColor: Colors.white.withAlpha(45),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Colors.white,
            ),
          ),
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.amber,
            size: 24,
          ),
        ],
      ),
    );
  }
}