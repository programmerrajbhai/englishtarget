import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../basic_sentences/data/basic_sentences_data.dart';
import '../../basic_sentences/services/basic_sentence_progress_service.dart';
import '../../basic_sentences/services/basic_sentence_xp_service.dart';
import '../../daily_challenge/services/daily_challenge_progress_service.dart';
import '../../question_making/data/question_making_data.dart';
import '../../question_making/services/question_making_progress_service.dart';
import '../../rules/models/rule_progress.dart';
import '../../rules/repositories/rules_repository.dart';
import '../../rules/services/rules_progress_service.dart';

class LearningProgressSnapshot {
  final int xp;
  final int completedRules;
  final int totalRules;
  final int basicPractices;
  final int totalBasicPractices;
  final int completedBasicTopics;
  final int totalBasicTopics;
  final int questionPractices;
  final int totalQuestionPractices;
  final int completedQuestionTopics;
  final int totalQuestionTopics;
  final int dailyCompleted;
  final int dailyCorrect;
  final int dailyTotal;
  final int streak;

  const LearningProgressSnapshot({
    required this.xp,
    required this.completedRules,
    required this.totalRules,
    required this.basicPractices,
    required this.totalBasicPractices,
    required this.completedBasicTopics,
    required this.totalBasicTopics,
    required this.questionPractices,
    required this.totalQuestionPractices,
    required this.completedQuestionTopics,
    required this.totalQuestionTopics,
    required this.dailyCompleted,
    required this.dailyCorrect,
    required this.dailyTotal,
    required this.streak,
  });

  static Future<LearningProgressSnapshot> load() async {
    final Map<String, RuleProgress> rules =
    await RulesProgressService.loadAllProgress();

    final List<int> basic = await Future.wait<int>(
      BasicSentencesData.topics.map(
            (topic) => BasicSentenceProgressService.getCount(topic.id),
      ),
    );

    final List<int> questions = await Future.wait<int>(
      QuestionMakingData.topics.map(
            (topic) => QuestionMakingProgressService.getCount(topic.id),
      ),
    );

    final DailyChallengeState daily =
    await DailyChallengeProgressService.getState();

    int cappedTotal(List<int> values) {
      return values.fold<int>(
        0,
            (sum, value) => sum + (value > 25 ? 25 : value),
      );
    }

    final int completedRules = RulesRepository.allRules.where((rule) {
      return (rules[rule.id] ?? const RuleProgress()).isCompleted;
    }).length;

    return LearningProgressSnapshot(
      xp: await BasicSentenceXpService.load(),
      completedRules: completedRules,
      totalRules: RulesRepository.allRules.length,
      basicPractices: cappedTotal(basic),
      totalBasicPractices: BasicSentencesData.topics.length * 25,
      completedBasicTopics: basic
          .where((value) => value >= BasicSentenceProgressService.practicesPerTopic)
          .length,
      totalBasicTopics: BasicSentencesData.topics.length,
      questionPractices: cappedTotal(questions),
      totalQuestionPractices: QuestionMakingData.topics.length * 25,
      completedQuestionTopics: questions.where(
            (value) => value >= QuestionMakingProgressService.practicesPerTopic,
      ).length,
      totalQuestionTopics: QuestionMakingData.topics.length,
      dailyCompleted: daily.completedCount,
      dailyCorrect: daily.correctCount,
      dailyTotal: daily.totalCount,
      streak: daily.streak,
    );
  }

  int get level => (xp ~/ 250) + 1;
  int get completedUnits => completedRules + completedBasicTopics + completedQuestionTopics;
  int get totalUnits => totalRules + totalBasicTopics + totalQuestionTopics;
  double get overallProgress => totalUnits == 0
      ? 0
      : (completedUnits / totalUnits).clamp(0.0, 1.0).toDouble();
}

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<LearningProgressSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = LearningProgressSnapshot.load();
  }

  Future<void> _refresh() async {
    final Future<LearningProgressSnapshot> future = LearningProgressSnapshot.load();
    setState(() => _future = future);
    await future;
  }

  void _open(BuildContext context, String route) {
    Navigator.pushNamed(context, route).then((_) {
      if (mounted) _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<LearningProgressSnapshot>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _RetryButton(onRetry: _refresh);
            }

            final LearningProgressSnapshot data = snapshot.data!;
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                children: <Widget>[
                  const _Header(title: 'Learning Progress', subtitle: 'See your real learning journey'),
                  const SizedBox(height: 20),
                  _JourneyCard(data: data),
                  const SizedBox(height: 18),
                  _StatsRow(data: data),
                  const SizedBox(height: 28),
                  const _SectionHeader(title: 'Progress by category', subtitle: 'Tap a category to continue learning'),
                  const SizedBox(height: 14),
                  _ProgressTile(title: 'Learn Rules', subtitle: 'নিয়ম বুঝে শেখা', icon: Icons.menu_book_rounded, color: AppColors.primary, completed: data.completedRules, total: data.totalRules, unit: 'rules completed', onTap: () => _open(context, AppRoutes.rules)),
                  _gap,
                  _ProgressTile(title: 'Basic Sentences', subtitle: 'দৈনন্দিন বাক্য অনুশীলন', icon: Icons.chat_bubble_rounded, color: AppColors.blue, completed: data.basicPractices, total: data.totalBasicPractices, unit: 'practices completed', onTap: () => _open(context, AppRoutes.basicSentences)),
                  _gap,
                  _ProgressTile(title: 'Question Making', subtitle: 'সঠিক প্রশ্ন তৈরি করা', icon: Icons.quiz_rounded, color: AppColors.purple, completed: data.questionPractices, total: data.totalQuestionPractices, unit: 'practices completed', onTap: () => _open(context, AppRoutes.questionMaking)),
                  _gap,
                  _ProgressTile(title: 'Daily Challenge', subtitle: 'আজকের challenge', icon: Icons.emoji_events_rounded, color: AppColors.amber, completed: data.dailyCompleted, total: data.dailyTotal, unit: 'questions completed', onTap: () => _open(context, AppRoutes.dailyChallenge)),
                  const SizedBox(height: 20),
                  _StreakCard(data: data),
                  const SizedBox(height: 14),
                  _MessageCard(data: data),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

const SizedBox _gap = SizedBox(height: 12);

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(title, style: const TextStyle(color: AppColors.navy, fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    ],
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(title, style: const TextStyle(color: AppColors.navy, fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
    ],
  );
}

class _JourneyCard extends StatelessWidget {
  final LearningProgressSnapshot data;
  const _JourneyCard({required this.data});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: <Color>[AppColors.primary, AppColors.primaryDark]),
      borderRadius: BorderRadius.circular(26),
      boxShadow: <BoxShadow>[BoxShadow(color: AppColors.primary.withAlpha(45), blurRadius: 22, offset: const Offset(0, 10))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: <Widget>[const Expanded(child: Text('Your learning journey', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))), _LevelPill(level: data.level)]),
        const SizedBox(height: 8),
        const Text('Keep going! You are making great progress.', style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 20),
        Row(children: <Widget>[Text('${data.xp} XP', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)), const Spacer(), Text('${(data.overallProgress * 100).round()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(value: data.overallProgress, minHeight: 8, backgroundColor: Colors.white.withAlpha(45), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
        ),
        const SizedBox(height: 8),
        Text('${data.completedUnits} of ${data.totalUnits} learning units completed', style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
      ],
    ),
  );
}

class _LevelPill extends StatelessWidget {
  final int level;
  const _LevelPill({required this.level});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(color: Colors.white.withAlpha(35), borderRadius: BorderRadius.circular(20)),
    child: Text('Level $level', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
  );
}

class _StatsRow extends StatelessWidget {
  final LearningProgressSnapshot data;
  const _StatsRow({required this.data});

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(child: _Stat(icon: Icons.bolt_rounded, value: '${data.xp}', label: 'Total XP', color: AppColors.amber)),
      const SizedBox(width: 10),
      Expanded(child: _Stat(icon: Icons.local_fire_department_rounded, value: '${data.streak}', label: 'Day streak', color: Colors.deepOrange)),
      const SizedBox(width: 10),
      Expanded(child: _Stat(icon: Icons.check_circle_rounded, value: '${data.dailyCorrect}', label: 'Today correct', color: AppColors.primary)),
    ],
  );
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _Stat({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border)),
    child: Column(children: <Widget>[Icon(icon, color: color, size: 21), const SizedBox(height: 6), Text(value, style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.w600))]),
  );
}

class _ProgressTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int completed;
  final int total;
  final String unit;
  final VoidCallback onTap;
  const _ProgressTile({required this.title, required this.subtitle, required this.icon, required this.color, required this.completed, required this.total, required this.unit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : (completed / total).clamp(0.0, 1.0).toDouble();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21), border: Border.all(color: color.withAlpha(55))),
          child: Row(children: <Widget>[
            Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withAlpha(24), borderRadius: BorderRadius.circular(17)), child: Icon(icon, color: color, size: 27)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[Text(title, style: const TextStyle(color: AppColors.navy, fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)), const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: color.withAlpha(25), valueColor: AlwaysStoppedAnimation<Color>(color))), const SizedBox(height: 5), Text('$completed / $total $unit', style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800))])),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ]),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final LearningProgressSnapshot data;
  const _StreakCard({required this.data});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.amber.withAlpha(18), borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.amber.withAlpha(70))),
    child: Row(children: <Widget>[const Icon(Icons.local_fire_department_rounded, color: AppColors.amber, size: 32), const SizedBox(width: 14), Expanded(child: Text(data.streak == 0 ? 'Start your streak today' : '${data.streak} day learning streak', style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w800)))]),
  );
}

class _MessageCard extends StatelessWidget {
  final LearningProgressSnapshot data;
  const _MessageCard({required this.data});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(22)),
    child: Row(children: <Widget>[const Icon(Icons.auto_awesome_rounded, color: AppColors.amber, size: 28), const SizedBox(width: 13), Expanded(child: Text(data.overallProgress >= 1 ? 'Amazing! You completed your learning journey.' : 'Small practice every day creates big progress.', style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4, fontWeight: FontWeight.w700)))]),
  );
}

class _RetryButton extends StatelessWidget {
  final Future<void> Function() onRetry;
  const _RetryButton({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(child: FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary)));
}
