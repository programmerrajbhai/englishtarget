import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/app_colors.dart';
import '../services/question_making_audio_service.dart';
import '../services/question_making_funnel.dart';
import '../services/question_making_progress_service.dart';
import '../widgets/question_making_activity.dart';
import '../widgets/question_making_item.dart';
import '../widgets/question_making_topic.dart';
import 'question_result_screen.dart';

class QuestionPracticeScreen extends StatefulWidget {
  final QuestionMakingTopic topic;

  const QuestionPracticeScreen({
    super.key,
    required this.topic,
  });

  @override
  State<QuestionPracticeScreen> createState() =>
      _QuestionPracticeScreenState();
}

class _QuestionPracticeScreenState
    extends State<QuestionPracticeScreen> {
  late final List<QuestionMakingActivity>
  _activities;

  final stt.SpeechToText _speech =
  stt.SpeechToText();

  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _skippedAnswers = 0;
  int _earnedXp = 0;

  List<String> _selectedWords = <String>[];
  List<String> _availableWords = <String>[];

  bool _buildChecked = false;
  bool _answered = false;
  bool _isListening = false;
  bool _speechAvailable = false;

  String _recognizedText = '';

  QuestionMakingActivity get _currentActivity =>
      _activities[_currentIndex];

  QuestionMakingItem get _question =>
      _currentActivity.question;

  double get _progress {
    if (_activities.isEmpty) {
      return 0;
    }

    return ((_currentIndex + 1) /
        _activities.length)
        .clamp(0.0, 1.0);
  }

  bool get _buildIsCorrect {
    return _normalize(
      _selectedWords.join(' '),
    ) ==
        _normalize(_question.english);
  }

  @override
  void initState() {
    super.initState();

    _activities =
        QuestionMakingFunnel.createSession(
          widget.topic,
        );

    _prepareActivity();

    unawaited(
      QuestionMakingAudioService.initialize(),
    );

    unawaited(_initializeSpeech());
  }

  Future<void> _initializeSpeech() async {
    final bool available =
    await _speech.initialize();

    if (!mounted) {
      return;
    }

    setState(() {
      _speechAvailable = available;
    });
  }

  void _prepareActivity() {
    final List<String> words =
    List<String>.from(_question.words)
      ..shuffle(Random());

    _selectedWords = <String>[];
    _availableWords = words;
    _buildChecked = false;
    _answered = false;
    _isListening = false;
    _recognizedText = '';
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[.!?,]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _speak(String text) async {
    await QuestionMakingAudioService.speak(text);
  }

  void _selectWord(String word) {
    if (_answered) {
      return;
    }

    setState(() {
      _buildChecked = false;
      _availableWords.remove(word);
      _selectedWords.add(word);
    });

    // Word tap করলে আলাদা word-এর voice
    unawaited(_speak(word));
  }

  void _removeSelectedWord(String word) {
    if (_answered) {
      return;
    }

    setState(() {
      _buildChecked = false;
      _selectedWords.remove(word);
      _availableWords.add(word);
    });
  }

  Future<void> _checkBuildAnswer() async {
    if (_selectedWords.length !=
        _question.words.length) {
      return;
    }

    if (!_buildChecked) {
      setState(() {
        _buildChecked = true;
      });

      await QuestionMakingAudioService.feedback(
        correct: _buildIsCorrect,
      );

      return;
    }

    // Correct হলে Continue
    if (_buildIsCorrect) {
      await _completeActivity(
        isCorrect: true,
        feedbackAlreadyPlayed: true,
      );
      return;
    }

    // Wrong হলে answer reveal না করে edit করার সুযোগ
    setState(() {
      _buildChecked = false;
    });
  }

  Future<void> _startListening() async {
    if (!_speechAvailable || _isListening) {
      return;
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    await _speech.listen(
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        localeId: 'en_US',
      ),
      onResult: (
          stt.SpeechRecognitionResult result,
          ) {
        if (!mounted) {
          return;
        }

        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = false;
    });
  }

  Future<void> _submitSpeaking() async {
    if (_isListening) {
      await _stopListening();
    }

    final bool isCorrect =
        _normalize(_recognizedText) ==
            _normalize(_question.english);

    await QuestionMakingAudioService.feedback(
      correct: isCorrect,
    );

    await _completeActivity(
      isCorrect: isCorrect,
      feedbackAlreadyPlayed: true,
    );
  }

  Future<void> _completeActivity({
    required bool isCorrect,
    bool feedbackAlreadyPlayed = false,
  }) async {
    if (_answered) {
      return;
    }

    setState(() {
      _answered = true;
    });

    if (!feedbackAlreadyPlayed) {
      await QuestionMakingAudioService.feedback(
        correct: isCorrect,
      );
    }

    final int earned =
    await QuestionMakingProgressService
        .markAttended(
      topicId: widget.topic.id,
      activityId: _currentActivity.id,
    );

    _earnedXp += earned;

    if (isCorrect) {
      _correctAnswers++;
    }

    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    if (!mounted) {
      return;
    }

    if (_currentIndex >=
        _activities.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) {
            return QuestionResultScreen(
              topic: widget.topic,
              totalQuestions: _activities.length,
              correctAnswers: _correctAnswers,
              skippedAnswers: _skippedAnswers,
              earnedXp: _earnedXp,
            );
          },
        ),
      );

      return;
    }

    setState(() {
      _currentIndex++;
      _prepareActivity();
    });
  }

  Future<void> _skipActivity() async {
    if (_answered) {
      return;
    }

    _skippedAnswers++;

    await QuestionMakingAudioService.speak(
      'Skipped',
    );

    await _completeActivity(
      isCorrect: false,
      feedbackAlreadyPlayed: true,
    );
  }

  Widget _buildLearnView() {
    return _ActivityPanel(
      color: Colors.green,
      icon: Icons.menu_book_rounded,
      label: 'LEARN',
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Understand this question',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 17),
          _QuestionCard(
            question: _question,
            color: Colors.green,
            showEnglish: true,
            onSound: () {
              _speak(_question.english);
            },
          ),
          const SizedBox(height: 16),
          _InfoBox(
            color: Colors.green,
            icon: Icons.lightbulb_rounded,
            text: _question.explanation,
          ),
          const SizedBox(height: 24),
          _ActionButton(
            label: 'Continue',
            color: Colors.green,
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              unawaited(
                _completeActivity(
                  isCorrect: true,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBuildView() {
    const Color color = Colors.orange;

    final String buttonLabel = !_buildChecked
        ? 'Check Answer'
        : _buildIsCorrect
        ? 'Continue'
        : 'Try Again';

    final IconData buttonIcon = !_buildChecked
        ? Icons.check_rounded
        : _buildIsCorrect
        ? Icons.arrow_forward_rounded
        : Icons.refresh_rounded;

    return _ActivityPanel(
      color: color,
      icon: Icons.extension_rounded,
      label: 'BUILD',
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Arrange the words correctly',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),

          // শুধু বাংলা sentence থাকবে
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              17,
              16,
              8,
              16,
            ),
            decoration: BoxDecoration(
              color: color.withAlpha(18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withAlpha(75),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _question.bengali,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                // Voice hint: English text দেখাবে না
                IconButton(
                  tooltip: 'Listen to a voice hint',
                  onPressed: () {
                    _speak(_question.english);
                  },
                  icon: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.orange,
                    size: 27,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Tap the speaker for a voice hint',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Selected words
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 78,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: _buildChecked
                    ? (_buildIsCorrect
                    ? Colors.green
                    : Colors.red)
                    : color.withAlpha(55),
                width: 1.5,
              ),
            ),
            child: _selectedWords.isEmpty
                ? const Center(
              child: Text(
                'Your question will appear here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            )
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedWords.map(
                    (String word) {
                  return InkWell(
                    onTap: () {
                      _removeSelectedWord(word);
                    },
                    borderRadius:
                    BorderRadius.circular(10),
                    child: _WordChip(
                      word: word,
                      color: _buildChecked
                          ? (_buildIsCorrect
                          ? Colors.green
                          : Colors.red)
                          : color,
                    ),
                  );
                },
              ).toList(),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Words you can use',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          // সব word থাকবে, কিন্তু random order-এ
          Wrap(
            spacing: 8,
            runSpacing: 9,
            children: _availableWords.map(
                  (String word) {
                return InkWell(
                  onTap: () {
                    _selectWord(word);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: _WordChip(
                    word: word,
                    color: Colors.blue,
                  ),
                );
              },
            ).toList(),
          ),

          if (_buildChecked) ...<Widget>[
            const SizedBox(height: 18),
            _FeedbackBox(
              correct: _buildIsCorrect,
            ),
          ],

          const SizedBox(height: 24),

          _ActionButton(
            label: buttonLabel,
            color: color,
            icon: buttonIcon,
            onPressed: _selectedWords.length ==
                _question.words.length
                ? () {
              unawaited(
                _checkBuildAnswer(),
              );
            }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakView() {
    const Color color = Colors.deepPurple;

    return _ActivityPanel(
      color: color,
      icon: Icons.mic_rounded,
      label: 'SPEAK',
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Say this question in English',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: color.withAlpha(18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withAlpha(55),
              ),
            ),
            child: Text(
              _question.bengali,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 27),
          Center(
            child: InkWell(
              onTap: _isListening
                  ? () {
                unawaited(
                  _stopListening(),
                );
              }
                  : () {
                unawaited(
                  _startListening(),
                );
              },
              borderRadius: BorderRadius.circular(70),
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 220,
                ),
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: _isListening
                      ? Colors.red
                      : color,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: color.withAlpha(55),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening
                      ? Icons.stop_rounded
                      : Icons.mic_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              _isListening
                  ? 'Listening... Tap to stop'
                  : 'Tap the microphone',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (_recognizedText.isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withAlpha(70),
                ),
              ),
              child: Text(
                'Recognized:\n$_recognizedText',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 23),
          _ActionButton(
            label: 'Submit Answer',
            color: color,
            icon: Icons.send_rounded,
            onPressed: _recognizedText.trim().isEmpty
                ? null
                : () {
              unawaited(
                _submitSpeaking(),
              );
            },
          ),
          if (!_speechAvailable) ...<Widget>[
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Speech service is not available.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final QuestionMakingActivityType type =
        _currentActivity.type;

    final Widget content =
    type == QuestionMakingActivityType.learn
        ? _buildLearnView()
        : type ==
        QuestionMakingActivityType.build
        ? _buildBuildView()
        : _buildSpeakView();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        title: Text(
          widget.topic.title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(
              right: 18,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: widget.topic.color.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentIndex + 1}/${_activities.length}',
              style: TextStyle(
                color: widget.topic.color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                3,
                20,
                0,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: _progress,
                        minHeight: 8,
                        backgroundColor:
                        Colors.black.withAlpha(18),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          widget.topic.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(_progress * 100).round()}%',
                    style: TextStyle(
                      color: widget.topic.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  20,
                ),
                child: content,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                14,
              ),
              child: TextButton.icon(
                onPressed: () {
                  unawaited(_skipActivity());
                },
                icon: const Icon(
                  Icons.skip_next_rounded,
                  size: 19,
                ),
                label: const Text(
                  'Skip this question',
                ),
                style: TextButton.styleFrom(
                  foregroundColor:
                  AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_speech.stop());
    unawaited(_speech.cancel());
    unawaited(
      QuestionMakingAudioService.stop(),
    );
    super.dispose();
  }
}

class _ActivityPanel extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Widget child;

  const _ActivityPanel({
    required this.color,
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withAlpha(55),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withAlpha(15),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withAlpha(24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuestionMakingItem question;
  final Color color;
  final bool showEnglish;
  final VoidCallback onSound;

  const _QuestionCard({
    required this.question,
    required this.color,
    required this.showEnglish,
    required this.onSound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        8,
        16,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withAlpha(55),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  question.bengali,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (showEnglish) ...<Widget>[
                  const SizedBox(height: 9),
                  Text(
                    question.english,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Play sound',
            onPressed: onSound,
            icon: Icon(
              Icons.volume_up_rounded,
              color: color,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final Color color;

  const _WordChip({
    required this.word,
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
        color: color.withAlpha(17),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: color.withAlpha(80),
        ),
      ),
      child: Text(
        word,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _InfoBox({
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBox extends StatelessWidget {
  final bool correct;

  const _FeedbackBox({
    required this.correct,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
    correct ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withAlpha(17),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withAlpha(75),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            correct
                ? Icons.check_circle_rounded
                : Icons.refresh_rounded,
            color: color,
            size: 25,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              correct
                  ? 'Perfect! Your question is correct.'
                  : 'Not quite. Change the word order and try again.',
              style: TextStyle(
                color: color,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
          Colors.grey.withAlpha(80),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}