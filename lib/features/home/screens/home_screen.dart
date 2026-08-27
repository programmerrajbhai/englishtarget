import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/home_data.dart';
import '../widgets/category_card.dart';
import '../widgets/continue_learning_card.dart';
import '../widgets/learning_progress_card.dart';
import '../widgets/xp_balance_pill.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onBottomNavigationTap;

  const HomeScreen({
    super.key,
    this.onBottomNavigationTap,
  });

  void _openCategory(
      BuildContext context,
      String categoryTitle,
      ) {
    switch (categoryTitle) {
      case 'Learn Rules':
        Navigator.pushNamed(context, AppRoutes.rules);
        return;

      case 'Basic Sentences':
        Navigator.pushNamed(context, AppRoutes.basicSentences);
        return;

      case 'Question Making':
        Navigator.pushNamed(context, AppRoutes.questionMaking);
        return;

      case 'Daily Challenge':
        Navigator.pushNamed(context, AppRoutes.dailyChallenge);
        return;

      default:
        _showComingSoon(context, categoryTitle);
    }
  }

  void _openDailyChallenge(BuildContext context) {
    if (onBottomNavigationTap != null) {
      onBottomNavigationTap!.call(2);
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.dailyChallenge,
    );
  }

  void _showComingSoon(
      BuildContext context,
      String feature,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature screen coming soon'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navy,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (
              BuildContext context,
              BoxConstraints constraints,
              ) {
            final double width = constraints.maxWidth;

            final double horizontalPadding =
            (width * 0.055).clamp(18.0, 38.0).toDouble();

            final int crossAxisCount = width >= 900
                ? 4
                : width >= 600
                ? 3
                : 2;

            final double categoryRatio = width < 360
                ? 0.76
                : width >= 900
                ? 0.90
                : width >= 600
                ? 0.82
                : 0.79;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        17,
                        horizontalPadding,
                        30,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            const _ModernHomeHeader(),
                            const SizedBox(height: 23),
                            const LearningProgressCard(),
                            const SizedBox(height: 19),
                            const _QuickStatsRow(),
                            const SizedBox(height: 29),
                            const _SectionHeader(
                              title: 'Start learning',
                              subtitle:
                              'Choose a category to continue',
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                              (
                              BuildContext context,
                              int index,
                              ) {
                            final category =
                            HomeData.categories[index];

                            return CategoryCard(
                              category: category,
                              onTap: () {
                                _openCategory(
                                  context,
                                  category.title,
                                );
                              },
                            );
                          },
                          childCount: HomeData.categories.length,
                        ),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: categoryRatio,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        30,
                        horizontalPadding,
                        16,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            const _SectionHeader(
                              title: 'Continue learning',
                              subtitle:
                              'Pick up where you left off',
                            ),
                            const SizedBox(height: 14),
                            ContinueLearningCard(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.rules,
                                );
                              },
                            ),
                            const SizedBox(height: 28),
                            _DailyGoalCard(
                              onTap: () {
                                _openDailyChallenge(context);
                              },
                            ),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ModernHomeHeader extends StatelessWidget {
  const _ModernHomeHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ready to learn?',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 27,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              SizedBox(height: 7),
              Row(
                children: [
                  _OnlineDot(),
                  SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      'Build your English every day',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const XpBalancePill(),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.amber.withAlpha(28),
                AppColors.amber.withAlpha(12),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.amber.withAlpha(60),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.amber,
                size: 21,
              ),
              SizedBox(width: 4),
              Text(
                '7 days',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _QuickStat(
            icon: Icons.check_circle_rounded,
            value: '18',
            label: 'Lessons',
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 11),
        Expanded(
          child: _QuickStat(
            icon: Icons.emoji_events_rounded,
            value: '6',
            label: 'Badges',
            color: AppColors.amber,
          ),
        ),
        SizedBox(width: 11),
        Expanded(
          child: _QuickStat(
            icon: Icons.schedule_rounded,
            value: '12m',
            label: 'Today',
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final VoidCallback onTap;

  const _DailyGoalCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.amber.withAlpha(28),
                AppColors.amber.withAlpha(10),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.amber.withAlpha(55),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Challenge',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Complete 10 questions and earn 50 XP',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 39,
                height: 39,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}