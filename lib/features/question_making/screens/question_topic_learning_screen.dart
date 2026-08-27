import 'package:englishtarget/features/question_making/screens/question_practice_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/question_making_topic.dart';


class QuestionTopicLearningScreen
    extends StatelessWidget {
  final QuestionMakingTopic topic;

  const QuestionTopicLearningScreen({
    super.key,
    required this.topic,
  });

  void _startPractice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) {
          return QuestionPracticeScreen(
            topic: topic,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleQuestions =
    topic.questions.take(2).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          topic.title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: topic.color.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: topic.color.withAlpha(80),
              ),
            ),
            child: Text(
              'Step 2 of 4',
              style: TextStyle(
                color: topic.color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            25,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: topic.color.withAlpha(22),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: topic.color.withAlpha(65),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: topic.color,
                        borderRadius:
                        BorderRadius.circular(18),
                      ),
                      child: Icon(
                        topic.icon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            topic.title,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            topic.subtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _CoachTip(color: topic.color),
              const SizedBox(height: 20),
              const Text(
                'Question structure',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.black.withAlpha(18),
                  ),
                ),
                child: Text(
                  'Question word + helping verb + subject + main verb?',
                  style: TextStyle(
                    color: topic.color,
                    fontSize: 15,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Examples',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              ...visibleQuestions.map(
                    (question) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: _ExampleCard(
                      bangla: question.bengali,
                      english: question.english,
                      color: topic.color,
                    ),
                  );
                },
              ),
              const SizedBox(height: 13),
              const Text(
                'Question words',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const <Widget>[
                  _WordChip(
                    word: 'What',
                    meaning: 'কী',
                    color: Colors.green,
                  ),
                  _WordChip(
                    word: 'Where',
                    meaning: 'কোথায়',
                    color: Colors.blue,
                  ),
                  _WordChip(
                    word: 'Why',
                    meaning: 'কেন',
                    color: Colors.deepPurple,
                  ),
                  _WordChip(
                    word: 'When',
                    meaning: 'কখন',
                    color: Colors.orange,
                  ),
                  _WordChip(
                    word: 'Who',
                    meaning: 'কে',
                    color: Colors.teal,
                  ),
                  _WordChip(
                    word: 'How',
                    meaning: 'কীভাবে',
                    color: Colors.pink,
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _startPractice(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize:
                        const Size.fromHeight(54),
                        side: BorderSide(
                          color: topic.color,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Take a Test',
                        style: TextStyle(
                          color: topic.color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _startPractice(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: topic.color,
                        foregroundColor: Colors.white,
                        minimumSize:
                        const Size.fromHeight(54),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Build Questions',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachTip extends StatelessWidget {
  final Color color;

  const _CoachTip({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withAlpha(55),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.lightbulb_rounded,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Use a question word first, then arrange the rest of the sentence.',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String bangla;
  final String english;
  final Color color;

  const _ExampleCard({
    required this.bangla,
    required this.english,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.black.withAlpha(18),
        ),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 17,
            backgroundColor: color,
            child: const Icon(
              Icons.volume_up_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '$bangla\n',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 13,
                    ),
                  ),
                  TextSpan(
                    text: english,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final String meaning;
  final Color color;

  const _WordChip({
    required this.word,
    required this.meaning,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(65),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(
            word,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '= $meaning',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}