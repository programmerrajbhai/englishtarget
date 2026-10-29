import 'package:flutter/material.dart';

import '../../../core/ads/banner_ad_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../data/freelancer_course_data.dart';
import '../models/freelancer_lesson.dart';
import '../services/freelancer_progress_service.dart';
import 'freelancer_lesson_screen.dart';

class FreelancerPathScreen extends StatefulWidget {
  const FreelancerPathScreen({super.key});

  @override
  State<FreelancerPathScreen> createState() => _FreelancerPathScreenState();
}

class _FreelancerPathScreenState extends State<FreelancerPathScreen> {
  Set<int> _completed = <int>{};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final Set<int> completed =
        await FreelancerProgressService.completedLessons();
    if (!mounted) return;
    setState(() {
      _completed = completed;
      _loading = false;
    });
  }

  bool _isUnlocked(int lessonId) =>
      lessonId == 1 || _completed.contains(lessonId - 1);

  Future<void> _openLesson(FreelancerLesson lesson) async {
    if (!_isUnlocked(lesson.id)) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FreelancerLessonScreen(lesson: lesson),
      ),
    );
    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final double progress =
        _completed.length / FreelancerCourseData.lessons.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const BannerAdWidget(),
      appBar: AppBar(
        title: const Text('Freelancer Communication'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProgress,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
                children: <Widget>[
                  _CourseHero(progress: progress, completed: _completed.length),
                  const SizedBox(height: 24),
                  for (int chapter = 1; chapter <= 5; chapter++) ...<Widget>[
                    _ChapterHeader(
                      number: chapter,
                      title: FreelancerCourseData.lessons
                          .firstWhere(
                            (FreelancerLesson lesson) =>
                                lesson.chapter == chapter,
                          )
                          .chapterTitle,
                    ),
                    const SizedBox(height: 10),
                    for (final FreelancerLesson lesson
                        in FreelancerCourseData.lessons.where(
                          (FreelancerLesson item) => item.chapter == chapter,
                        ))
                      _LessonTile(
                        lesson: lesson,
                        completed: _completed.contains(lesson.id),
                        unlocked: _isUnlocked(lesson.id),
                        onTap: () => _openLesson(lesson),
                      ),
                    const SizedBox(height: 18),
                  ],
                ],
              ),
            ),
    );
  }
}

class _CourseHero extends StatelessWidget {
  final double progress;
  final int completed;

  const _CourseHero({required this.progress, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF087A4D), Color(0xFF16A36A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withAlpha(45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.support_agent_rounded, color: Colors.white),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Master Buyer Communication',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Practice real client messages, calls and project conversations.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$completed/16',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  final int number;
  final String title;

  const _ChapterHeader({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.navy,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  final FreelancerLesson lesson;
  final bool completed;
  final bool unlocked;
  final VoidCallback onTap;

  const _LessonTile({
    required this.lesson,
    required this.completed,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: unlocked ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: completed
                    ? AppColors.primary.withAlpha(70)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: unlocked ? AppColors.mint : const Color(0xFFF0F2F4),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    completed
                        ? Icons.check_rounded
                        : (unlocked ? lesson.icon : Icons.lock_rounded),
                    color: completed || unlocked
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'LEVEL ${lesson.id}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        lesson.title,
                        style: TextStyle(
                          color: unlocked
                              ? AppColors.navy
                              : AppColors.textSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        lesson.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: unlocked ? AppColors.primary : AppColors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
