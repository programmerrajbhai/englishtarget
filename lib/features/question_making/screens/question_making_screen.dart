import 'package:englishtarget/features/question_making/screens/question_topic_learning_screen.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../home/widgets/xp_balance_pill.dart';
import '../data/question_making_data.dart';

import '../services/question_making_progress_service.dart';
import '../widgets/question_making_topic.dart';


class QuestionMakingScreen extends StatefulWidget {
  const QuestionMakingScreen({
    super.key,
  });

  @override
  State<QuestionMakingScreen> createState() =>
      _QuestionMakingScreenState();
}

class _QuestionMakingScreenState
    extends State<QuestionMakingScreen> {
  final Map<String, int> _progress =
  <String, int>{};

  bool _loading = true;

  List<QuestionMakingTopic> get _topics =>
      QuestionMakingData.topics;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final List<int> counts = await Future.wait<int>(
      _topics.map(
            (QuestionMakingTopic topic) {
          return QuestionMakingProgressService
              .getCount(topic.id);
        },
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      for (int index = 0;
      index < _topics.length;
      index++) {
        _progress[_topics[index].id] =
        counts[index];
      }

      _loading = false;
    });
  }

  Future<void> _openTopic(
      QuestionMakingTopic topic,
      ) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) {
          return QuestionTopicLearningScreen(
            topic: topic,
          );
        },
      ),
    );

    await _loadProgress();
  }

  int _completedTopics() {
    return _topics.where(
          (QuestionMakingTopic topic) {
        return (_progress[topic.id] ?? 0) >= 25;
      },
    ).length;
  }

  double _overallProgress() {
    if (_topics.isEmpty) {
      return 0;
    }

    final int completedPractices =
    _progress.values.fold<int>(
      0,
          (int total, int value) {
        return total + value.clamp(0, 25);
      },
    );

    return completedPractices /
        (_topics.length * 25);
  }

  @override
  Widget build(BuildContext context) {
    final double overallProgress =
    _overallProgress();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                      ),
                      color: AppColors.navy,
                    ),
                    const Expanded(
                      child: Text(
                        'Question Making',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const XpBalancePill(),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  0,
                ),
                child: _HeroCard(
                  progress: overallProgress,
                  completedTopics: _completedTopics(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  18,
                ),
                child: _SummaryCard(
                  topicCount: _topics.length,
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  30,
                ),
                sliver: SliverList.builder(
                  itemCount: _topics.length,
                  itemBuilder: (
                      BuildContext context,
                      int index,
                      ) {
                    final QuestionMakingTopic topic =
                    _topics[index];

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 13,
                      ),
                      child: _TopicCard(
                        topic: topic,
                        completed:
                        _progress[topic.id] ?? 0,
                        onTap: () {
                          _openTopic(topic);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final double progress;
  final int completedTopics;

  const _HeroCard({
    required this.progress,
    required this.completedTopics,
  });

  @override
  Widget build(BuildContext context) {
    final int percentage =
    (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFF0EA765),
            Color(0xFF087C56),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withAlpha(35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Build your questions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Learn to ask questions correctly.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius:
                  BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor:
                    Colors.white.withAlpha(55),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$completedTopics/30 topics completed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(235),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 5,
              ),
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int topicCount;

  const _SummaryCard({
    required this.topicCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withAlpha(35),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.tune_rounded,
            color: AppColors.primary,
            size: 23,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$topicCount topics • 25 practices per topic',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Text(
            '+10 XP',
            style: TextStyle(
              color: AppColors.amber,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final QuestionMakingTopic topic;
  final int completed;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
    (completed / 25).clamp(0.0, 1.0);

    final bool isCompleted = completed >= 25;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: topic.color.withAlpha(65),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: topic.color.withAlpha(13),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: topic.color.withAlpha(28),
                shape: BoxShape.circle,
                border: Border.all(
                  color: topic.color.withAlpha(90),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_rounded
                    : topic.icon,
                color: topic.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    topic.title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 11),
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      backgroundColor:
                      topic.color.withAlpha(28),
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                        topic.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: topic.color.withAlpha(24),
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted ? 'Review' : 'Start',
                    style: TextStyle(
                      color: topic.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$completed/25',
                  style: TextStyle(
                    color: topic.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}