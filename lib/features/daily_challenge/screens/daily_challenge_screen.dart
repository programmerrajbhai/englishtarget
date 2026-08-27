import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../question_making/services/question_making_audio_service.dart';
import '../data/daily_challenge_data.dart';
import '../models/daily_challenge_item.dart';
import '../services/daily_challenge_progress_service.dart';
import 'daily_challenge_practice_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({
    super.key,
  });

  @override
  State<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState
    extends State<DailyChallengeScreen> {
  DailyChallengeState? _state;
  bool _loading = true;

  List<DailyChallengeItem> get _items =>
      DailyChallengeData.today();

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final DailyChallengeState state =
    await DailyChallengeProgressService
        .getState();

    if (!mounted) {
      return;
    }

    setState(() {
      _state = state;
      _loading = false;
    });
  }

  Future<void> _startChallenge() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) {
          return const DailyChallengePracticeScreen();
        },
      ),
    );

    await _loadState();
  }

  String _todayText() {
    final DateTime now = DateTime.now();

    const List<String> weekdays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[now.weekday - 1]}, '
        '${now.day} ${months[now.month - 1]}';
  }

  int _count(DailyChallengeItemType type) {
    return _items
        .where(
          (DailyChallengeItem item) =>
      item.type == type,
    )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final DailyChallengeState state =
        _state ??
            const DailyChallengeState(
              completedIds: <String>{},
              correctIds: <String>{},
              xpAwarded: false,
              streak: 0,
            );

    final double progress =
    (state.completedCount / 10).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Daily Challenge',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(
              right: 16,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.amber.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.amber.withAlpha(75),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.amber,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.streak} days',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      )
          : SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            28,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.navy,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _todayText(),
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _ChallengeHero(
                completed: state.completedCount,
                progress: progress,
                streak: state.streak,
              ),
              const SizedBox(height: 15),
              _XpBanner(
                completed: state.completedCount,
                xpAwarded: state.xpAwarded,
              ),
              const SizedBox(height: 23),
              const Text(
                "Today's Challenge",
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 11),
              _ChallengeBreakdown(
                ruleCount:
                _count(DailyChallengeItemType.rule),
                basicCount: _count(
                  DailyChallengeItemType.basicSentence,
                ),
                questionCount: _count(
                  DailyChallengeItemType.questionMaking,
                ),
                speakingCount: _count(
                  DailyChallengeItemType.speaking,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(55),
                  ),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(
                      Icons.schedule_rounded,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Estimated time',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '5 minutes',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Weekly Streak',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _StreakRow(
                streak: state.streak,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _startChallenge,
                  icon: Icon(
                    state.isComplete
                        ? Icons.replay_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    state.isComplete
                        ? 'Review Challenge'
                        : 'Start Challenge',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
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

class _ChallengeHero extends StatelessWidget {
  final int completed;
  final double progress;
  final int streak;

  const _ChallengeHero({
    required this.completed,
    required this.progress,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFFE7F8EF),
            Color(0xFFF7FFFA),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppColors.primary.withAlpha(55),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Ready for today\'s challenge?',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 21,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Text(
                      '$completed of 10',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor:
                          AppColors.primary.withAlpha(35),
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _XpBanner extends StatelessWidget {
  final int completed;
  final bool xpAwarded;

  const _XpBanner({
    required this.completed,
    required this.xpAwarded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.amber.withAlpha(80),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.star_rounded,
            color: AppColors.amber,
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            xpAwarded ? '50 XP earned' : '+50 XP',
            style: const TextStyle(
              color: AppColors.amber,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 9),
          const Text(
            '•',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              xpAwarded
                  ? 'Challenge completed'
                  : 'Complete all 10 questions',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeBreakdown extends StatelessWidget {
  final int ruleCount;
  final int basicCount;
  final int questionCount;
  final int speakingCount;

  const _ChallengeBreakdown({
    required this.ruleCount,
    required this.basicCount,
    required this.questionCount,
    required this.speakingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.black.withAlpha(18),
        ),
      ),
      child: Column(
        children: <Widget>[
          _BreakdownRow(
            icon: Icons.menu_book_rounded,
            color: Colors.green,
            label: '$ruleCount Rule Questions',
          ),
          _BreakdownRow(
            icon: Icons.chat_bubble_rounded,
            color: Colors.blue,
            label: '$basicCount Basic Sentences',
          ),
          _BreakdownRow(
            icon: Icons.quiz_rounded,
            color: Colors.orange,
            label: '$questionCount Question Making',
          ),
          _BreakdownRow(
            icon: Icons.mic_rounded,
            color: Colors.deepPurple,
            label: '$speakingCount Speaking',
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _BreakdownRow({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: color.withAlpha(18),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label.split(' ').first,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  final int streak;

  const _StreakRow({
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> days = <String>[
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.black.withAlpha(18),
        ),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,
        children: days.asMap().entries.map(
              (MapEntry<int, String> entry) {
            final bool active =
                entry.key < streak.clamp(0, 7);

            return Column(
              children: <Widget>[
                Text(
                  entry.value,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  width: 29,
                  height: 29,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active
                          ? AppColors.primary
                          : AppColors.primary.withAlpha(80),
                    ),
                  ),
                  child: Icon(
                    active
                        ? Icons.check_rounded
                        : Icons.circle_outlined,
                    color: active
                        ? Colors.white
                        : AppColors.primary.withAlpha(130),
                    size: 17,
                  ),
                ),
              ],
            );
          },
        ).toList(),
      ),
    );
  }
}