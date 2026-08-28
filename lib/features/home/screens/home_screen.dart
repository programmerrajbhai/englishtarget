import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/home_data.dart';
import '../models/learning_category.dart';
import '../services/home_dashboard_service.dart';
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
      return _HomeErrorView(
        message:
        _errorMessage ?? 'Something went wrong',
        onRetry: _loadDashboard,
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
            (width * 0.045)
                .clamp(16.0, 34.0)
                .toDouble();

            final int categoryColumns =
            width >= 900 ? 4 : 2;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1080,
                ),
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadDashboard,
                  child: ListView(
                    physics:
                    const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      14,
                      horizontalPadding,
                      34,
                    ),
                    children: <Widget>[
                      _BrandHeader(
                        streak: data.dailyStreak,
                      ),
                      const SizedBox(height: 20),

                      _JourneyCard(data: data),
                      const SizedBox(height: 15),

                      _QuickStats(data: data),
                      const SizedBox(height: 28),

                      const _SectionTitle(
                        eyebrow: 'CHOOSE YOUR PATH',
                        title: 'Start learning',
                        subtitle:
                        'Small lessons. Real English. Daily progress.',
                        icon: Icons.explore_rounded,
                      ),
                      const SizedBox(height: 15),

                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                          categoryColumns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 196,
                        ),
                        itemBuilder: (
                            BuildContext context,
                            int index,
                            ) {
                          final LearningCategory category =
                          categories[index];

                          return _LearningCategoryCard(
                            category: category,
                            onTap: () {
                              _openCategory(
                                category.title,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 29),

                      const _SectionTitle(
                        eyebrow: 'KEEP GOING',
                        title: 'Continue learning',
                        subtitle:
                        'Continue exactly where you stopped.',
                        icon: Icons.auto_awesome_rounded,
                      ),
                      const SizedBox(height: 15),

                      _ContinueCard(
                        item: data.resumeItem,
                        onTap: () {
                          _openRoute(
                            data.resumeItem.route,
                          );
                        },
                      ),
                      const SizedBox(height: 17),

                      _DailyChallengeCard(
                        completed:
                        data.dailyCompleted,
                        total: data.dailyTotal,
                        xpAwarded:
                        data.dailyXpAwarded,
                        onTap: _openDailyChallenge,
                      ),
                      const SizedBox(height: 12),
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

class _BrandHeader extends StatelessWidget {
  final int streak;

  const _BrandHeader({
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 62,
              height: 62,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(19),
                border: Border.all(
                  color:
                  AppColors.primary.withAlpha(50),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color:
                    AppColors.primary.withAlpha(28),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(15),
                child: Image.asset(
                  'assets/branding/app_icon.png',
                  fit: BoxFit.cover,
                  filterQuality:
                  FilterQuality.high,
                  errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                      ) {
                    return Container(
                      color: AppColors.primary,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 31,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 13),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'WELCOME TO',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'English Target',
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 23,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.55,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Speak confidently, one lesson at a time.',
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                      AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 9),

            const _SettingsButton(),
          ],
        ),
        const SizedBox(height: 17),

        Row(
          children: <Widget>[
            const Expanded(
              child: XpBalancePill(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StreakPill(
                streak: streak,
              ),
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
      padding:
      const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.amber.withAlpha(23),
            AppColors.amber.withAlpha(8),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.amber.withAlpha(70),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: AppColors.amber.withAlpha(34),
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
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  final HomeDashboardData data;

  const _JourneyCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
    _safeProgress(data.levelProgress);
    final int percentage =
    (progress * 100).round();

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF14B87A),
            Color(0xFF079566),
            Color(0xFF047354),
          ],
          stops: <double>[0, 0.56, 1],
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color:
            AppColors.primary.withAlpha(45),
            blurRadius: 25,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            right: -54,
            top: -72,
            child: _DecorativeCircle(
              size: 175,
              opacity: 15,
            ),
          ),
          const Positioned(
            right: 45,
            bottom: -69,
            child: _DecorativeCircle(
              size: 135,
              opacity: 11,
            ),
          ),
          const Positioned(
            left: -45,
            bottom: -65,
            child: _DecorativeCircle(
              size: 125,
              opacity: 8,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color:
                        Colors.white.withAlpha(25),
                        borderRadius:
                        BorderRadius.circular(30),
                        border: Border.all(
                          color:
                          Colors.white.withAlpha(38),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.trending_up_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'YOUR JOURNEY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight:
                              FontWeight.w800,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color:
                        Colors.white.withAlpha(28),
                        borderRadius:
                        BorderRadius.circular(30),
                        border: Border.all(
                          color:
                          Colors.white.withAlpha(45),
                        ),
                      ),
                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.amber,
                            size: 17,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Level ${data.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),

                const Text(
                  'Build confident English',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  data.completedLessons == 0
                      ? 'Your first lesson is waiting for you.'
                      : '${data.completedLessons} learning activities completed.',
                  style: TextStyle(
                    color:
                    Colors.white.withAlpha(205),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),

                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 7,
                            strokeCap:
                            StrokeCap.round,
                            backgroundColor:
                            Colors.white.withAlpha(42),
                            valueColor:
                            const AlwaysStoppedAnimation<
                                Color>(
                              Colors.white,
                            ),
                          ),
                          Column(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                '$percentage%',
                                style:
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight:
                                  FontWeight.w900,
                                ),
                              ),
                              Text(
                                'LEVEL',
                                style: TextStyle(
                                  color: Colors.white
                                      .withAlpha(175),
                                  fontSize: 7.5,
                                  fontWeight:
                                  FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 17),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${data.xp}',
                                style:
                                const TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  height: 1,
                                  fontWeight:
                                  FontWeight.w900,
                                  letterSpacing: -0.7,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'XP earned',
                                style: TextStyle(
                                  color: Colors.white
                                      .withAlpha(195),
                                  fontSize: 11.5,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          ClipRRect(
                            borderRadius:
                            BorderRadius.circular(30),
                            child:
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor:
                              Colors.white.withAlpha(42),
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
                              color: Colors.white
                                  .withAlpha(190),
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w500,
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

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final int opacity;

  const _DecorativeCircle({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final HomeDashboardData data;

  const _QuickStats({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _QuickStatItem(
            icon: Icons.check_circle_rounded,
            value: '${data.completedLessons}',
            label: 'Lessons',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _QuickStatItem(
            icon: Icons.emoji_events_rounded,
            value: '${data.completedBadges}',
            label: 'Badges',
            color: AppColors.amber,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _QuickStatItem(
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

class _QuickStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67,
      padding:
      const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withAlpha(7),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 17,
            ),
          ),
          const SizedBox(width: 7),

          Flexible(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                    AppColors.textSecondary,
                    fontSize: 9.5,
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

class _SectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionTitle({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                AppColors.primary.withAlpha(27),
                AppColors.primary.withAlpha(10),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                eyebrow,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),

              Text(
                title,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.35,
                ),
              ),
              const SizedBox(height: 2),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
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

class _LearningCategoryCard
    extends StatelessWidget {
  final LearningCategory category;
  final VoidCallback onTap;

  const _LearningCategoryCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
    _safeProgress(category.progress);
    final int percentage =
    (progress * 100).round();

    final String action = progress >= 1
        ? 'Review'
        : progress > 0
        ? 'Continue'
        : 'Start';

    return Semantics(
      button: true,
      label: '${category.title}, $action',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(23),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  category.color.withAlpha(34),
                  category.color.withAlpha(12),
                  Colors.white,
                ],
                stops: const <double>[
                  0,
                  0.58,
                  1,
                ],
              ),
              borderRadius:
              BorderRadius.circular(23),
              border: Border.all(
                color:
                category.color.withAlpha(55),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color:
                  category.color.withAlpha(13),
                  blurRadius: 17,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: -27,
                  top: -31,
                  child: Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      color: category.color
                          .withAlpha(12),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient:
                              LinearGradient(
                                begin:
                                Alignment.topLeft,
                                end: Alignment
                                    .bottomRight,
                                colors: <Color>[
                                  category.color,
                                  category.color
                                      .withAlpha(190),
                                ],
                              ),
                              borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: category.color
                                      .withAlpha(35),
                                  blurRadius: 11,
                                  offset:
                                  const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              category.icon,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          const Spacer(),

                          Container(
                            width: 34,
                            height: 34,
                            decoration:
                            const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons
                                  .arrow_outward_rounded,
                              color: category.color,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      Text(
                        category.title,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 14.5,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.15,
                        ),
                      ),
                      const SizedBox(height: 5),

                      Text(
                        category.subtitle,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color:
                          AppColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                              child:
                              LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor:
                                Colors.white,
                                valueColor:
                                AlwaysStoppedAnimation<
                                    Color>(
                                  category.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          Text(
                            progress > 0
                                ? '$percentage%'
                                : action,
                            style: TextStyle(
                              color: category.color,
                              fontSize: 10,
                              fontWeight:
                              FontWeight.w900,
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
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final HomeResumeItem item;
  final VoidCallback onTap;

  const _ContinueCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
    _safeProgress(item.progress);
    final int percentage =
    (progress * 100).round();

    final String label = progress <= 0
        ? 'START HERE'
        : progress >= 1
        ? 'REVIEW AGAIN'
        : 'CONTINUE LEARNING';

    return Semantics(
      button: true,
      label: '$label ${item.title}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(24),
              border: Border.all(
                color: item.color.withAlpha(52),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: item.color.withAlpha(14),
                  blurRadius: 22,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 66,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        item.color,
                        item.color.withAlpha(185),
                      ],
                    ),
                    borderRadius:
                    BorderRadius.circular(19),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color:
                        item.color.withAlpha(30),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Icon(
                        item.icon,
                        color: Colors.white,
                        size: 31,
                      ),
                      const Positioned(
                        right: 8,
                        top: 8,
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.amber,
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: TextStyle(
                                color: item.color,
                                fontSize: 9.5,
                                fontWeight:
                                FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              color: item.color,
                              fontSize: 11.5,
                              fontWeight:
                              FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Text(
                        item.title,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color:
                          AppColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 11),

                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(30),
                        child:
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor:
                          item.color.withAlpha(22),
                          valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                            item.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 11),

                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color:
                    item.color.withAlpha(18),
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

class _DailyChallengeCard
    extends StatelessWidget {
  final int completed;
  final int total;
  final bool xpAwarded;
  final VoidCallback onTap;

  const _DailyChallengeCard({
    required this.completed,
    required this.total,
    required this.xpAwarded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int safeTotal =
    total <= 0 ? 10 : total;

    final double progress = _safeProgress(
      completed / safeTotal,
    );

    final Color accent = xpAwarded
        ? AppColors.primary
        : AppColors.amber;

    return Semantics(
      button: true,
      label: 'Open Daily Challenge',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
          BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  accent.withAlpha(31),
                  accent.withAlpha(9),
                  Colors.white,
                ],
              ),
              borderRadius:
              BorderRadius.circular(24),
              border: Border.all(
                color: accent.withAlpha(65),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        accent,
                        accent.withAlpha(190),
                      ],
                    ),
                    borderRadius:
                    BorderRadius.circular(18),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color:
                        accent.withAlpha(32),
                        blurRadius: 13,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    xpAwarded
                        ? Icons
                        .verified_rounded
                        : Icons
                        .emoji_events_rounded,
                    color: Colors.white,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              'Daily Challenge',
                              style: TextStyle(
                                color: AppColors.navy,
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                              accent.withAlpha(18),
                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: Text(
                              xpAwarded
                                  ? 'DONE'
                                  : '+50 XP',
                              style: TextStyle(
                                color: accent,
                                fontSize: 9.5,
                                fontWeight:
                                FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      Text(
                        xpAwarded
                            ? 'Completed today • Come back tomorrow'
                            : '$completed/$safeTotal completed • Keep your streak alive',
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: const TextStyle(
                          color:
                          AppColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(20),
                        child:
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor:
                          accent.withAlpha(23),
                          valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                            accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                Container(
                  width: 37,
                  height: 37,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    xpAwarded
                        ? Icons.check_rounded
                        : Icons
                        .arrow_forward_rounded,
                    color: accent,
                    size: 20,
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

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Settings',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.settings,
            );
          },
          child: Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.border,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color:
                  AppColors.navy.withAlpha(7),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: AppColors.navy,
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _HomeErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color:
                    AppColors.error.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.error,
                    size: 43,
                  ),
                ),
                const SizedBox(height: 17),

                const Text(
                  'Could not load Home',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color:
                    AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 19),

                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(
                    Icons.refresh_rounded,
                  ),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
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

double _safeProgress(double value) {
  return value.clamp(0.0, 1.0).toDouble();
}