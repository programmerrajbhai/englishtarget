import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/constants/app_colors.dart';
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
  State<RulePracticeScreen> createState() =>
      _RulePracticeScreenState();
}

class _RulePracticeScreenState
    extends State<RulePracticeScreen> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech =
  stt.SpeechToText();

  int _currentIndex = 0;

  String _transcript = '';
  int? _matchScore;

  bool _isListening = false;
  bool _speechReady = false;
  bool _isInitializing = true;
  bool _isSaving = false;
  bool _isChecking = false;
  bool _resultShowing = false;

  final Set<int> _attendedIndexes = <int>{};
  final Set<int> _correctIndexes = <int>{};
  final Set<int> _skippedIndexes = <int>{};

  List<SpeakingTest> get _practices {
    return widget.rule.speakingTests
        .take(5)
        .toList();
  }

  SpeakingTest get _currentPractice {
    return _practices[_currentIndex];
  }

  bool get _isFirst {
    return _currentIndex == 0;
  }

  bool get _isLast {
    return _currentIndex ==
        _practices.length - 1;
  }

  bool get _currentCompleted {
    return _attendedIndexes.contains(
      _currentIndex,
    ) ||
        _skippedIndexes.contains(
          _currentIndex,
        );
  }

  bool get _allCompleted {
    return _attendedIndexes.length +
        _skippedIndexes.length ==
        _practices.length;
  }

  int get _correctAnswers {
    return _correctIndexes.length;
  }

  int get _attendedPercent {
    if (_practices.isEmpty) return 0;

    return ((_attendedIndexes.length /
        _practices.length) *
        100)
        .round();
  }

  int get _skippedPercent {
    if (_practices.isEmpty) return 0;

    return ((_skippedIndexes.length /
        _practices.length) *
        100)
        .round();
  }

  @override
  void initState() {
    super.initState();

    _setupTts();
    _initializeSpeech();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> _initializeSpeech() async {
    try {
      final bool ready =
      await _speech.initialize(
        onStatus: (String status) {
          if (!mounted) return;

          setState(() {
            _isListening =
                status == 'listening';
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

    await _tts.speak(
      _currentPractice.expectedAnswer,
    );
  }

  Future<void> _toggleMicrophone() async {
    if (_isInitializing) return;

    if (!_speechReady) {
      await _initializeSpeech();

      if (!_speechReady) {
        _showMessage(
          'Microphone permission allow করুন।',
        );
        return;
      }
    }

    if (_isListening) {
      await _speech.stop();

      if (!mounted) return;

      setState(() {
        _isListening = false;
      });

      return;
    }

    await _tts.stop();

    setState(() {
      _transcript = '';
      _matchScore = null;
    });

    await _speech.listen(
      onResult:
          (stt.SpeechRecognitionResult result) {
        if (!mounted) return;

        setState(() {
          _transcript =
              result.recognizedWords;
        });
      },
      listenFor: const Duration(
        seconds: 12,
      ),
      pauseFor: const Duration(
        seconds: 3,
      ),
      partialResults: true,
      cancelOnError: true,
      localeId: 'en_US',
    );

    if (!mounted) return;

    setState(() {
      _isListening = true;
    });
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll(
      RegExp(r"[^a-z0-9']+"),
      ' ',
    )
        .replaceAll(
      RegExp(r'\s+'),
      ' ',
    )
        .trim();
  }

  int _calculateScore({
    required String spoken,
    required SpeakingTest practice,
  }) {
    final String actual =
    _normalize(spoken);

    if (actual.isEmpty) return 0;

    final List<String> accepted = <String>[
      practice.expectedAnswer,
      ...practice.acceptedAnswers,
    ];

    int highestScore = 0;

    for (final String answer in accepted) {
      final String expected =
      _normalize(answer);

      if (actual == expected) {
        return 100;
      }

      final List<String> actualWords =
      actual.split(' ');

      final List<String> expectedWords =
      expected.split(' ');

      if (expectedWords.isEmpty) {
        continue;
      }

      final int matchedWords = actualWords
          .toSet()
          .intersection(expectedWords.toSet())
          .length;

      final int lengthDifference =
      (actual.length - expected.length)
          .abs();

      final int lengthScore =
      (100 - lengthDifference * 2)
          .clamp(0, 100);

      final int score = (((matchedWords /
          expectedWords.length) *
          75) +
          (lengthScore * 0.25))
          .round()
          .clamp(0, 100);

      if (score > highestScore) {
        highestScore = score;
      }
    }

    return highestScore;
  }

  Future<void> _checkSentence() async {
    if (_isChecking) return;

    if (_transcript.trim().isEmpty) {
      _showMessage(
        'আগে microphone-এ sentence বলুন।',
      );
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

      _attendedIndexes.add(_currentIndex);
      _skippedIndexes.remove(_currentIndex);

      if (correct) {
        _correctIndexes.add(_currentIndex);
      } else {
        _correctIndexes.remove(_currentIndex);
      }
    });

    await _tts.stop();

    await _tts.speak(
      correct
          ? 'Correct. Well done.'
          : 'Not correct. Try again.',
    );

    if (!mounted) return;

    setState(() {
      _isChecking = false;
    });
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
      setState(() {
        _currentIndex++;
      });
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
      _showMessage(
        'Sentence বলুন অথবা Skip করুন।',
      );
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
    if (_isSaving || _resultShowing) {
      return;
    }

    if (!_allCompleted) {
      _showMessage(
        'সব sentence attend অথবা skip করুন।',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final int total = _practices.length;

    await RulesProgressService.saveSpeakingResult(
      ruleId: widget.rule.id,
      correctAnswers: _correctAnswers,
      totalQuestions: total,
    );

    await RulesProgressService.completeSpeaking(
      ruleId: widget.rule.id,
      correctAnswers: _correctAnswers,
    );

    if (!mounted) return;

    final RuleProgress progress =
    await RulesProgressService.getRuleProgress(
      widget.rule.id,
    );

    setState(() {
      _isSaving = false;
      _resultShowing = true;
    });

    await _showResult(progress);
  }

  RuleContent? _getNextRule() {
    final int currentIndex =
    RulesData.rules.indexWhere(
          (rule) => rule.id == widget.rule.id,
    );

    if (currentIndex == -1 ||
        currentIndex + 1 >=
            RulesData.rules.length) {
      return null;
    }

    final String nextId =
        RulesData.rules[currentIndex + 1].id;

    return RulesRepository.findById(nextId);
  }



  Future<void> _showResult(
      RuleProgress progress,
      ) async {
    final RuleContent? nextRule = _getNextRule();

    final bool currentRuleCompleted =
        progress.isCompleted;

    final bool canGoNext =
        currentRuleCompleted;

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              22,
              26,
              22,
              18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                  size: 58,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Practice Submitted!',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Correct: $_correctAnswers/${_practices.length}',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Attended: $_attendedPercent%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Skipped: $_skippedPercent%',
                  style: const TextStyle(
                    color: AppColors.amber,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Rule Progress: ${progress.percentage}%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 20),

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
                  icon: const Icon(
                    Icons.replay_rounded,
                  ),
                  label: const Text(
                    'Practice Again',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                    AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                    ),
                    minimumSize:
                    const Size.fromHeight(52),
                  ),
                ),

                const SizedBox(height: 10),

                FilledButton.icon(
                  onPressed: canGoNext
                      ? () {
                    Navigator.pop(sheetContext);

                    if (nextRule == null) {
                      // Next content এখনো add হয়নি,
                      // তাই Rules list-এ ফিরে যাবে।
                      Navigator.pop(context, true);
                      return;
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return RuleDetailsScreen(
                            rule: nextRule,
                          );
                        },
                      ),
                    );
                  }
                      : null,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                  ),
                  label: Text(
                    nextRule == null
                        ? 'Back to Rules'
                        : 'Next Level',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                    AppColors.primary,
                    disabledBackgroundColor:
                    const Color(0xFFD9E2DD),
                    minimumSize:
                    const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (mounted) {
      setState(() {
        _resultShowing = false;
      });
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
        body: Center(
          child: Text(
            'Speaking practice add করা হয়নি।',
          ),
        ),
      );
    }

    final SpeakingTest practice =
        _currentPractice;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Rule Practice',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                8,
                18,
                14,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                      BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) /
                            _practices.length,
                        minHeight: 8,
                        color: AppColors.primary,
                        backgroundColor:
                        const Color(0xFFE1E8E4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_currentIndex + 1}/${_practices.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  4,
                  18,
                  22,
                ),
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius:
                      BorderRadius.circular(13),
                      border: Border.all(
                        color:
                        AppColors.primary.withAlpha(
                          45,
                        ),
                      ),
                    ),
                    child: Text(
                      'Using: ${widget.rule.title}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color:
                      practice.visualColor.withAlpha(
                        20,
                      ),
                      borderRadius:
                      BorderRadius.circular(22),
                      border: Border.all(
                        color:
                        practice.visualColor.withAlpha(
                          70,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor:
                          practice.visualColor,
                          child: Icon(
                            practice.visualIcon,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          practice.instruction,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _listenFirst,
                          icon: const Icon(
                            Icons.volume_up_rounded,
                          ),
                          label: const Text(
                            'Listen first',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _isListening
                          ? AppColors.mint
                          : Colors.white,
                      borderRadius:
                      BorderRadius.circular(22),
                      border: Border.all(
                        color: _isListening
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        IconButton.filled(
                          onPressed: _isInitializing
                              ? null
                              : _toggleMicrophone,
                          style: IconButton.styleFrom(
                            backgroundColor: _isListening
                                ? AppColors.error
                                : AppColors.primary,
                            fixedSize:
                            const Size(82, 82),
                          ),
                          icon: _isInitializing
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : Icon(
                            _isListening
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            color: Colors.white,
                            size: 39,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          _isListening
                              ? 'Listening… বলুন'
                              : 'Tap and speak',
                          style: const TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_transcript.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            _transcript,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: _isChecking
                                ? null
                                : _checkSentence,
                            icon: const Icon(
                              Icons.check_rounded,
                            ),
                            label: const Text(
                              'Check sentence',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius:
                      BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFCFE1F6),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.amber,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'Hint: ${widget.rule.title} rule মনে রেখে ধীরে বলুন।',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_matchScore != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding:
                      const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _matchScore! >= 70
                            ? AppColors.mint
                            : const Color(0xFFFFF2F2),
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _matchScore! >= 70
                                ? Icons.check_circle_rounded
                                : Icons.replay_rounded,
                            color: _matchScore! >= 70
                                ? AppColors.primary
                                : AppColors.error,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            _matchScore! >= 70
                                ? 'Correct • $_matchScore%'
                                : 'Try again • $_matchScore%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                18,
                10,
                18,
                12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isFirst
                            ? null
                            : _previousPractice,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                        ),
                        label: const Text(
                          'Previous',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _isSaving
                          ? null
                          : _skipPractice,
                      icon: const Icon(
                        Icons.skip_next_rounded,
                      ),
                      label: const Text('Skip'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isSaving
                            ? null
                            : _nextPractice,
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                        ),
                        label: Text(
                          _isLast
                              ? 'Submit'
                              : 'Next',
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