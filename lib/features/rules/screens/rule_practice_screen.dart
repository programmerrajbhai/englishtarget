import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/microphone_disclosure.dart';
import '../models/rule_content.dart';
import '../models/rule_progress.dart';
import '../models/rules_data.dart';
import '../repositories/rules_repository.dart';
import '../services/rules_progress_service.dart';
import 'rule_details_screen.dart';

class RulePracticeScreen extends StatefulWidget {
  const RulePracticeScreen({
    super.key,
    required this.rule,
  });

  final RuleContent rule;

  @override
  State<RulePracticeScreen> createState() => _RulePracticeScreenState();
}

class _RulePracticeScreenState extends State<RulePracticeScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  int _currentIndex = 0;
  String _transcript = '';
  int? _matchScore;

  bool _isListening = false;
  bool _speechReady = false;
  bool _isInitializing = false;
  bool _isSaving = false;
  bool _isChecking = false;
  bool _resultShowing = false;

  final Set<int> _attendedIndexes = <int>{};
  final Set<int> _correctIndexes = <int>{};
  final Set<int> _skippedIndexes = <int>{};

  List<SpeakingTest> get _practices {
    return widget.rule.speakingTests.take(5).toList();
  }

  SpeakingTest get _currentPractice {
    return _practices[_currentIndex];
  }

  bool get _isFirst => _currentIndex == 0;
  bool get _isLast => _currentIndex == _practices.length - 1;

  bool get _currentCompleted {
    return _attendedIndexes.contains(_currentIndex) ||
        _skippedIndexes.contains(_currentIndex);
  }

  bool get _allCompleted {
    return _attendedIndexes.length + _skippedIndexes.length ==
        _practices.length;
  }

  int get _correctAnswers => _correctIndexes.length;

  int get _attendedPercent {
    if (_practices.isEmpty) return 0;
    return ((_attendedIndexes.length / _practices.length) * 100).round();
  }

  int get _skippedPercent {
    if (_practices.isEmpty) return 0;
    return ((_skippedIndexes.length / _practices.length) * 100).round();
  }

  @override
  void initState() {
    super.initState();
    _setupTts();
    _initializeSpeech();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.40);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> _initializeSpeech() async {
    if (_isInitializing) return;
    setState(() => _isInitializing = true);

    try {
      final bool ready = await _speech.initialize(
        onStatus: (String status) {
          if (!mounted) return;
          setState(() {
            if (status == 'done' || status == 'notListening') {
              _isListening = false;
            } else if (status == 'listening') {
              _isListening = true;
            }
          });
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _speechReady = ready;
        _isInitializing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _speechReady = false;
        _isInitializing = false;
      });
    }
  }

  Future<void> _listenFirst() async {
    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.speak(_currentPractice.expectedAnswer);
  }

  Future<void> _toggleMicrophone() async {
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }

    if (_isInitializing) return;

    final bool accepted = await MicrophoneDisclosure.ensureAccepted(context);
    if (!accepted || !mounted) return;

    if (!_speechReady) {
      await _initializeSpeech();
      if (!mounted) return;

      if (!_speechReady) {
        _showMessage('Microphone permission denied or speech service unavailable.');
        return;
      }
    }

    await _tts.stop();
    if (!mounted) return;

    setState(() {
      _transcript = '';
      _matchScore = null;
    });

    try {
      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: false,
          localeId: 'en_US',
        ),
        onResult: (stt.SpeechRecognitionResult result) {
          if (!mounted) return;
          setState(() {
            _transcript = result.recognizedWords;
            if (result.finalResult) {
              _isListening = false;
            }
          });
        },
      );

      if (!mounted) return;
      setState(() => _isListening = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isListening = false);
      _showMessage('Speaking practice শুরু করা যায়নি।');
    }
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll(RegExp(r"[^a-z0-9']+"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int _calculateScore({
    required String spoken,
    required SpeakingTest practice,
  }) {
    final String actual = _normalize(spoken);
    if (actual.isEmpty) return 0;

    final List<String> accepted = <String>[
      practice.expectedAnswer,
      ...practice.acceptedAnswers,
    ];

    int highestScore = 0;

    for (final String answer in accepted) {
      final String expected = _normalize(answer);

      if (actual == expected || actual.contains(expected)) {
        return 100;
      }

      final List<String> actualWords = actual.split(' ')..removeWhere((w) => w.isEmpty);
      final List<String> expectedWords = expected.split(' ')..removeWhere((w) => w.isEmpty);

      if (expectedWords.isEmpty) continue;

      int matchCount = 0;
      List<String> tempActual = List.from(actualWords);

      for (String eWord in expectedWords) {
        int idx = tempActual.indexOf(eWord);
        if (idx != -1) {
          matchCount++;
          tempActual.removeAt(idx);
        }
      }

      final int lengthDifference = (actual.length - expected.length).abs();
      final int lengthScore = (100 - lengthDifference * 2).clamp(0, 100);

      final int score = (((matchCount / expectedWords.length) * 75) + (lengthScore * 0.25)).round().clamp(0, 100);

      if (score > highestScore) {
        highestScore = score;
      }
    }

    return highestScore;
  }

  Future<void> _checkSentence() async {
    if (_isChecking) return;

    if (_transcript.trim().isEmpty) {
      _showMessage('আগে microphone-এ sentence বলুন।');
      return;
    }

    await _speech.stop();

    final int score = _calculateScore(
      spoken: _transcript,
      practice: _currentPractice,
    );

    final bool correct = score >= 70;

    setState(() {
      _isChecking = true;
      _matchScore = score;

      if (correct) {
        // Only mark as attended if correct
        _attendedIndexes.add(_currentIndex);
        _correctIndexes.add(_currentIndex);
        _skippedIndexes.remove(_currentIndex);
      } else {
        // If wrong, force them to retry or skip (Next is blocked)
        _attendedIndexes.remove(_currentIndex);
        _correctIndexes.remove(_currentIndex);
      }
    });

    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.speak(correct ? 'Correct. Well done.' : 'Not correct. Try again.');

    if (!mounted) return;
    setState(() => _isChecking = false);
  }

  Future<void> _skipPractice() async {
    await _speech.stop();
    await _tts.stop();

    setState(() {
      _skippedIndexes.add(_currentIndex);
      _attendedIndexes.remove(_currentIndex);
      _correctIndexes.remove(_currentIndex);

      _transcript = '';
      _matchScore = null;
    });

    if (!_isLast) {
      setState(() => _currentIndex++);
    } else {
      await _finishPractice();
    }
  }

  Future<void> _previousPractice() async {
    if (_isFirst) return;

    await _speech.stop();
    await _tts.stop();

    setState(() {
      _currentIndex--;
      _transcript = '';
      _matchScore = null;
    });
  }

  Future<void> _nextPractice() async {
    if (!_currentCompleted) {
      if (_matchScore != null && _matchScore! < 70) {
        _showMessage('সঠিক উত্তর দিন অথবা Skip করুন।');
      } else {
        _showMessage('আগে Sentence-টি বলুন অথবা Skip করুন।');
      }
      return;
    }

    await _speech.stop();
    await _tts.stop();

    if (_isLast) {
      if (_allCompleted) {
        await _finishPractice();
      }
      return;
    }

    setState(() {
      _currentIndex++;
      _transcript = '';
      _matchScore = null;
    });
  }

  Future<void> _finishPractice() async {
    if (_isSaving || _resultShowing) return;

    if (!_allCompleted) {
      _showMessage('সব sentence attend অথবা skip করুন।');
      return;
    }

    setState(() => _isSaving = true);

    final int total = _practices.length;
    // Strict passing logic (must get at least 60% correct to unlock next rule)
    final bool passed = (_correctAnswers / total) >= 0.60;

    if (passed) {
      await RulesProgressService.completeSpeaking(
        ruleId: widget.rule.id,
        correctAnswers: _correctAnswers,
      );
    } else {
      await RulesProgressService.saveSpeakingResult(
        ruleId: widget.rule.id,
        correctAnswers: _correctAnswers,
        totalQuestions: total,
      );
    }

    if (!mounted) return;

    final RuleProgress progress = await RulesProgressService.getRuleProgress(
      widget.rule.id,
    );

    setState(() {
      _isSaving = false;
      _resultShowing = true;
    });

    await _showResult(progress, passed);
  }

  RuleContent? _getNextRule() {
    final int currentIndex = RulesData.rules.indexWhere(
          (rule) => rule.id == widget.rule.id,
    );

    if (currentIndex == -1 || currentIndex + 1 >= RulesData.rules.length) {
      return null;
    }

    final String nextId = RulesData.rules[currentIndex + 1].id;
    return RulesRepository.findById(nextId);
  }

  Future<void> _showResult(RuleProgress progress, bool passed) async {
    final RuleContent? nextRule = _getNextRule();

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  passed ? Icons.stars_rounded : Icons.cancel_rounded,
                  color: passed ? AppColors.primary : AppColors.error,
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  passed ? 'Practice Completed!' : 'Practice Failed!',
                  style: TextStyle(
                    color: passed ? AppColors.navy : AppColors.error,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Score: $_correctAnswers/${_practices.length} Correct',
                  style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  passed
                      ? 'Great job! You can move to the next level.'
                      : 'You need at least 60% correct to pass. Please try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    setState(() {
                      _currentIndex = 0;
                      _transcript = '';
                      _matchScore = null;
                      _attendedIndexes.clear();
                      _correctIndexes.clear();
                      _skippedIndexes.clear();
                      _resultShowing = false;
                    });
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Practice Again'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: passed
                      ? () {
                    Navigator.pop(sheetContext);
                    if (nextRule == null) {
                      Navigator.pop(context, true);
                      return;
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RuleDetailsScreen(rule: nextRule),
                      ),
                    );
                  }
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(nextRule == null ? 'Back to Rules' : 'Next Level'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFD9E2DD),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (mounted) {
      setState(() => _resultShowing = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_practices.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Speaking practice add করা হয়নি।')),
      );
    }

    final SpeakingTest practice = _currentPractice;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Rule Practice',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Progress Bar Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _practices.length,
                        minHeight: 8,
                        color: AppColors.primary,
                        backgroundColor: const Color(0xFFE1E8E4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentIndex + 1}/${_practices.length}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy),
                  ),
                ],
              ),
            ),

            // MAIN CARD CONTENT AREA
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.mint,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withAlpha(50)),
                          ),
                          child: Text(
                            'Category: ${widget.rule.title}',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Prompt Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: practice.visualColor.withAlpha(60), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: practice.visualColor.withAlpha(20),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: practice.visualColor.withAlpha(25),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(practice.visualIcon, color: practice.visualColor, size: 32),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'বলুন:',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                practice.instruction,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900, height: 1.3),
                              ),
                              const SizedBox(height: 24),
                              OutlinedButton.icon(
                                onPressed: _listenFirst,
                                icon: const Icon(Icons.volume_up_rounded, size: 18),
                                label: const Text('Listen Pronunciation'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.navy,
                                  side: const BorderSide(color: AppColors.border),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Hint Box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7FF),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFCFE1F6)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_rounded, color: AppColors.amber, size: 20),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Hint: স্পষ্ট উচ্চারণে স্বাভাবিক গতিতে বলুন।',
                                  style: TextStyle(color: AppColors.navy, fontSize: 12.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // FIXED BOTTOM INTERACTION DYNAMIC PANEL
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withAlpha(15),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Show Result if checked
                  if (_matchScore != null) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _matchScore! >= 70 ? AppColors.mint : const Color(0xFFFFF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _matchScore! >= 70 ? AppColors.primary.withAlpha(50) : AppColors.error.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _matchScore! >= 70 ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                            color: _matchScore! >= 70 ? AppColors.primary : AppColors.error,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _matchScore! >= 70 ? 'Awesome! Correct ($_matchScore% match)' : 'Keep trying! Accuracy: $_matchScore%',
                            style: TextStyle(
                              color: _matchScore! >= 70 ? AppColors.primary : AppColors.error,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 2. Transcript text
                  if (_transcript.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '"$_transcript"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.navy, fontSize: 16, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],

                  // 3. Dynamic Controls Logic
                  if (_matchScore != null && _matchScore! >= 70) ...[
                    // CORRECT STATE -> User must tap Next
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Tap Next to continue',
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ] else if (_transcript.isNotEmpty && !_isListening && _matchScore == null) ...[
                    // WAITING TO BE CHECKED STATE
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _toggleMicrophone,
                          icon: const Icon(Icons.mic_rounded),
                          label: const Text('Retry'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isChecking ? null : _checkSentence,
                            icon: const Icon(Icons.check_rounded, size: 20),
                            label: const Text('Check Answer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // INITIAL, LISTENING, OR WRONG STATE -> Show Big Mic to speak/retry
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? AppColors.error : AppColors.primary).withAlpha(80),
                            blurRadius: _isListening ? 20 : 12,
                            spreadRadius: _isListening ? 4 : 0,
                          ),
                        ],
                      ),
                      child: IconButton.filled(
                        onPressed: _isInitializing ? null : _toggleMicrophone,
                        style: IconButton.styleFrom(
                          backgroundColor: _isListening ? AppColors.error : AppColors.primary,
                          fixedSize: const Size(68, 68),
                        ),
                        icon: _isInitializing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Icon(
                          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isListening
                          ? 'Listening carefully... বলুন'
                          : (_matchScore != null && _matchScore! < 70)
                          ? 'Tap microphone to try again'
                          : 'Tap microphone to speak',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ]
                ],
              ),
            ),

            // FIXED BOTTOM NAVIGATION (Previous, Skip, Next)
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isFirst ? null : _previousPractice,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Previous', style: TextStyle(fontWeight: FontWeight.w800)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: _isSaving ? null : _skipPractice,
                      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                      child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _nextPractice,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(_isLast ? 'Submit' : 'Next', style: const TextStyle(fontWeight: FontWeight.w800)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
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