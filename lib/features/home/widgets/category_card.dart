import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/learning_category.dart';

class CategoryCard extends StatelessWidget {
  final LearningCategory category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (category.progress * 100).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.color.withAlpha(30),
                category.color.withAlpha(10),
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: category.color.withAlpha(45),
            ),
            boxShadow: [
              BoxShadow(
                color: category.color.withAlpha(18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -25,
                child: Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: category.color.withAlpha(12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(
                right: 13,
                top: 13,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(220),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: category.color.withAlpha(35),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_outward_rounded,
                    color: category.color,
                    size: 18,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            category.color,
                            category.color.withAlpha(190),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: category.color.withAlpha(50),
                            blurRadius: 13,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        category.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      category.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      category.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: category.progress,
                              minHeight: 6,
                              backgroundColor: Colors.white,
                              valueColor:
                              AlwaysStoppedAnimation<Color>(
                                category.color,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 9),

                        Text(
                          category.progress == 0
                              ? 'Start'
                              : '$percentage%',
                          style: TextStyle(
                            color: category.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}