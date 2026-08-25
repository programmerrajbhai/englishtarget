import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/rule_item.dart';
import '../models/rule_progress.dart';

class RuleCard extends StatelessWidget {
  final RuleItem rule;
  final RuleProgress progress;
  final bool isUnlocked;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const RuleCard({
    super.key,
    required this.rule,
    required this.progress,
    required this.isUnlocked,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isUnlocked
        ? Colors.white
        : const Color(0xFFF3F4F4);

    final contentOpacity = isUnlocked ? 1.0 : 0.52;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: progress.isCompleted
                  ? AppColors.primary.withAlpha(80)
                  : AppColors.border,
            ),
            boxShadow: isUnlocked
                ? [
              BoxShadow(
                color: AppColors.navy.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
                : null,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Opacity(
                  opacity: contentOpacity,
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: isUnlocked
                                  ? LinearGradient(
                                colors: [
                                  rule.color,
                                  rule.color.withAlpha(180),
                                ],
                              )
                                  : null,
                              color: isUnlocked
                                  ? null
                                  : AppColors.textSecondary,
                              borderRadius:
                              BorderRadius.circular(17),
                            ),
                            child: Icon(
                              rule.icon,
                              color: Colors.white,
                              size: 27,
                            ),
                          ),

                          const SizedBox(width: 13),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: rule.color.withAlpha(18),
                                        borderRadius:
                                        BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${rule.serial}',
                                        style: TextStyle(
                                          color: rule.color,
                                          fontSize: 10,
                                          fontWeight:
                                          FontWeight.w800,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 7),

                                    Expanded(
                                      child: Text(
                                        rule.title,
                                        maxLines: 1,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.navy,
                                          fontSize: 17,
                                          fontWeight:
                                          FontWeight.w800,
                                        ),
                                      ),
                                    ),

                                    if (isUnlocked)
                                      InkWell(
                                        onTap: onBookmark,
                                        borderRadius:
                                        BorderRadius.circular(30),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.all(4),
                                          child: Icon(
                                            isBookmarked
                                                ? Icons
                                                .bookmark_rounded
                                                : Icons
                                                .bookmark_border_rounded,
                                            color: isBookmarked
                                                ? AppColors.primary
                                                : AppColors
                                                .textSecondary,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 7),

                                Text(
                                  rule.shortMeaning,
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color:
                                    AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.4,
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  rule.levelLabel,
                                  style: TextStyle(
                                    color: rule.color,
                                    fontSize: 11.5,
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      if (isUnlocked)
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(30),
                                child:
                                LinearProgressIndicator(
                                  value: progress.progress,
                                  minHeight: 7,
                                  backgroundColor:
                                  rule.color.withAlpha(18),
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                    rule.color,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            _ProgressStatus(
                              progress: progress,
                              color: rule.color,
                            ),
                          ],
                        )
                      else
                        const Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                'Complete the previous rule to unlock',
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                  AppColors.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              if (!isUnlocked)
                const Positioned(
                  right: 14,
                  top: 14,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.lock_rounded,
                      color: AppColors.textSecondary,
                      size: 19,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressStatus extends StatelessWidget {
  final RuleProgress progress;
  final Color color;

  const _ProgressStatus({
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (progress.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: AppColors.mint,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 17,
            ),
            SizedBox(width: 4),
            Text(
              'Done',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        progress.isStarted
            ? '${progress.percentage}%'
            : 'Start',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}