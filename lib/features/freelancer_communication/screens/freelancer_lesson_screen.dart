import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../models/freelancer_lesson.dart';
import '../services/freelancer_progress_service.dart';
import 'freelancer_conversation_screen.dart';

class FreelancerLessonScreen extends StatefulWidget {
  final FreelancerLesson lesson;

  const FreelancerLessonScreen({super.key, required this.lesson});

  @override
  State<FreelancerLessonScreen> createState() => _FreelancerLessonScreenState();
}

class _FreelancerLessonScreenState extends State<FreelancerLessonScreen> {
  final FlutterTts _tts = FlutterTts();
  int _bestScore = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_setup());
  }

  Future<void> _setup() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    final int score = await FreelancerProgressService.bestScore(
      widget.lesson.id,
    );
    if (mounted) setState(() => _bestScore = score);
  }

  Future<void> _startPractice() async {
    await _tts.stop();
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FreelancerConversationScreen(lesson: widget.lesson),
      ),
    );
    final int score = await FreelancerProgressService.bestScore(
      widget.lesson.id,
    );
    if (mounted) setState(() => _bestScore = score);
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Level ${widget.lesson.id}'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(widget.lesson.icon, color: Colors.white, size: 34),
                const SizedBox(height: 14),
                Text(
                  widget.lesson.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  widget.lesson.subtitle,
                  style: const TextStyle(color: Colors.white70, height: 1.45),
                ),
                if (_bestScore > 0) ...<Widget>[
                  const SizedBox(height: 14),
                  Text(
                    'Best conversation score: $_bestScore%',
                    style: const TextStyle(
                      color: Color(0xFF91E3B9),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Essential replies',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Listen, understand and say each reply aloud.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          for (int index = 0; index < widget.lesson.phrases.length; index++)
            _PhraseCard(
              number: index + 1,
              phrase: widget.lesson.phrases[index],
              onListen: () => _tts.speak(widget.lesson.phrases[index].english),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: FilledButton.icon(
          onPressed: _startPractice,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          icon: const Icon(Icons.support_agent_rounded),
          label: const Text(
            'Practice with AI Buyer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _PhraseCard extends StatelessWidget {
  final int number;
  final FreelancerPhrase phrase;
  final VoidCallback onListen;

  const _PhraseCard({
    required this.number,
    required this.phrase,
    required this.onListen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.mint,
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  phrase.english,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phrase.bangla,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onListen,
            icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
