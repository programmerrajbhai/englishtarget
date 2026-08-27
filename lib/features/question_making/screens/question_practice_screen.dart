import 'dart:async';
import 'dart:math';
import 'package:englishtarget/features/question_making/screens/question_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/constants/app_colors.dart';
import '../services/question_making_funnel.dart';
import '../services/question_making_progress_service.dart';
import '../widgets/question_making_activity.dart';
import '../widgets/question_making_item.dart';
import '../widgets/question_making_topic.dart';


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

  late final FlutterTts _tts;

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

  double get _progress =>
      (_currentIndex / _activities.length)
          .clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();

    _tts = FlutterTts();

    _activities =
        QuestionMakingFunnel.createSession(
          widget.topic,
        );

    _prepareActivity();

    unawaited(_configureSpeech());
  }

  Future<void> _configureSpeech() async {
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
    _recognizedText = '';
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[.!?,]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool get _buildIsCorrect {
    final String selected =
    _selectedWords.join(' ');

    return _normalize(selected) ==
        _normalize(_question.english);
  }

  void _selectWord(String word) {
    if (_answered || _buildChecked) {
      return;
    }

    setState(() {
      _availableWords.remove(word);
      _selectedWords.add(word);
    });

    unawaited(_speak(word));
  }

  void _removeSelectedWord(String word) {
    if (_answered || _buildChecked) {
      return;
    }

    setState(() {
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
      return;
    }

    await _completeActivity(
      isCorrect: _buildIsCorrect,
    );
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
      onResult: (stt.SpeechRecognitionResult result) {
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

    final bool correct =
        _normalize(_recognizedText) ==
            _normalize(_question.english);

    await _completeActivity(
      isCorrect: correct,
    );
  }

  Future<void> _completeActivity({
    required bool isCorrect,
  }) async {
    if (_answered) {
      return;
    }

    setState(() {
      _answered = true;
    });

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
      const Duration(milliseconds: 250),
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

    await _completeActivity(
      isCorrect: false,
    );
  }

  Widget _buildLearnBody() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: <Widget>[
        _TypeLabel(
          label: 'LEARN',
          color: Colors.green,
        ),
        const SizedBox(height: 18),
        const Text(
          'Understand this question',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 15),
        _QuestionCard(
          question: _question,
          color: Colors.green,
          showEnglish: true,
          onSound: () {
            _speak(_question.english);
          },
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(18),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Text(
            _question.explanation,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 25),
        _primaryButton(
          label: 'Continue',
          onPressed: () {
            _completeActivity(isCorrect: true);
          },
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildBuildBody() {
    final Color color = Colors.orange;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: <Widget>[
        _TypeLabel(
          label: 'BUILD',
          color: color,
        ),
        const SizedBox(height: 18),
        const Text(
          'Arrange the words correctly',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withAlpha(80),
            ),
          ),
          child: Text(
            _question.bengali,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 17),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 70,
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
                  : Colors.black.withAlpha(35),
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedWords.map(
                  (String word) {
                return InkWell(
                  onTap: () {
                    _removeSelectedWord(word);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: _WordButton(
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
        const SizedBox(height: 15),
        const Text(
          'Tap the words',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
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
                child: _WordButton(
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
            correctAnswer: _question.english,
          ),
        ],
        const SizedBox(height: 22),
        _primaryButton(
          label: _buildChecked
              ? 'Continue'
              : 'Check Answer',
          onPressed:
          _selectedWords.length ==
              _question.words.length
              ? _checkBuildAnswer
              : null,
          color: color,
        ),
      ],
    );
  }

  Widget _buildSpeakBody() {
    final Color color = Colors.deepPurple;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: <Widget>[
        _TypeLabel(
          label: 'SPEAK',
          color: color,
        ),
        const SizedBox(height: 18),
        const Text(
          'Say this question in English',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withAlpha(17),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            _question.bengali,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 25),
        Center(
          child: InkWell(
            onTap: _isListening
                ? _stopListening
                : _startListening,
            borderRadius: BorderRadius.circular(60),
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: _isListening
                    ? Colors.red
                    : color,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: color.withAlpha(55),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                _isListening
                    ? Icons.stop_rounded
                    : Icons.mic_rounded,
                color: Colors.white,
                size: 46,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            _isListening
                ? 'Listening...'
                : 'Tap the microphone',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
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
              'Recognized: $_recognizedText',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _primaryButton(
          label: 'Submit Answer',
          onPressed: _recognizedText.isEmpty
              ? null
              : _submitSpeaking,
          color: color,
        ),
        if (!_speechAvailable)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Speech service is not available on this device.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
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
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final QuestionMakingActivityType type =
        _currentActivity.type;

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
          Text(
            '${_currentIndex + 1}/${_activities.length}',
            style: const TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 18),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 7,
                  backgroundColor:
                  Colors.black.withAlpha(18),
                  valueColor:
                  AlwaysStoppedAnimation<Color>(
                    widget.topic.color,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  22,
                  20,
                  25,
                ),
                child: type ==
                    QuestionMakingActivityType.learn
                    ? _buildLearnBody()
                    : type ==
                    QuestionMakingActivityType
                        .build
                    ? _buildBuildBody()
                    : _buildSpeakBody(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                16,
              ),
              child: TextButton(
                onPressed: _skipActivity,
                child: const Text(
                  'Skip this question',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
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
    unawaited(_tts.stop());
    _speech.cancel();
    super.dispose();
  }
}

class _TypeLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _TypeLabel({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          label == 'LEARN'
              ? Icons.menu_book_rounded
              : label == 'BUILD'
              ? Icons.extension_rounded
              : Icons.mic_rounded,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
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
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onSound,
            icon: Icon(
              Icons.volume_up_rounded,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WordButton extends StatelessWidget {
  final String word;
  final Color color;

  const _WordButton({
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
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
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

class _FeedbackBox extends StatelessWidget {
  final bool correct;
  final String correctAnswer;

  const _FeedbackBox({
    required this.correct,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
    correct ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withAlpha(70),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            correct
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              correct
                  ? 'Perfect! The question is correct.'
                  : 'Correct: $correctAnswer',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}