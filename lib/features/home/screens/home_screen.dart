import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/home_data.dart';
import '../models/learning_category.dart';
import '../services/home_dashboard_service.dart';
import '../widgets/category_card.dart';
import '../widgets/xp_balance_pill.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onBottomNavigationTap;

  const HomeScreen({
    super.key,
    this.onBottomNavigationTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeDashboardData? _dashboard;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final HomeDashboardData data =
      await HomeDashboardService.load();

      if (!mounted) {
        return;
      }

      setState(() {
        _dashboard = data;
        _loading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _errorMessage =
        'Home data load করা যায়নি। আবার চেষ্টা করুন।';
      });
    }
  }

  Future<void> _openRoute(String route) async {
    await Navigator.pushNamed(
      context,
      route,
    );

    if (mounted) {
      await _loadDashboard();
    }
  }

  void _openCategory(String title) {
    switch (title) {
      case 'Learn Rules':
        _openRoute(AppRoutes.rules);
        return;

      case 'Basic Sentences':
        _openRoute(AppRoutes.basicSentences);
        return;

      case 'Question Making':
        _openRoute(AppRoutes.questionMaking);
        return;

      case 'Daily Challenge':
        _openDailyChallenge();
        return;
    }
  }

  void _openDailyChallenge() {
    if (widget.onBottomNavigationTap != null) {
      widget.onBottomNavigationTap!.call(2);
      return;
    }

    _openRoute(AppRoutes.dailyChallenge);
  }

  List<LearningCategory> _categories(
      HomeDashboardData data,
      ) {
    return HomeData.categories.map(
          (LearningCategory category) {
        return LearningCategory(
          title: category.title,
          subtitle: category.subtitle,
          icon: category.icon,
          color: category.color,
          progress:
          data.categoryProgress[category.title] ?? 0,
        );
      },
    ).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _dashboard == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_dashboard == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: AppColors.error,
                  size: 54,
                ),
                const SizedBox(height: 14),
                Text(
                  _errorMessage ?? 'Something went wrong',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadDashboard,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final HomeDashboardData data = _dashboard!;
    final List<LearningCategory> categories =
    _categories(data);

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
            (width * 0.055)
                .clamp(18.0, 38.0)
                .toDouble();

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
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadDashboard,
                  child: CustomScrollView(
                    physics:
                    const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          17,
                          horizontalPadding,
                          30,
                        ),
                        sliver: SliverList(
                          delegate:
                          SliverChildListDelegate(
                            [
                              _ModernHomeHeader(
                                streak: data.dailyStreak,
                              ),
                              const SizedBox(height: 23),
                              _LearningProgressCard(
                                data: data,
                              ),
                              const SizedBox(height: 19),
                              _QuickStatsRow(
                                data: data,
                              ),
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
                          delegate:
                          SliverChildBuilderDelegate(
                                (
                                BuildContext context,
                                int index,
                                ) {
                              final LearningCategory category =
                              categories[index];

                              return CategoryCard(
                                category: category,
                                onTap: () {
                                  _openCategory(
                                    category.title,
                                  );
                                },
                              );
                            },
                            childCount: categories.length,
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
                          26,
                        ),
                        sliver: SliverList(
                          delegate:
                          SliverChildListDelegate(
                            [
                              const _SectionHeader(
                                title: 'Continue learning',
                                subtitle:
                                'Pick up where you left off',
                              ),
                              const SizedBox(height: 14),
                              _ContinueLearningCard(
                                item: data.resumeItem,
                                onTap: () {
                                  _openRoute(
                                    data.resumeItem.route,
                                  );
                                },
                              ),
                              const SizedBox(height: 28),
                              _DailyGoalCard(
                                completed:
                                data.dailyCompleted,
                                total: data.dailyTotal,
                                xpAwarded:
                                data.dailyXpAwarded,
                                onTap: _openDailyChallenge,
                              ),
                              const SizedBox(height: 25),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
  final int streak;

  const _ModernHomeHeader({
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(width: 12),
            const _SettingsButton(),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: XpBalancePill(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StreakPill(streak: streak),
            ),
          ],
        ),
      ],
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int streak;

  const _StreakPill({
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.amber.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.amber.withAlpha(70),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.amber.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: AppColors.amber,
              size: 18,
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              '$streak day streak',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
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

class _LearningProgressCard extends StatelessWidget {
  final HomeDashboardData data;

  const _LearningProgressCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final int percentage =
    (data.levelProgress * 100).round();

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
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Your learning journey',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(32),
                        borderRadius:
                        BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Level ${data.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  '${data.completedLessons} learning activities completed',
                  style: TextStyle(
                    color: Colors.white.withAlpha(205),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 23),
                Row(
                  children: [
                    SizedBox(
                      width: 61,
                      height: 61,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: data.levelProgress,
                            strokeWidth: 6,
                            backgroundColor:
                            Colors.white.withAlpha(45),
                            valueColor:
                            const AlwaysStoppedAnimation<
                                Color>(
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
                    ),
                    const SizedBox(width: 17),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${data.xp} XP',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$percentage%',
                                style: const TextStyle(
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
                              value: data.levelProgress,
                              minHeight: 8,
                              backgroundColor:
                              Colors.white.withAlpha(50),
                              valueColor:
                              const AlwaysStoppedAnimation<
                                  Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${data.xpToNextLevel} XP until Level ${data.level + 1}',
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

class _QuickStatsRow extends StatelessWidget {
  final HomeDashboardData data;

  const _QuickStatsRow({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStat(
            icon: Icons.check_circle_rounded,
            value: '${data.completedLessons}',
            label: 'Lessons',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _QuickStat(
            icon: Icons.emoji_events_rounded,
            value: '${data.completedBadges}',
            label: 'Badges',
            color: AppColors.amber,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: _QuickStat(
            icon: Icons.today_rounded,
            value: '${data.todayPractices}',
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withAlpha(8),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 5,
          height: 45,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
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
          ),
        ),
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  final HomeResumeItem item;
  final VoidCallback onTap;

  const _ContinueLearningCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int percentage =
    (item.progress * 100).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: item.color.withAlpha(55),
            ),
            boxShadow: [
              BoxShadow(
                color: item.color.withAlpha(15),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  width: 67,
                  height: 77,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        item.color,
                        item.color.withAlpha(190),
                      ],
                    ),
                    borderRadius:
                    BorderRadius.circular(19),
                  ),
                  child: Icon(
                    item.icon,
                    color: Colors.white,
                    size: 33,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'CONTINUE LEARNING',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              color: item.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(30),
                        child: LinearProgressIndicator(
                          value: item.progress,
                          minHeight: 7,
                          backgroundColor:
                          item.color.withAlpha(25),
                          valueColor:
                          AlwaysStoppedAnimation<Color>(
                            item.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 13),
                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: item.color.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: item.color,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  final int completed;
  final int total;
  final bool xpAwarded;
  final VoidCallback onTap;

  const _DailyGoalCard({
    required this.completed,
    required this.total,
    required this.xpAwarded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int safeTotal = total <= 0 ? 10 : total;
    final double progress =
    (completed / safeTotal)
        .clamp(0.0, 1.0)
        .toDouble();
    final Color accent =
    xpAwarded ? AppColors.primary : AppColors.amber;

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
                accent.withAlpha(30),
                accent.withAlpha(9),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: accent.withAlpha(65),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Challenge',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      xpAwarded
                          ? 'Challenge completed • 50 XP earned'
                          : '$completed/$safeTotal completed • Earn 50 XP',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius:
                      BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: accent.withAlpha(28),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          accent,
                        ),
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
                child: Icon(
                  xpAwarded
                      ? Icons.check_rounded
                      : Icons.arrow_forward_rounded,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Settings',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.settings,
            );
          },
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.settings_outlined,
              color: AppColors.navy,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
