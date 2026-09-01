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

  // 100% FIXED: Storing state PER QUESTION so going 'Back' works perfectly
  final Map<int, String> _transcripts = {};
  final Map<int, int> _matchScores = {};

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

  String get _currentTranscript => _transcripts[_currentIndex] ?? '';
  int? get _currentMatchScore => _matchScores[_currentIndex];

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
      _transcripts[_currentIndex] = '';
      _matchScores.remove(_currentIndex);
      _attendedIndexes.remove(_currentIndex);
      _correctIndexes.remove(_currentIndex);
      _skippedIndexes.remove(_currentIndex);
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
            _transcripts[_currentIndex] = result.recognizedWords;
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

    if (_currentTranscript.trim().isEmpty) {
      _showMessage('আগে microphone-এ sentence বলুন।');
      return;
    }

    await _speech.stop();

    final int score = _calculateScore(
      spoken: _currentTranscript,
      practice: _currentPractice,
    );

    final bool correct = score >= 70;

    setState(() {
      _isChecking = true;
      _matchScores[_currentIndex] = score;

      _skippedIndexes.remove(_currentIndex);

      if (correct) {
        _attendedIndexes.add(_currentIndex);
        _correctIndexes.add(_currentIndex);
      } else {
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
    });
  }

  Future<void> _nextPractice() async {
    if (!_currentCompleted) {
      if (_currentMatchScore != null && _currentMatchScore! < 70) {
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
    });
  }

  Future<void> _finishPractice() async {
    if (_isSaving || _resultShowing) return;

    if (!_allCompleted) {
      _showMessage('সবগুলো sentence attend অথবা skip করুন।');
      return;
    }

    setState(() => _isSaving = true);

    final int total = _practices.length;
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
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  passed ? Icons.stars_rounded : Icons.cancel_rounded,
                  color: passed ? AppColors.primary : AppColors.error,
                  size: 68,
                ),
                const SizedBox(height: 16),
                Text(
                  passed ? 'Practice Completed!' : 'Practice Failed!',
                  style: TextStyle(
                    color: passed ? AppColors.navy : AppColors.error,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Score: $_correctAnswers/${_practices.length} Correct',
                  style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 17,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  passed
                      ? 'Great job! You can move to the next level.'
                      : 'You need at least 60% correct to pass. Please try again.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    setState(() {
                      _currentIndex = 0;
                      _transcripts.clear();
                      _matchScores.clear();
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
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                ),
                const SizedBox(height: 12),
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
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
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
      return Scaffold(
        appBar: AppBar(title: const Text('Practice')),
        body: const Center(child: Text('Speaking practice add করা হয়নি।')),
      );
    }

    final SpeakingTest practice = _currentPractice;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Premium off-white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Rule Practice',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.3),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Progress Bar Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _practices.length,
                        minHeight: 8,
                        color: AppColors.primary,
                        backgroundColor: const Color(0xFFE1E8E4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    '${_currentIndex + 1} / ${_practices.length}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.navy, fontSize: 15),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      children: [
                        // Category Label
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.mint,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withAlpha(40)),
                          ),
                          child: Text(
                            'Category: ${widget.rule.title}',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Prompt Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: practice.visualColor.withAlpha(50), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: practice.visualColor.withAlpha(15),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: practice.visualColor.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(practice.visualIcon, color: practice.visualColor, size: 36),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'বলুন:',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                practice.instruction,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.navy, fontSize: 24, fontWeight: FontWeight.w900, height: 1.3),
                              ),
                              const SizedBox(height: 28),
                              OutlinedButton.icon(
                                onPressed: _listenFirst,
                                icon: const Icon(Icons.volume_up_rounded, size: 20),
                                label: const Text('Listen Pronunciation', style: TextStyle(fontWeight: FontWeight.w700)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.navy,
                                  side: const BorderSide(color: AppColors.border, width: 1.5),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Hint Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F7FF),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFCFE1F6)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lightbulb_rounded, color: AppColors.amber, size: 22),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Hint: স্পষ্ট উচ্চারণে স্বাভাবিক গতিতে বলুন।',
                                  style: TextStyle(color: AppColors.navy, fontSize: 13.5, fontWeight: FontWeight.w700),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navy.withAlpha(10),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Show Result if checked
                  if (_currentMatchScore != null) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: _currentMatchScore! >= 70 ? AppColors.mint : const Color(0xFFFFF2F2),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _currentMatchScore! >= 70 ? AppColors.primary.withAlpha(40) : AppColors.error.withAlpha(40),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _currentMatchScore! >= 70 ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                            color: _currentMatchScore! >= 70 ? AppColors.primary : AppColors.error,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _currentMatchScore! >= 70 ? 'Awesome! Correct ($_currentMatchScore% match)' : 'Keep trying! Accuracy: $_currentMatchScore%',
                            style: TextStyle(
                              color: _currentMatchScore! >= 70 ? AppColors.primary : AppColors.error,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 2. Transcript text
                  if (_currentTranscript.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '"$_currentTranscript"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.navy, fontSize: 17, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],

                  // 3. Dynamic Controls Logic
                  if (_currentMatchScore != null && _currentMatchScore! >= 70) ...[
                    // CORRECT STATE -> User must tap Next
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text(
                        'Tap Next to continue',
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ] else if (_currentTranscript.isNotEmpty && !_isListening && _currentMatchScore == null) ...[
                    // WAITING TO BE CHECKED STATE
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _toggleMicrophone,
                          icon: const Icon(Icons.mic_rounded),
                          label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.w800)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.navy,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _isChecking ? null : _checkSentence,
                            icon: const Icon(Icons.check_rounded, size: 22),
                            label: const Text('Check Answer', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900)),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                            color: (_isListening ? AppColors.error : AppColors.primary).withAlpha(60),
                            blurRadius: _isListening ? 25 : 15,
                            spreadRadius: _isListening ? 5 : 0,
                          ),
                        ],
                      ),
                      child: IconButton.filled(
                        onPressed: _isInitializing ? null : _toggleMicrophone,
                        style: IconButton.styleFrom(
                          backgroundColor: _isListening ? AppColors.error : AppColors.primary,
                          fixedSize: const Size(76, 76),
                        ),
                        icon: _isInitializing
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                            : Icon(
                          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _isListening
                          ? 'Listening carefully... বলুন'
                          : (_currentMatchScore != null && _currentMatchScore! < 70)
                          ? 'Tap microphone to try again'
                          : 'Tap microphone to speak',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ]
                ],
              ),
            ),

            // FIXED BOTTOM NAVIGATION (Previous, Skip, Next)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F7FA),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isFirst ? null : _previousPractice,
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        label: const Text('Previous', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _isSaving ? null : _skipPractice,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      child: const Text('Skip', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _nextPractice,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: Text(_isLast ? 'Submit' : 'Next', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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