import 'package:flutter/material.dart';

import '../../../core/ads/ad_manager.dart'; // <--- AD MANAGER IMPORT
import '../../../core/ads/banner_ad_widget.dart'; // <--- BANNER AD IMPORT
import '../../../core/constants/app_colors.dart';
import '../../splash/widgets/splash_mascot.dart';
import '../data/basic_sentences_data.dart';
import '../models/basic_sentence_topic.dart';
import '../services/basic_sentence_progress_service.dart';
import 'basic_sentence_session_screen.dart';

class BasicSentencesScreen extends StatefulWidget {
  const BasicSentencesScreen({super.key});

  @override
  State<BasicSentencesScreen> createState() =>
      _BasicSentencesScreenState();
}

class _BasicSentencesScreenState
    extends State<BasicSentencesScreen> {
  final Map<String, int> _attendedProgress =
  <String, int>{};

  bool _loading = true;

  List<BasicSentenceTopic> get _topics {
    return BasicSentencesData.topics;
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final Map<String, int> progress =
    <String, int>{};

    for (final BasicSentenceTopic topic in _topics) {
      progress[topic.id] =
      await BasicSentenceProgressService.getCount(
        topic.id,
      );
    }

    if (!mounted) return;

    setState(() {
      _attendedProgress
        ..clear()
        ..addAll(progress);
      _loading = false;
    });
  }

  Future<void> _openTopic(BasicSentenceTopic topic) async {
    // --- INTERSTITIAL AD TRIGGER ---
    // ইউজার যেকোনো টপিকে ক্লিক করলেই অ্যাড কল হবে
    AdManager.instance.showInterstitialAd(
      onAdDismissed: () {
        // অ্যাড দেখা শেষ হলে (বা কুলডাউনে থাকলে) নেক্সট স্ক্রিনে (Practice Session) যাবে
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => BasicSentenceSessionScreen(
              topic: topic,
            ),
          ),
        ).then((_) {
          // সেশন শেষ করে ব্যাক করার পর প্রগ্রেস আপডেট হবে
          _loadProgress();
        });
      },
    );
  }

  int _attended(BasicSentenceTopic topic) {
    return _attendedProgress[topic.id] ?? 0;
  }

  int get _completedTopics {
    return _topics.where((BasicSentenceTopic topic) {
      return _attended(topic) >= 25;
    }).length;
  }

  double get _overallProgress {
    if (_topics.isEmpty) return 0;

    final int totalActivities =
    _topics.fold<int>(
      0,
          (int total, BasicSentenceTopic topic) {
        return total + _attended(topic);
      },
    );

    return (totalActivities / (_topics.length * 25))
        .clamp(0.0, 1.0)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- STICKY BANNER AD START ---
            const BannerAdWidget(),
            // --- STICKY BANNER AD END ---

            Expanded(
              child: _loading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
                  : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      10,
                      18,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _Header(
                        onBack: () =>
                            Navigator.maybePop(context),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      17,
                      18,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _HeroCard(
                        progress: _overallProgress,
                        completedTopics: _completedTopics,
                        totalTopics: _topics.length,
                      ),
                    ),
                  ),
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      14,
                      18,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _SummaryCard(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      24,
                      18,
                      35,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (
                            BuildContext context,
                            int index,
                            ) {
                          final BasicSentenceTopic topic =
                          _topics[index];

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index ==
                                  _topics.length - 1
                                  ? 0
                                  : 14,
                            ),
                            child: _TopicCard(
                              topic: topic,
                              attended: _attended(topic),
                              onTap: () => _openTopic(topic),
                            ),
                          );
                        },
                        childCount: _topics.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: onBack,
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          color: AppColors.navy,
        ),
        const Expanded(
          child: Text(
            'Basic Sentences',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const _StatPill(
          icon: Icons.local_fire_department_rounded,
          value: '7',
          color: AppColors.amber,
        ),
        const SizedBox(width: 8),
        const _StatPill(
          icon: Icons.star_rounded,
          value: '180',
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withAlpha(45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: 17,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final double progress;
  final int completedTopics;
  final int totalTopics;

  const _HeroCard({
    required this.progress,
    required this.completedTopics,
    required this.totalTopics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        14,
        17,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withAlpha(45),
            blurRadius: 22,
            offset: const Offset(0, 10),
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
                  'Build your English',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Learn useful sentences for real life.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor:
                          Colors.white24,
                          valueColor:
                          const AlwaysStoppedAnimation<
                              Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$completedTopics/$totalTopics topics completed',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 92,
            height: 112,
            child: SplashMascot(size: 92),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: const Row(
        children: <Widget>[
          Icon(
            Icons.route_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '30 topics • 25 practices per topic',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '+10 XP',
            style: TextStyle(
              color: AppColors.amber,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final BasicSentenceTopic topic;
  final int attended;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.attended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final int total = 25;
    final bool completed = attended >= total;
    final bool started = attended > 0;
    final Color color = topic.color;

    final double progress = (attended / total)
        .clamp(0.0, 1.0)
        .toDouble();

    final String action = completed
        ? 'Review'
        : started
        ? 'Continue'
        : 'Start';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: started
                ? color.withAlpha(22)
                : Colors.white,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: started
                  ? color.withAlpha(110)
                  : AppColors.border,
              width: started ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withAlpha(90),
                    width: 2,
                  ),
                ),
                child: Icon(
                  completed
                      ? Icons.check_rounded
                      : topic.icon,
                  color: color,
                  size: 29,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      topic.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor:
                              color.withAlpha(20),
                              valueColor:
                              AlwaysStoppedAnimation<Color>(
                                color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$attended/$total',
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: started || completed
                      ? color
                      : color.withAlpha(18),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  action,
                  style: TextStyle(
                    color: started || completed
                        ? Colors.white
                        : color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
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