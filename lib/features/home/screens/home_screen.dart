import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../models/home_data.dart';
import '../models/learning_category.dart';
import '../services/home_dashboard_service.dart';

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
      final HomeDashboardData data = await HomeDashboardService.load();
      if (!mounted) return;

      setState(() {
        _dashboard = data;
        _loading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Home data load করা যায়নি। আবার চেষ্টা করুন।';
      });
    }
  }

  Future<void> _openRoute(String route) async {
    await Navigator.pushNamed(context, route);
    if (mounted) await _loadDashboard();
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

  List<LearningCategory> _categories(HomeDashboardData data) {
    return HomeData.categories.map((LearningCategory category) {
      return LearningCategory(
        title: category.title,
        subtitle: category.subtitle,
        icon: category.icon,
        color: category.color,
        progress: data.categoryProgress[category.title] ?? 0,
      );
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Premium off-white background
      body: Stack(
        children: [
          // Soft Ambient Background Glows
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(20),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withAlpha(15),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            bottom: false,
            top: false,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double width = constraints.maxWidth;
                final double horizontalPadding =
                (width * 0.045).clamp(16.0, 34.0).toDouble();
                final int categoryColumns = width >= 900 ? 4 : 2;

                if (_loading && _dashboard == null) {
                  return _HomeSkeletonLoader(padding: horizontalPadding);
                }

                if (_dashboard == null) {
                  return _HomeErrorView(
                    message: _errorMessage ?? 'Something went wrong',
                    onRetry: _loadDashboard,
                  );
                }

                final HomeDashboardData data = _dashboard!;
                final List<LearningCategory> categories = _categories(data);

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _loadDashboard,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          MediaQuery.paddingOf(context).top + 12,
                          horizontalPadding,
                          34 + MediaQuery.paddingOf(context).bottom,
                        ),
                        children: <Widget>[
                          // 1. ONE-LINE COMPACT TOP APP BAR
                          _AnimatedEntry(
                            delay: 0,
                            child: _TopNavBar(
                              xp: data.xp,
                              streak: data.dailyStreak,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2. SHORT & COMPACT HERO JOURNEY CARD
                          _AnimatedEntry(
                            delay: 1,
                            child: _HeroJourneyCard(
                              data: data,
                              onStartTap: () {
                                if (data.completedLessons == 0) {
                                  _openRoute(AppRoutes.rules);
                                } else {
                                  _openRoute(data.resumeItem.route);
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),


                          const SizedBox(height: 26),

                          // 4. START LEARNING SECTION
                          const _AnimatedEntry(
                            delay: 3,
                            child: _SectionTitle(
                              eyebrow: 'CHOOSE YOUR PATH',
                              title: 'Start learning',
                              subtitle:
                              'Small lessons. Real English. Daily progress.',
                              icon: Icons.explore_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 5. CLEAN CATEGORY CARDS
                          _AnimatedEntry(
                            delay: 4,
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categories.length,
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: categoryColumns,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent: 180, // Slightly shorter
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                final LearningCategory category = categories[index];
                                return _LearningCategoryCard(
                                  category: category,
                                  onTap: () => _openCategory(category.title),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 6. CONTINUE LEARNING SECTION
                          const _AnimatedEntry(
                            delay: 5,
                            child: _SectionTitle(
                              eyebrow: 'KEEP GOING',
                              title: 'Continue learning',
                              subtitle: 'Continue exactly where you stopped.',
                              icon: Icons.auto_awesome_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),

                          _AnimatedEntry(
                            delay: 6,
                            child: _ContinueCard(
                              item: data.resumeItem,
                              onTap: () => _openRoute(data.resumeItem.route),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _AnimatedEntry(
                            delay: 7,
                            child: _DailyChallengeCard(
                              completed: data.dailyCompleted,
                              total: data.dailyTotal,
                              xpAwarded: data.dailyXpAwarded,
                              onTap: _openDailyChallenge,
                            ),
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
        ],
      ),
    );
  }
}

// ==========================================
// UNIFIED & COMPACT UI COMPONENTS
// ==========================================

class _TopNavBar extends StatelessWidget {
  final int xp;
  final int streak;

  const _TopNavBar({
    required this.xp,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // App Logo
        Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/branding/app_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.school_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
        ),

        // XP, Streak, Settings in one row
        Row(
          children: [
            _MiniStat(
              icon: Icons.star_rounded,
              value: '$xp',
              color: const Color(0xFF10B981),
            ),
            const SizedBox(width: 8),
            _MiniStat(
              icon: Icons.local_fire_department_rounded,
              value: '$streak',
              color: AppColors.amber,
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E293B).withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppColors.navy,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _MiniStat({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroJourneyCard extends StatelessWidget {
  final HomeDashboardData data;
  final VoidCallback onStartTap;

  const _HeroJourneyCard({required this.data, required this.onStartTap});

  @override
  Widget build(BuildContext context) {
    final double progress = _safeProgress(data.levelProgress);

    return Container(
      decoration: BoxDecoration(
        // Vibrant Emerald/Teal Gradient
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0EA5E9), // Emerald
            Color(0xFF10B981), // Teal
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withAlpha(50),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onStartTap,
          borderRadius: BorderRadius.circular(24),
          highlightColor: Colors.white.withAlpha(20),
          splashColor: Colors.white.withAlpha(30),
          child: Stack(
            children: [
              const Positioned(right: -20, top: -30, child: _DecorativeCircle(size: 140, opacity: 15)),
              const Positioned(left: -20, bottom: -30, child: _DecorativeCircle(size: 80, opacity: 10)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Level & Text
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.workspace_premium_rounded, color: AppColors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Level ${data.level}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  data.completedLessons == 0 ? 'Start Learning' : 'Continue Journey',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(220),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Build confident English',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Compact Progress Bar
                          Row(
                            children: [
                              Text(
                                '${data.xp} XP',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 5,
                                    backgroundColor: Colors.black.withAlpha(20),
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.amber),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${data.xpToNextLevel} Left',
                                style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 10.5, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Big Play Button with Circular Progress
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4,
                              strokeCap: StrokeCap.round,
                              backgroundColor: Colors.white.withAlpha(30),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFF047857),
                              size: 28,
                            ),
                          ),
                        ],
                      ),
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

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final int opacity;
  const _DecorativeCircle({required this.size, required this.opacity});

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

class _UnifiedQuickStats extends StatelessWidget {
  final HomeDashboardData data;
  const _UnifiedQuickStats({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withAlpha(8),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: <Widget>[
            Expanded(
              child: _StatColumn(
                icon: Icons.check_circle_rounded,
                value: '${data.completedLessons}',
                label: 'Lessons',
                color: AppColors.primary,
              ),
            ),
            VerticalDivider(color: AppColors.border.withAlpha(150), width: 1, indent: 12, endIndent: 12),
            Expanded(
              child: _StatColumn(
                icon: Icons.emoji_events_rounded,
                value: '${data.completedBadges}',
                label: 'Badges',
                color: AppColors.amber,
              ),
            ),
            VerticalDivider(color: AppColors.border.withAlpha(150), width: 1, indent: 12, endIndent: 12),
            Expanded(
              child: _StatColumn(
                icon: Icons.today_rounded,
                value: '${data.todayPractices}',
                label: 'Today',
                color: AppColors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
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

  const _SectionTitle({required this.eyebrow, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withAlpha(30)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(15),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                eyebrow,
                style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(color: AppColors.navy, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LearningCategoryCard extends StatelessWidget {
  final LearningCategory category;
  final VoidCallback onTap;

  const _LearningCategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double progress = _safeProgress(category.progress);
    final int percentage = (progress * 100).round();
    final String action = progress >= 1 ? 'Review' : progress > 0 ? 'Continue' : 'Start';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.color.withAlpha(12),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: category.color.withAlpha(30), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: category.color.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -20,
                top: -20,
                child: Container(width: 90, height: 90, decoration: BoxDecoration(color: category.color.withAlpha(10), shape: BoxShape.circle)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: category.color.withAlpha(25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withAlpha(150)),
                          ),
                          child: Icon(category.icon, color: category.color, size: 24),
                        ),
                        const Spacer(),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(180),
                            shape: BoxShape.circle,
                            border: Border.all(color: category.color.withAlpha(20)),
                          ),
                          child: Icon(Icons.arrow_forward_rounded, color: category.color, size: 15),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      category.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.navy, fontSize: 15.5, height: 1.15, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: category.color.withAlpha(20),
                              valueColor: AlwaysStoppedAnimation<Color>(category.color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          progress > 0 ? '$percentage%' : action,
                          style: TextStyle(color: category.color, fontSize: 10.5, fontWeight: FontWeight.w900),
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

class _ContinueCard extends StatelessWidget {
  final HomeResumeItem item;
  final VoidCallback onTap;

  const _ContinueCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double progress = _safeProgress(item.progress);
    final int percentage = (progress * 100).round();
    final String label = progress <= 0 ? 'START HERE' : progress >= 1 ? 'REVIEW AGAIN' : 'CONTINUE LEARNING';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            item.color.withAlpha(10),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: item.color.withAlpha(25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: item.color.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: item.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(150)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Icon(item.icon, color: item.color, size: 30),
                      const Positioned(right: 6, top: 6, child: Icon(Icons.auto_awesome_rounded, color: AppColors.amber, size: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: item.color, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                            ),
                          ),
                          Text('$percentage%', style: TextStyle(color: item.color, fontSize: 12, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.navy, fontSize: 16.5, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: item.color.withAlpha(20),
                          valueColor: AlwaysStoppedAnimation<Color>(item.color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: item.color.withAlpha(50), blurRadius: 8, offset: const Offset(0, 4)),
                      ]
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final int completed;
  final int total;
  final bool xpAwarded;
  final VoidCallback onTap;

  const _DailyChallengeCard({required this.completed, required this.total, required this.xpAwarded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final int safeTotal = total <= 0 ? 10 : total;
    final double progress = _safeProgress(completed / safeTotal);
    final Color accent = xpAwarded ? AppColors.primary : AppColors.amber;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withAlpha(10),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withAlpha(25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: accent.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(150)),
                  ),
                  child: Icon(xpAwarded ? Icons.verified_rounded : Icons.emoji_events_rounded, color: accent, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Text(
                              'Daily Challenge',
                              style: TextStyle(color: AppColors.navy, fontSize: 16.5, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: accent.withAlpha(20), borderRadius: BorderRadius.circular(16)),
                            child: Text(
                              xpAwarded ? 'DONE' : '+50 XP',
                              style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        xpAwarded ? 'Completed today • Come back tomorrow' : '$completed/$safeTotal completed • Keep your streak alive',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: accent.withAlpha(20),
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: xpAwarded ? accent : accent.withAlpha(20),
                    shape: BoxShape.circle,
                    boxShadow: xpAwarded ? [
                      BoxShadow(color: accent.withAlpha(50), blurRadius: 8, offset: const Offset(0, 4))
                    ] : null,
                  ),
                  child: Icon(
                    xpAwarded ? Icons.check_rounded : Icons.arrow_forward_ios_rounded,
                    color: xpAwarded ? Colors.white : accent,
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

// ==========================================
// ANIMATION & LOADING HELPERS
// ==========================================

class _AnimatedEntry extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedEntry({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final double delayedValue = ((value - (delay * 0.05)) / (1 - (delay * 0.05))).clamp(0.0, 1.0);
        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - delayedValue)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _HomeSkeletonLoader extends StatefulWidget {
  final double padding;
  const _HomeSkeletonLoader({required this.padding});

  @override
  State<_HomeSkeletonLoader> createState() => _HomeSkeletonLoaderState();
}

class _HomeSkeletonLoaderState extends State<_HomeSkeletonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildShimmerBox({required double width, required double height, double borderRadius = 16}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((100 + (_controller.value * 100)).toInt()),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(widget.padding, MediaQuery.paddingOf(context).top + 16, widget.padding, 34),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Row(
          children: [
            _buildShimmerBox(width: 44, height: 44, borderRadius: 22),
            const Spacer(),
            _buildShimmerBox(height: 44, width: 80, borderRadius: 22),
            const SizedBox(width: 8),
            _buildShimmerBox(height: 44, width: 80, borderRadius: 22),
            const SizedBox(width: 8),
            _buildShimmerBox(width: 44, height: 44, borderRadius: 22),
          ],
        ),
        const SizedBox(height: 16),
        _buildShimmerBox(height: 200, width: double.infinity, borderRadius: 24),
        const SizedBox(height: 16),
        _buildShimmerBox(height: 70, width: double.infinity, borderRadius: 20),
        const SizedBox(height: 32),
        Row(
          children: [
            _buildShimmerBox(height: 44, width: 44, borderRadius: 14),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(height: 10, width: 100),
                const SizedBox(height: 6),
                _buildShimmerBox(height: 16, width: 160),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildShimmerBox(height: 180, width: double.infinity, borderRadius: 22)),
            const SizedBox(width: 14),
            Expanded(child: _buildShimmerBox(height: 180, width: double.infinity, borderRadius: 22)),
          ],
        ),
      ],
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _HomeErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: AppColors.navy.withAlpha(10), blurRadius: 20, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(color: AppColors.error.withAlpha(20), shape: BoxShape.circle),
                child: const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 43),
              ),
              const SizedBox(height: 18),
              const Text(
                'Could not load Home',
                style: TextStyle(color: AppColors.navy, fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.45, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _safeProgress(double value) {
  return value.clamp(0.0, 1.0).toDouble();
}