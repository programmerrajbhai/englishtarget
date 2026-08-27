import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/question_making_topic.dart';

class QuestionResultScreen extends StatelessWidget {
  final QuestionMakingTopic topic;
  final int totalQuestions;
  final int correctAnswers;
  final int skippedAnswers;
  final int earnedXp;

  const QuestionResultScreen({
    super.key,
    required this.topic,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.skippedAnswers,
    required this.earnedXp,
  });

  @override
  Widget build(BuildContext context) {
    final int percentage = totalQuestions == 0
        ? 0
        : ((correctAnswers / totalQuestions) * 100)
        .round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Question Test Result',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            25,
          ),
          child: Column(
            children: <Widget>[
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 14,
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$correctAnswers/$totalQuestions',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                percentage >= 80
                    ? 'Excellent!'
                    : percentage >= 50
                    ? 'Good job!'
                    : 'Keep practising!',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                topic.title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: Colors.black.withAlpha(20),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _ResultStat(
                        icon: Icons.star_rounded,
                        value: '+$earnedXp XP',
                        label: 'Earned',
                        color: AppColors.amber,
                      ),
                    ),
                    Expanded(
                      child: _ResultStat(
                        icon: Icons.check_circle_rounded,
                        value: '$correctAnswers',
                        label: 'Correct',
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: _ResultStat(
                        icon: Icons.skip_next_rounded,
                        value: '$skippedAnswers',
                        label: 'Skipped',
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _ProgressLine(
                label: 'Question Words',
                value: percentage,
              ),
              const SizedBox(height: 12),
              _ProgressLine(
                label: 'Question Order',
                value: percentage,
              ),
              const SizedBox(height: 12),
              _ProgressLine(
                label: 'Speaking',
                value: percentage,
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(17),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(
                      Icons.lightbulb_rounded,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Keep practising every day to improve your question-making skill.',
                        style: TextStyle(
                          color: AppColors.navy,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back to Topic',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 11),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                          (Route<dynamic> route) {
                        return route.isFirst;
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(
                      color: AppColors.navy,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
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

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ResultStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(
          icon,
          color: color,
          size: 27,
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final String label;
  final int value;

  const _ProgressLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 125,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 7,
              backgroundColor:
              Colors.black.withAlpha(18),
              valueColor:
              const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$value%',
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}