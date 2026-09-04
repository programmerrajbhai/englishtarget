import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/ads/ad_manager.dart'; // <--- AD MANAGER IMPORT
import '../../../core/ads/banner_ad_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../models/rule_content.dart';
import '../services/rules_progress_service.dart';
import 'rule_practice_screen.dart';

class RuleTestScreen extends StatefulWidget {
  final RuleContent rule;

  const RuleTestScreen({
    super.key,
    required this.rule,
  });

  @override
  State<RuleTestScreen> createState() =>
      _RuleTestScreenState();
}

class _RuleTestScreenState
    extends State<RuleTestScreen> {
  late final FlutterTts _tts;

  int _currentIndex = 0;
  int _correctAnswers = 0;

  String? _selectedAnswer;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  bool _isSpeaking = false;
  bool _isSaving = false;

  RuleTest get _currentTest {
    return widget.rule.tests[_currentIndex];
  }

  bool get _isLastQuestion {
    return _currentIndex ==
        widget.rule.tests.length - 1;
  }

  double get _progress {
    return (_currentIndex + 1) /
        widget.rule.tests.length;
  }

  @override
  void initState() {
    super.initState();

    _tts = FlutterTts();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.43);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);

    _tts.setStartHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = true);
    });

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _tts.setCancelHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    _tts.setErrorHandler((_) {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speakQuestion() async {
    await _tts.stop();

    final question = _currentTest.question;

    try {
      final isBangla =
      RegExp(r'[\u0980-\u09FF]')
          .hasMatch(question);

      await _tts.setLanguage(
        isBangla ? 'bn-BD' : 'en-US',
      );
    } catch (_) {
      await _tts.setLanguage('en-US');
    }

    await _tts.speak(question);
  }

  Future<void> _playCorrectSound() async {
    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.46);
    await _tts.speak('Correct! Well done.');
  }

  Future<void> _playWrongSound() async {
    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.46);
    await _tts.speak('Not correct. Try again.');
  }

  void _selectAnswer(String answer) {
    if (_hasAnswered) return;

    final isCorrect =
        answer.trim().toLowerCase() ==
            _currentTest.correctAnswer
                .trim()
                .toLowerCase();

    setState(() {
      _selectedAnswer = answer;
      _hasAnswered = true;
      _isCorrect = isCorrect;

      if (isCorrect) {
        _correctAnswers++;
      }
    });

    if (isCorrect) {
      _playCorrectSound();
    } else {
      _playWrongSound();
    }
  }

  void _continue() {
    if (!_hasAnswered) {
      _showMessage(
        'আগে একটি answer select করুন।',
      );
      return;
    }

    if (!_isLastQuestion) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
        _isCorrect = false;
      });
      return;
    }

    _finishTest();
  }

  Future<void> _finishTest() async {
    if (_isSaving) return;

    final total =
        widget.rule.tests.length;

    setState(() {
      _isSaving = true;
    });

    await RulesProgressService.saveTestResult(
      ruleId: widget.rule.id,
      correctAnswers: _correctAnswers,
      totalQuestions: total,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    final passed =
        _correctAnswers / total >= 0.70;

    await _showResultDialog(
      passed: passed,
      total: total,
    );
  }

  Future<void> _showResultDialog({
    required bool passed,
    required int total,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding:
          const EdgeInsets.fromLTRB(
            24,
            27,
            24,
            18,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    color: passed
                        ? AppColors.mint
                        : const Color(0xFFFFF0F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    passed
                        ? Icons.emoji_events_rounded
                        : Icons.refresh_rounded,
                    color: passed
                        ? AppColors.primary
                        : AppColors.error,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 17),
                Text(
                  passed
                      ? 'Excellent!'
                      : 'Test Complete',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Score: $_correctAnswers/$total',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  passed
                      ? 'Test pass হয়েছে। এখন speaking practice করুন।'
                      : 'এই result সত্ত্বেও আপনি speaking practice করতে পারবেন।',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 21),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: FilledButton(
                    onPressed: () {
                      // --- INTERSTITIAL AD TRIGGER ---
                      // প্রথমে ডায়ালগ বন্ধ হবে, তারপর অ্যাড শো করে প্র্যাকটিস স্ক্রিনে যাবে
                      Navigator.pop(dialogContext);

                      AdManager.instance.showInterstitialAd(
                        onAdDismissed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) {
                                return RulePracticeScreen(
                                  rule: widget.rule,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Continue to Practice',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navy,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rule.tests.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No test available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _TestHeader(),

            // --- STICKY BANNER AD START ---
            const BannerAdWidget(),
            // --- STICKY BANNER AD END ---

            _ProgressHeader(
              current: _currentIndex + 1,
              total: widget.rule.tests.length,
              progress: _progress,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final padding =
                  (constraints.maxWidth * 0.055)
                      .clamp(18.0, 34.0)
                      .toDouble();

                  return Center(
                    child: ConstrainedBox(
                      constraints:
                      const BoxConstraints(
                        maxWidth: 760,
                      ),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          padding,
                          21,
                          padding,
                          28,
                        ),
                        children: [
                          const _TestHeading(),
                          const SizedBox(height: 18),
                          _QuestionCard(
                            question:
                            _currentTest.question,
                            questionNumber:
                            _currentIndex + 1,
                            totalQuestions:
                            widget.rule.tests.length,
                            isSpeaking: _isSpeaking,
                            onSpeak: _speakQuestion,
                          ),
                          const SizedBox(height: 17),
                          const Text(
                            'Choose the correct answer',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 13),
                          _OptionsList(
                            options:
                            _currentTest.options,
                            selected:
                            _selectedAnswer,
                            correctAnswer:
                            _currentTest.correctAnswer,
                            hasAnswered:
                            _hasAnswered,
                            onSelect: _selectAnswer,
                          ),
                          if (_hasAnswered) ...[
                            const SizedBox(height: 16),
                            _FeedbackCard(
                              isCorrect: _isCorrect,
                              correctAnswer:
                              _currentTest.correctAnswer,
                              explanation:
                              _currentTest.explanation,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _BottomButton(
              answered: _hasAnswered,
              saving: _isSaving,
              lastQuestion: _isLastQuestion,
              onPressed: _continue,
            ),
          ],
        ),
      ),
    );
  }
}

class _TestHeader extends StatelessWidget {
  const _TestHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        16,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.maybePop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
            color: AppColors.navy,
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Rule Test',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.flag_outlined,
            ),
            color: AppColors.navy,
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  final double progress;

  const _ProgressHeader({
    required this.current,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        22,
        9,
        22,
        14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(
                total,
                    (index) {
                  final active =
                      index < current;

                  return Expanded(
                    child: Container(
                      height: 7,
                      margin: EdgeInsets.only(
                        right: index == total - 1
                            ? 0
                            : 4,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : const Color(0xFFE1E7E4),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 13),
          Text(
            '$current/$total',
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestHeading extends StatelessWidget {
  const _TestHeading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius:
            BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.quiz_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Check your learning',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Select one correct answer',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final int questionNumber;
  final int totalQuestions;
  final bool isSpeaking;
  final VoidCallback onSpeak;

  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.isSpeaking,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFC9E7D7),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onSpeak,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              fixedSize: const Size(51, 51),
            ),
            icon: Icon(
              isSpeaking
                  ? Icons.volume_up_rounded
                  : Icons.volume_up_outlined,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Question $questionNumber of $totalQuestions',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  question,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    height: 1.45,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsList extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final String correctAnswer;
  final bool hasAnswered;
  final ValueChanged<String> onSelect;

  const _OptionsList({
    required this.options,
    required this.selected,
    required this.correctAnswer,
    required this.hasAnswered,
    required this.onSelect,
  });

  bool _same(String first, String second) {
    return first.trim().toLowerCase() ==
        second.trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected =
            selected != null &&
                _same(selected!, option);

        final isCorrect =
            hasAnswered &&
                _same(option, correctAnswer);

        final isWrong =
            hasAnswered &&
                isSelected &&
                !isCorrect;

        Color borderColor = AppColors.border;
        Color backgroundColor = Colors.white;
        Color iconColor = AppColors.textSecondary;
        IconData icon =
            Icons.radio_button_off_rounded;

        if (isCorrect) {
          borderColor = AppColors.primary;
          backgroundColor = AppColors.mint;
          iconColor = AppColors.primary;
          icon = Icons.check_circle_rounded;
        } else if (isWrong) {
          borderColor = AppColors.error;
          backgroundColor =
          const Color(0xFFFFF3F3);
          iconColor = AppColors.error;
          icon = Icons.cancel_rounded;
        } else if (isSelected) {
          borderColor = AppColors.primary;
          backgroundColor =
          const Color(0xFFF2FBF6);
          iconColor = AppColors.primary;
          icon =
              Icons.radio_button_checked_rounded;
        }

        return Padding(
          padding: const EdgeInsets.only(
            bottom: 11,
          ),
          child: Material(
            color: backgroundColor,
            borderRadius:
            BorderRadius.circular(17),
            child: InkWell(
              onTap: hasAnswered
                  ? null
                  : () => onSelect(option),
              borderRadius:
              BorderRadius.circular(17),
              child: Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 17,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(17),
                  border: Border.all(
                    color: borderColor,
                    width: isSelected ||
                        isCorrect
                        ? 1.7
                        : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: iconColor,
                      size: 25,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  final String explanation;

  const _FeedbackCard({
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect
        ? AppColors.primary
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.mint
            : const Color(0xFFFFF3F3),
        borderRadius:
        BorderRadius.circular(19),
        border: Border.all(
          color: color.withAlpha(55),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_rounded
                : Icons.info_rounded,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect
                      ? 'Excellent!'
                      : 'Review this rule',
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                if (!isCorrect) ...[
                  Text(
                    'Correct answer: $correctAnswer',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
                Text(
                  explanation,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final bool answered;
  final bool saving;
  final bool lastQuestion;
  final VoidCallback onPressed;

  const _BottomButton({
    required this.answered,
    required this.saving,
    required this.lastQuestion,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        12,
        18,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: saving ? null : onPressed,
            child: saving
                ? const SizedBox(
              width: 22,
              height: 22,
              child:
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : Text(
              answered
                  ? lastQuestion
                  ? 'See Result'
                  : 'Continue'
                  : 'Select an Answer',
            ),
          ),
        ),
      ),
    );
  }
}