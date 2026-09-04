import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/ads/banner_ad_widget.dart'; // <--- BANNER AD IMPORT
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/microphone_disclosure.dart';
import '../services/question_making_audio_service.dart';
import '../services/question_making_funnel.dart';
import '../services/question_making_progress_service.dart';
import '../widgets/question_making_activity.dart';
import '../widgets/question_making_item.dart';
import '../widgets/question_making_topic.dart';
import 'question_result_screen.dart';

class QuestionPracticeScreen extends StatefulWidget {
  final QuestionMakingTopic topic;

  const QuestionPracticeScreen({super.key, required this.topic});

  @override
  State<QuestionPracticeScreen> createState() => _QuestionPracticeScreenState();
}

class _QuestionPracticeScreenState extends State<QuestionPracticeScreen> {
  late final List<QuestionMakingActivity> _activities;
  final stt.SpeechToText _speech = stt.SpeechToText();

  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _skippedAnswers = 0;
  int _earnedXp = 0;

  // Build Variables
  List<String> _selectedWords = <String>[];
  List<String> _availableWords = <String>[];

  // MCQ Variables
  List<String> _mcqOptions = <String>[];
  String _selectedMcqOption = '';

  // Speak Variables
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _speechInitializing = false;
  bool _speechInitializationAttempted = false;
  String _recognizedText = '';

  // State Variables
  bool _isChecked = false;
  bool _isCorrect = false;
  bool _answered = false;

  QuestionMakingActivity get _currentActivity => _activities[_currentIndex];
  QuestionMakingItem get _question => _currentActivity.question;

  double get _progress {
    if (_activities.isEmpty) return 0;
    return ((_currentIndex + 1) / _activities.length).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _activities = QuestionMakingFunnel.createSession(widget.topic);
    _prepareActivity();
    unawaited(QuestionMakingAudioService.initialize());
  }

  Future<bool> _initializeSpeech() async {
    if (_speechInitializing) return _speechAvailable;
    if (!mounted) return false;

    setState(() {
      _speechInitializing = true;
      _speechInitializationAttempted = true;
    });

    try {
      final bool available = await _speech.initialize();
      if (!mounted) return false;
      setState(() {
        _speechAvailable = available;
        _speechInitializing = false;
      });
      return available;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _speechAvailable = false;
        _speechInitializing = false;
      });
      return false;
    }
  }

  void _prepareActivity() {
    final QuestionMakingActivity activity = _currentActivity;

    if (activity.type == QuestionMakingActivityType.build) {
      final List<String> words = List<String>.from(_question.words)..shuffle(Random());
      _selectedWords = <String>[];
      _availableWords = words;
    } else if (activity.type == QuestionMakingActivityType.mcq) {
      final String correctEnglish = _question.english;
      final Set<String> options = <String>{correctEnglish};

      final List<QuestionMakingItem> allQuestions =
      List<QuestionMakingItem>.from(widget.topic.questions)..shuffle(Random());

      for (final QuestionMakingItem q in allQuestions) {
        if (options.length >= 3) break;
        if (q.english != correctEnglish) {
          options.add(q.english);
        }
      }

      _mcqOptions = options.toList()..shuffle(Random());
      _selectedMcqOption = '';
    }

    _isChecked = false;
    _isCorrect = false;
    _answered = false;
    _isListening = false;
    _recognizedText = '';
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll(RegExp(r'[.!?,]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _speak(String text) async {
    await QuestionMakingAudioService.speak(text);
  }

  // ---- LOGIC METHODS ----

  void _selectWord(String word) {
    if (_isChecked) return;
    setState(() {
      _availableWords.remove(word);
      _selectedWords.add(word);
    });
    unawaited(_speak(word));
  }

  void _removeSelectedWord(String word) {
    if (_isChecked) return;
    setState(() {
      _selectedWords.remove(word);
      _availableWords.add(word);
    });
  }

  Future<void> _startListening() async {
    if (_isListening || _speechInitializing || _isChecked) return;

    final bool accepted = await MicrophoneDisclosure.ensureAccepted(context);
    if (!accepted || !mounted) return;

    if (!_speechAvailable) {
      final bool available = await _initializeSpeech();
      if (!available || !mounted) {
        _showMessage('Microphone permission denied.');
        return;
      }
    }

    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    try {
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          localeId: 'en_US',
        ),
        onResult: (stt.SpeechRecognitionResult result) {
          if (!mounted) return;
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      _showMessage('Please try again.');
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _isListening = false;
    });
  }

  void _checkAnswer() async {
    if (_isListening) await _stopListening();

    bool isCorrect = false;

    if (_currentActivity.type == QuestionMakingActivityType.mcq) {
      isCorrect = _selectedMcqOption == _question.english;
    } else if (_currentActivity.type == QuestionMakingActivityType.build) {
      isCorrect = _normalize(_selectedWords.join(' ')) == _normalize(_question.english);
    } else if (_currentActivity.type == QuestionMakingActivityType.speak) {
      final actualWords = _normalize(_recognizedText).split(' ').toSet();
      final expectedWords = _normalize(_question.english).split(' ').toSet();
      final matched = actualWords.intersection(expectedWords).length;
      final score = expectedWords.isEmpty ? 0 : ((matched / expectedWords.length) * 100).round();
      isCorrect = score >= 70; // 70% match
    }

    setState(() {
      _isChecked = true;
      _isCorrect = isCorrect;
    });

    await QuestionMakingAudioService.feedback(correct: isCorrect);
    if (isCorrect) {
      unawaited(_speak(_question.english));
    }
  }

  Future<void> _skipActivity() async {
    if (_isChecked) return;
    if (_isListening) await _stopListening();

    setState(() {
      _skippedAnswers++;
    });

    await QuestionMakingAudioService.speak('Skipped');
    await _processNextStep();
  }

  Future<void> _moveToNext() async {
    if (_isCorrect) {
      _correctAnswers++;
    }
    await _processNextStep();
  }

  Future<void> _processNextStep() async {
    final int earned = await QuestionMakingProgressService.markAttended(
      topicId: widget.topic.id,
      activityId: _currentActivity.id,
    );
    _earnedXp += earned;

    if (!mounted) return;

    if (_currentIndex >= _activities.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => QuestionResultScreen(
            topic: widget.topic,
            totalQuestions: _activities.length,
            correctAnswers: _correctAnswers,
            skippedAnswers: _skippedAnswers,
            earnedXp: _earnedXp,
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex++;
      _prepareActivity();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
  }

  @override
  void dispose() {
    unawaited(QuestionMakingAudioService.stop());
    unawaited(_speech.stop());
    unawaited(_speech.cancel());
    super.dispose();
  }

  // ---- UI BUILDERS ----

  Widget _buildLearnView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Read and understand',
          style: TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _question.bengali,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Color(0xFFE5E5E5), thickness: 2),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _question.english,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ),
                  InkWell(
                    onTap: () => _speak(_question.english),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 28),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMcqView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select the correct translation',
          style: TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 15),
        Text(
          _question.bengali,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 30),
        ..._mcqOptions.map((String option) {
          final bool isSelected = _selectedMcqOption == option;
          final bool isRightAnswer = option == _question.english;

          Color borderColor = const Color(0xFFE5E5E5);
          Color bgColor = Colors.white;
          Color textColor = AppColors.navy;

          if (_isChecked) {
            if (isRightAnswer) {
              borderColor = const Color(0xFF58A700);
              bgColor = const Color(0xFFD7FFB8);
              textColor = const Color(0xFF58A700);
            } else if (isSelected && !isRightAnswer) {
              borderColor = const Color(0xFFEA2B2B);
              bgColor = const Color(0xFFFFDFE0);
              textColor = const Color(0xFFEA2B2B);
            }
          } else if (isSelected) {
            borderColor = AppColors.primary;
            bgColor = AppColors.primary.withAlpha(15);
            textColor = AppColors.primary;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: _isChecked ? null : () => setState(() => _selectedMcqOption = option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2),
                  // 3D Effect
                  boxShadow: [
                    if (!isSelected && !_isChecked)
                      BoxShadow(
                        color: const Color(0xFFE5E5E5),
                        offset: const Offset(0, 4),
                      )
                    else if (isSelected && !_isChecked)
                      BoxShadow(
                        color: AppColors.primary.withAlpha(80),
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBuildView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Translate this sentence',
          style: TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _question.bengali,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
            IconButton(
              onPressed: () => _speak(_question.english),
              icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Dropzone Area
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isChecked
                  ? (_isCorrect ? const Color(0xFF58A700) : const Color(0xFFEA2B2B))
                  : const Color(0xFFE5E5E5),
              width: 2,
            ),
          ),
          child: _selectedWords.isEmpty
              ? const Center(
            child: Text(
              'Tap words to build',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
              : Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _selectedWords.map((word) => GestureDetector(
              onTap: () => _removeSelectedWord(word),
              child: _Word3DChip(word: word, isSelected: false),
            )).toList(),
          ),
        ),
        const SizedBox(height: 30),
        // Available Words
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: _availableWords.map((word) => GestureDetector(
            onTap: () => _selectWord(word),
            child: _Word3DChip(word: word, isSelected: false),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSpeakView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Speak this sentence',
            style: TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
          ),
          child: Column(
            children: [
              Text(
                _question.bengali,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 15),
              Text(
                _question.english,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.navy),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
        GestureDetector(
          onTap: _isChecked ? null : (_isListening ? _stopListening : _startListening),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isListening ? 140 : 120,
            height: _isListening ? 140 : 120,
            decoration: BoxDecoration(
              color: _isListening ? Colors.red : AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? Colors.red : AppColors.primary).withAlpha(60),
                  blurRadius: _isListening ? 30 : 10,
                  spreadRadius: _isListening ? 10 : 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded, color: Colors.white, size: 55),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          _speechInitializing ? 'Preparing mic...' : _isListening ? 'Listening... Tap to stop' : 'Tap the microphone to speak',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (_recognizedText.isNotEmpty) ...[
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text('You said: $_recognizedText', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy)),
          ),
        ]
      ],
    );
  }

  // --- PREMIUM BOTTOM BAR UI ---
  Widget _buildBottomBar() {
    final bool isLearn = _currentActivity.type == QuestionMakingActivityType.learn;

    // Learn Screen Button
    if (isLearn) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 2)),
        ),
        child: _ChunkyButton(
          label: 'Continue',
          color: AppColors.primary,
          shadowColor: const Color(0xFF1B6E96), // Darker primary
          onPressed: () {
            _isCorrect = true;
            _moveToNext();
          },
        ),
      );
    }

    // Unchecked State Button
    if (!_isChecked) {
      final bool canCheck = (_currentActivity.type == QuestionMakingActivityType.mcq && _selectedMcqOption.isNotEmpty) ||
          (_currentActivity.type == QuestionMakingActivityType.build && _selectedWords.length == _question.words.length) ||
          (_currentActivity.type == QuestionMakingActivityType.speak && _recognizedText.isNotEmpty);
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E5E5), width: 2)),
        ),
        child: _ChunkyButton(
          label: 'Check Answer',
          color: canCheck ? AppColors.primary : const Color(0xFFE5E5E5),
          shadowColor: canCheck ? const Color(0xFF1B6E96) : const Color(0xFFC0C0C0),
          textColor: canCheck ? Colors.white : const Color(0xFFAFAFAF),
          onPressed: canCheck ? _checkAnswer : null,
        ),
      );
    }

    // Checked State (Correct/Wrong) Panel
    final bgColor = _isCorrect ? const Color(0xFFD7FFB8) : const Color(0xFFFFDFE0);
    final textColor = _isCorrect ? const Color(0xFF58A700) : const Color(0xFFEA2B2B);
    final buttonColor = _isCorrect ? const Color(0xFF58A700) : const Color(0xFFEA2B2B);
    final buttonShadow = _isCorrect ? const Color(0xFF468500) : const Color(0xFFC11818);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isCorrect ? Icons.check_rounded : Icons.close_rounded,
                  color: textColor,
                  size: 24,
                  weight: 900,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isCorrect ? 'Excellent!' : 'Correct solution:',
                style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          if (!_isCorrect) ...[
            const SizedBox(height: 10),
            Text(
              _question.english,
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
          const SizedBox(height: 24),
          _ChunkyButton(
            label: _isCorrect ? 'Continue' : 'Got it',
            color: buttonColor,
            shadowColor: buttonShadow,
            onPressed: _isCorrect ? _moveToNext : () {
              setState(() {
                _isChecked = false;
                _selectedMcqOption = '';
                _selectedWords.clear();
                _availableWords = List.from(_question.words)..shuffle();
                _recognizedText = '';
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_activities.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final type = _currentActivity.type;
    final Widget content = type == QuestionMakingActivityType.learn
        ? _buildLearnView()
        : type == QuestionMakingActivityType.mcq
        ? _buildMcqView()
        : type == QuestionMakingActivityType.build
        ? _buildBuildView()
        : _buildSpeakView();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 14,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E5E5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              // Add a nice light reflection effect
              child: Container(
                margin: const EdgeInsets.only(top: 2, left: 6, right: 6, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(70),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _skipActivity,
            child: const Text('SKIP', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w900)),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- STICKY BANNER AD START ---
            const BannerAdWidget(),
            // --- STICKY BANNER AD END ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                physics: const BouncingScrollPhysics(),
                child: content,
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }
}

// ---- CUSTOM WIDGETS FOR PREMIUM UI ----

class _Word3DChip extends StatelessWidget {
  final String word;
  final bool isSelected;

  const _Word3DChip({required this.word, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE5E5E5),
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(
        word,
        style: const TextStyle(
            color: AppColors.navy,
            fontSize: 18,
            fontWeight: FontWeight.w800
        ),
      ),
    );
  }
}

class _ChunkyButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final VoidCallback? onPressed;

  const _ChunkyButton({
    required this.label,
    required this.color,
    required this.shadowColor,
    this.textColor = Colors.white,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0, // We use custom border for 3D effect
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide.none,
          ),
        ).copyWith(
          // Simulate 3D Bottom Border
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed) || onPressed == null) {
              return BorderSide(color: Colors.transparent, width: 0);
            }
            return BorderSide(color: shadowColor, width: 4); // Bottom shadow
          }),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0), // Adjust text position
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}