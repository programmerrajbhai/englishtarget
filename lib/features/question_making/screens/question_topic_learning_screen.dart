import 'package:flutter/material.dart';

import '../../../core/ads/ad_manager.dart'; // <--- AD MANAGER IMPORT
import '../../../core/ads/banner_ad_widget.dart'; // <--- BANNER AD IMPORT
import '../../../core/constants/app_colors.dart';

import '../services/question_making_audio_service.dart';
import '../widgets/question_making_topic.dart';
import 'question_practice_screen.dart';

class QuestionTopicLearningScreen extends StatelessWidget {
  final QuestionMakingTopic topic;

  const QuestionTopicLearningScreen({
    super.key,
    required this.topic,
  });

  void _startPractice(BuildContext context) {
    // --- INTERSTITIAL AD TRIGGER ---
    // প্র্যাকটিস শুরু করার আগে অ্যাড শো করবে
    AdManager.instance.showInterstitialAd(
      onAdDismissed: () {
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List questions = topic.questions.take(3).toList();

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
            margin: const EdgeInsets.only(
              right: 16,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: topic.color.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: topic.color.withAlpha(75),
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
        bottom: false,
        child: Column(
          children: [
            // --- STICKY BANNER AD START ---
            const BannerAdWidget(),
            // --- STICKY BANNER AD END ---

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            topic.color.withAlpha(38),
                            topic.color.withAlpha(12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: topic.color.withAlpha(65),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              color: topic.color,
                              borderRadius: BorderRadius.circular(19),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: topic.color.withAlpha(55),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              topic.icon,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  topic.title,
                                  style: const TextStyle(
                                    color: AppColors.navy,
                                    fontSize: 21,
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
                    const SizedBox(height: 18),
                    _TipCard(color: topic.color),
                    const SizedBox(height: 23),
                    const Text(
                      'Question structure',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
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
                          height: 1.45,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 23),
                    const Text(
                      'Examples',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...questions.map(
                          (dynamic question) {
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
                    const SizedBox(height: 15),
                    const Text(
                      'Question words',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const <Widget>[
                        _WordCard(
                          word: 'What',
                          meaning: 'কী',
                          color: Colors.green,
                        ),
                        _WordCard(
                          word: 'Where',
                          meaning: 'কোথায়',
                          color: Colors.blue,
                        ),
                        _WordCard(
                          word: 'Why',
                          meaning: 'কেন',
                          color: Colors.deepPurple,
                        ),
                        _WordCard(
                          word: 'When',
                          meaning: 'কখন',
                          color: Colors.orange,
                        ),
                        _WordCard(
                          word: 'Who',
                          meaning: 'কে',
                          color: Colors.teal,
                        ),
                        _WordCard(
                          word: 'How',
                          meaning: 'কীভাবে',
                          color: Colors.pink,
                        ),
                      ],
                    ),
                    const SizedBox(height: 27),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _startPractice(context);
                            },
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                            ),
                            label: const Text(
                              'Take Test',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: topic.color,
                              minimumSize: const Size.fromHeight(55),
                              side: BorderSide(
                                color: topic.color,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _startPractice(context);
                            },
                            icon: const Icon(
                              Icons.extension_rounded,
                            ),
                            label: const Text(
                              'Build',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: topic.color,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(55),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final Color color;

  const _TipCard({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withAlpha(60),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.lightbulb_rounded,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Text(
              'Start with a question word and arrange the sentence carefully.',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                height: 1.4,
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
      padding: const EdgeInsets.fromLTRB(
        13,
        12,
        8,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withAlpha(18),
        ),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                QuestionMakingAudioService.speak(
                  english,
                );
              },
              icon: const Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
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
                      fontWeight: FontWeight.w900,
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

class _WordCard extends StatelessWidget {
  final String word;
  final String meaning;
  final Color color;

  const _WordCard({
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