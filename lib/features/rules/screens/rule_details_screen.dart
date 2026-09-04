import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/ads/ad_manager.dart'; // <--- AD MANAGER IMPORT
import '../../../core/ads/banner_ad_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rule_learning_controller.dart';
import '../models/rule_content.dart';
import 'rule_test_screen.dart'; // <--- ENSURE THIS FILE EXISTS IN THE SAME FOLDER

class RuleDetailsScreen extends StatefulWidget {
  final RuleContent rule;

  const RuleDetailsScreen({
    super.key,
    required this.rule,
  });

  @override
  State<RuleDetailsScreen> createState() => _RuleDetailsScreenState();
}

class _RuleDetailsScreenState extends State<RuleDetailsScreen> {
  late final RuleLearningController _controller;
  late final FlutterTts _tts;

  int _currentIndex = 0;
  bool _isSpeaking = false;

  RuleExample get _currentExample {
    return widget.rule.examples[_currentIndex];
  }

  bool get _isFirst {
    return _currentIndex == 0;
  }

  bool get _isLast {
    return _currentIndex == widget.rule.examples.length - 1;
  }

  double get _exampleProgress {
    if (widget.rule.examples.isEmpty) return 0;

    return (_currentIndex + 1) / widget.rule.examples.length;
  }

  @override
  void initState() {
    super.initState();

    _controller = RuleLearningController(
      ruleId: widget.rule.id,
    );

    _tts = FlutterTts();

    _controller.addListener(_refreshScreen);

    _configureTts();
    _controller.initialize();
  }

  Future<void> _configureTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
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

  void _refreshScreen() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _speakSentence() async {
    await _tts.stop();
    await _tts.speak(_currentExample.english);
  }

  Future<void> _previousSentence() async {
    if (_isFirst) return;

    await _tts.stop();

    setState(() {
      _currentIndex--;
    });
  }

  Future<void> _nextSentence() async {
    await _tts.stop();

    if (!_isLast) {
      setState(() {
        _currentIndex++;
      });
      return;
    }

    if (!_controller.progress.learnCompleted) {
      final completed = await _controller.completeLearning();

      if (!mounted) return;

      if (completed) {
        _showMessage(
          'Learning complete হয়েছে। এখন Rule Test দিন।',
          color: AppColors.primary,
        );
      }

      setState(() {});
      return;
    }

    _openTest();
  }

  void _openTest() {
    // --- INTERSTITIAL AD TRIGGER ---
    // Test-এ যাওয়ার ঠিক আগে অ্যাড শো করবে
    AdManager.instance.showInterstitialAd(
      onAdDismissed: () {
        Navigator.of(context)
            .push(
          MaterialPageRoute<void>(
            builder: (_) {
              return RuleTestScreen(
                rule: widget.rule,
              );
            },
          ),
        )
            .then((_) {
          _controller.refreshProgress();
        });
      },
    );
  }

  void _showMessage(
      String message, {
        Color color = AppColors.navy,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
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
    _controller.removeListener(_refreshScreen);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rule.examples.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No examples available'),
        ),
      );
    }

    final progress = _controller.progress;
    final visual = _SentenceVisualResolver.resolve(
      example: _currentExample,
      rule: widget.rule,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopHeader(
              title: widget.rule.title,
              onBack: () {
                Navigator.maybePop(context);
              },
            ),
            const _LessonSteps(),

            // --- STICKY BANNER AD START ---
            const BannerAdWidget(),
            // --- STICKY BANNER AD END ---

            Expanded(
              child: _controller.isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
                  : LayoutBuilder(
                builder: (context, constraints) {
                  final padding = (constraints.maxWidth * 0.055)
                      .clamp(18.0, 34.0)
                      .toDouble();

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 760,
                      ),
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          padding,
                          18,
                          padding,
                          25,
                        ),
                        children: [
                          _RuleInfoCard(
                            rule: widget.rule,
                          ),
                          const SizedBox(height: 14),
                          _FormulaCard(
                            formula: widget.rule.formula,
                          ),
                          const SizedBox(height: 20),
                          _ExampleProgress(
                            current: _currentIndex + 1,
                            total: widget.rule.examples.length,
                            value: _exampleProgress,
                          ),
                          const SizedBox(height: 13),
                          AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 350,
                            ),
                            child: _VisualCard(
                              key: ValueKey(
                                _currentIndex,
                              ),
                              visual: visual,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 300,
                            ),
                            child: _SentenceCard(
                              key: ValueKey(
                                'sentence_$_currentIndex',
                              ),
                              example: _currentExample,
                              color: visual.color,
                              isSpeaking: _isSpeaking,
                              onSpeak: _speakSentence,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _TipCard(
                            example: _currentExample,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _BottomControls(
              isFirst: _isFirst,
              isLast: _isLast,
              isCompleted: progress.learnCompleted,
              isLoading: _controller.isLoading,
              onPrevious: _previousSentence,
              onNext: _nextSentence,
            ),
          ],
        ),
      ),
    );
  }
}

class _VisualInfo {
  final IconData icon;
  final Color color;
  final String label;

  const _VisualInfo({
    required this.icon,
    required this.color,
    required this.label,
  });
}

class _TopHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopHeader({
    required this.title,
    required this.onBack,
  });

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
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
            color: AppColors.navy,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.bookmark_border_rounded,
            ),
            color: AppColors.navy,
          ),
        ],
      ),
    );
  }
}

class _LessonSteps extends StatelessWidget {
  const _LessonSteps();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        8,
        24,
        12,
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
          const _StepItem(
            title: 'Learn',
            icon: Icons.menu_book_rounded,
            active: true,
          ),
          const _StepLine(),
          const _StepItem(
            title: 'Test',
            icon: Icons.quiz_rounded,
            active: false,
          ),
          const _StepLine(),
          const _StepItem(
            title: 'Speak',
            icon: Icons.mic_rounded,
            active: false,
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool active;

  const _StepItem({
    required this.title,
    required this.icon,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;

    return Column(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: active ? AppColors.mint : const Color(0xFFF1F3F2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 17,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.fromLTRB(
          8,
          0,
          8,
          17,
        ),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _RuleInfoCard extends StatelessWidget {
  final RuleContent rule;

  const _RuleInfoCard({
    required this.rule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rule.color.withAlpha(17),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: rule.color.withAlpha(48),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: rule.color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              rule.icon,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.shortMeaning,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  rule.usage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
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

class _FormulaCard extends StatelessWidget {
  final String formula;

  const _FormulaCard({
    required this.formula,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              color: AppColors.amber,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sentence Structure',
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formula,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
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

class _ExampleProgress extends StatelessWidget {
  final int current;
  final int total;
  final double value;

  const _ExampleProgress({
    required this.current,
    required this.total,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Learn with a visual example',
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$current of $total',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: const Color(0xFFE1EAE5),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _VisualCard extends StatelessWidget {
  final _VisualInfo visual;

  const _VisualCard({
    super.key,
    required this.visual,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            visual.color.withAlpha(35),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: visual.color.withAlpha(60),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 18,
            left: 25,
            child: _Dot(
              size: 24,
              color: visual.color.withAlpha(38),
            ),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: _Dot(
              size: 42,
              color: visual.color.withAlpha(24),
            ),
          ),
          Positioned(
            bottom: 22,
            right: 56,
            child: _Dot(
              size: 20,
              color: visual.color.withAlpha(42),
            ),
          ),
          Container(
            width: 122,
            height: 122,
            decoration: BoxDecoration(
              color: visual.color.withAlpha(22),
              shape: BoxShape.circle,
              border: Border.all(
                color: visual.color.withAlpha(68),
                width: 2,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: visual.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: visual.color.withAlpha(75),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                visual.icon,
                color: Colors.white,
                size: 53,
              ),
            ),
          ),
          Positioned(
            bottom: 17,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                visual.label,
                style: TextStyle(
                  color: visual.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final Color color;

  const _Dot({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SentenceCard extends StatelessWidget {
  final RuleExample example;
  final Color color;
  final bool isSpeaking;
  final VoidCallback onSpeak;

  const _SentenceCard({
    super.key,
    required this.example,
    required this.color,
    required this.isSpeaking,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'বাংলা অর্থ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  example.bengali,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 17,
                    height: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  example.english,
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    height: 1.4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onSpeak,
            tooltip: 'Listen',
            style: IconButton.styleFrom(
              backgroundColor: color.withAlpha(18),
              foregroundColor: color,
            ),
            icon: Icon(
              isSpeaking
                  ? Icons.volume_up_rounded
                  : Icons.volume_up_outlined,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final RuleExample example;

  const _TipCard({
    required this.example,
  });

  @override
  Widget build(BuildContext context) {
    final firstWord = example.english.split(' ').first;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC8DFF7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color: AppColors.amber,
            size: 23,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '"$firstWord" sentence-এর গুরুত্বপূর্ণ word হিসেবে ব্যবহার হয়েছে।',
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _BottomControls({
    required this.isFirst,
    required this.isLast,
    required this.isCompleted,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final nextLabel = isCompleted
        ? 'Take Rule Test'
        : isLast
        ? 'Complete Learning'
        : 'Next Sentence';

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        11,
        16,
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
            color: AppColors.navy.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            SizedBox(
              width: 112,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: isFirst || isLoading ? null : onPrevious,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 18,
                ),
                label: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : onNext,
                  icon: Icon(
                    isCompleted
                        ? Icons.quiz_rounded
                        : isLast
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_rounded,
                    size: 19,
                  ),
                  label: Text(nextLabel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resolves every example key to a semantic icon.
abstract final class _SentenceVisualResolver {
  static _VisualInfo resolve({
    required RuleExample example,
    required RuleContent rule,
  }) {
    final raw = '${example.visualKey} ${example.bengali} ${example.english}'
        .toLowerCase();
    final text = _normalize(raw);

    for (final _VisualRule item in _rules) {
      if (_containsAny(text, item.words)) {
        return _applyModifier(item.info, text);
      }
    }

    final _VisualInfo typeVisual = _typeVisual(example.type);
    return _applyModifier(typeVisual, text);
  }

  static String _normalize(String value) {
    return ' ${value.replaceAll('_', ' ').replaceAll(RegExp(r'[^a-z0-9\u0980-\u09ff]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim()} ';
  }

  static bool _containsAny(String text, List<String> words) {
    return words.any((String word) {
      final normalizedWord = word.toLowerCase();
      if (RegExp(r'^[a-z0-9 ]+$').hasMatch(normalizedWord)) {
        return text.contains(' $normalizedWord ');
      }
      return text.contains(normalizedWord);
    });
  }

  static _VisualInfo _applyModifier(_VisualInfo base, String text) {
    if (_containsAny(
        text, <String>['question', 'কি', 'কেন', 'কখন', 'কীভাবে'])) {
      return _VisualInfo(
        icon: base.icon,
        color: const Color(0xFF0D9E9A),
        label: '${base.label} question',
      );
    }

    if (_containsAny(text, <String>['negative', 'not', 'নয়', 'নেই', 'না'])) {
      return _VisualInfo(
        icon: base.icon,
        color: const Color(0xFFE94B4B),
        label: '${base.label} negative',
      );
    }

    if (_containsAny(text, <String>['near', 'কাছের', 'কাছে'])) {
      return _VisualInfo(
        icon: base.icon,
        color: base.color,
        label: 'Near ${base.label}',
      );
    }

    if (_containsAny(text, <String>['far', 'দূরের', 'দূরে'])) {
      return _VisualInfo(
        icon: base.icon,
        color: base.color,
        label: 'Far ${base.label}',
      );
    }

    return base;
  }

  static _VisualInfo _typeVisual(RuleExampleType type) {
    switch (type) {
      case RuleExampleType.question:
        return const _VisualInfo(
          icon: Icons.help_outline_rounded,
          color: Color(0xFF0D9E9A),
          label: 'Question',
        );
      case RuleExampleType.negative:
        return const _VisualInfo(
          icon: Icons.block_rounded,
          color: Color(0xFFE94B4B),
          label: 'Negative sentence',
        );
      case RuleExampleType.positive:
        return const _VisualInfo(
          icon: Icons.check_circle_rounded,
          color: Color(0xFF16A36A),
          label: 'Positive sentence',
        );
      case RuleExampleType.conversation:
        return const _VisualInfo(
          icon: Icons.forum_rounded,
          color: Color(0xFF7756D8),
          label: 'Conversation',
        );
      case RuleExampleType.simple:
        return const _VisualInfo(
          icon: Icons.chat_bubble_outline_rounded,
          color: Color(0xFF4285F4),
          label: 'Sentence',
        );
    }
  }

  static _VisualInfo _i(
      IconData icon,
      Color color,
      String label,
      ) {
    return _VisualInfo(
      icon: icon,
      color: color,
      label: label,
    );
  }

  static _VisualRule _r(
      List<String> words,
      IconData icon,
      int color,
      String label,
      ) {
    return _VisualRule(
      words,
      _i(icon, Color(color), label),
    );
  }

  static final List<_VisualRule> _rules = <_VisualRule>[
    _r(<String>['blue car'], Icons.directions_car_rounded, 0xFF4285F4,
        'Blue car'),
    _r(<String>['fast food'], Icons.restaurant_rounded, 0xFFE94B4B,
        'Fast food'),
    _r(<String>['read book'], Icons.menu_book_rounded, 0xFF4285F4,
        'Reading a book'),
    _r(<String>['write letter'], Icons.mail_rounded, 0xFF4285F4,
        'Writing a letter'),
    _r(<String>['play football'], Icons.sports_soccer_rounded, 0xFF16A36A,
        'Playing football'),
    _r(<String>['watch movie'], Icons.movie_rounded, 0xFF7756D8,
        'Watching a movie'),
    _r(<String>['school', 'স্কুল'], Icons.school_rounded, 0xFF4285F4, 'School'),
    _r(<String>['teacher', 'শিক্ষক'], Icons.school_rounded, 0xFF7756D8,
        'Teacher'),
    _r(<String>['doctor', 'ডাক্তার'], Icons.medical_services_rounded,
        0xFFE94B4B, 'Doctor'),
    _r(<String>['student', 'ছাত্র', 'ছাত্রী'], Icons.school_rounded, 0xFF16A36A,
        'Student'),
    _r(<String>['friend', 'বন্ধু'], Icons.groups_rounded, 0xFF7756D8,
        'Friends'),
    _r(<String>['mother', 'মা'], Icons.person_rounded, 0xFFE94B4B, 'Mother'),
    _r(<String>['brother', 'ভাই'], Icons.person_rounded, 0xFF16A36A, 'Brother'),
    _r(<String>['sister', 'বোন'], Icons.face_rounded, 0xFF7756D8, 'Sister'),
    _r(<String>['children', 'child', 'শিশু'], Icons.child_care_rounded,
        0xFFFFA51F, 'Children'),
    _r(<String>['book', 'বই'], Icons.menu_book_rounded, 0xFF4285F4, 'Book'),
    _r(<String>['pen', 'কলম'], Icons.edit_rounded, 0xFF4285F4, 'Pen'),
    _r(<String>['phone', 'ফোন'], Icons.phone_android_rounded, 0xFF0D9E70,
        'Phone'),
    _r(<String>['computer', 'কম্পিউটার'], Icons.computer_rounded, 0xFF4285F4,
        'Computer'),
    _r(<String>['chair', 'চেয়ার', 'চেয়ার'], Icons.chair_rounded, 0xFFFFA51F,
        'Chair'),
    _r(<String>['car', 'গাড়ি', 'গাড়ি'], Icons.directions_car_rounded,
        0xFF4285F4, 'Car'),
    _r(<String>['house', 'home', 'বাড়ি', 'বাড়ি'], Icons.home_rounded,
        0xFF16A36A, 'Home'),
    _r(<String>['hospital', 'হাসপাতাল'], Icons.local_hospital_rounded,
        0xFFE94B4B, 'Hospital'),
    _r(<String>['tree', 'গাছ'], Icons.park_rounded, 0xFF16A36A, 'Tree'),
    _r(<String>['flower', 'ফুল'], Icons.local_florist_rounded, 0xFFE94B4B,
        'Flower'),
    _r(<String>['ball', 'বল'], Icons.sports_baseball_rounded, 0xFFFFA51F,
        'Ball'),
    _r(<String>['bus', 'বাস'], Icons.directions_bus_rounded, 0xFF0D9E70, 'Bus'),
    _r(<String>['bicycle', 'bike', 'সাইকেল'], Icons.directions_bike_rounded,
        0xFF16A36A, 'Bicycle'),
    _r(<String>['bag', 'ব্যাগ'], Icons.backpack_rounded, 0xFF7756D8, 'Bag'),
    _r(<String>['key', 'keys', 'চাবি'], Icons.key_rounded, 0xFFFFA51F, 'Key'),
    _r(<String>['shoe', 'shoes', 'জুতা'], Icons.shopping_bag_rounded,
        0xFF7756D8, 'Shoes'),
    _r(<String>['cup', 'cups', 'কাপ'], Icons.local_cafe_rounded, 0xFFFFA51F,
        'Cup'),
    _r(<String>['table', 'টেবিল'], Icons.table_restaurant_rounded, 0xFFFFA51F,
        'Table'),
    _r(<String>['tea', 'চা'], Icons.local_cafe_rounded, 0xFFFFA51F, 'Tea'),
    _r(<String>['coffee', 'কফি'], Icons.coffee_rounded, 0xFF795548, 'Coffee'),
    _r(<String>['food', 'খাবার', 'restaurant'], Icons.restaurant_rounded,
        0xFFE94B4B, 'Food'),
    _r(<String>['water', 'পানি', 'জল'], Icons.water_drop_rounded, 0xFF4285F4,
        'Water'),
    _r(<String>['apple', 'আপেল'], Icons.shopping_basket_rounded, 0xFFE94B4B,
        'Apple'),
    _r(<String>['rain', 'raining', 'বৃষ্টি'], Icons.umbrella_rounded,
        0xFF4285F4, 'Rain'),
    _r(<String>['sunrise', 'sun', 'সূর্য'], Icons.wb_sunny_rounded, 0xFFFFA51F,
        'Sun'),
    _r(<String>['moon', 'চাঁদ'], Icons.nightlight_round, 0xFF7756D8, 'Moon'),
    _r(<String>['sky', 'আকাশ'], Icons.cloud_rounded, 0xFF4285F4, 'Sky'),
    _r(<String>['river', 'নদী'], Icons.water_rounded, 0xFF4285F4, 'River'),
    _r(<String>['park', 'পার্ক'], Icons.park_rounded, 0xFF16A36A, 'Park'),
    _r(<String>['office', 'অফিস'], Icons.business_rounded, 0xFF7756D8,
        'Office'),
    _r(<String>['class', 'ক্লাস'], Icons.class_rounded, 0xFF4285F4, 'Class'),
    _r(<String>['exam', 'পরীক্ষা'], Icons.assignment_rounded, 0xFFE94B4B,
        'Exam'),
    _r(<String>['traffic', 'ট্রাফিক'], Icons.traffic_rounded, 0xFFE94B4B,
        'Traffic'),
    _r(<String>['work', 'works', 'working', 'কাজ'], Icons.work_rounded,
        0xFFFFA51F, 'Work'),
    _r(<String>['cook', 'cooking', 'রান্না'], Icons.soup_kitchen_rounded,
        0xFFE94B4B, 'Cooking'),
    _r(<String>['eat', 'eating', 'খাই', 'খাওয়া'], Icons.restaurant_rounded,
        0xFFE94B4B, 'Eating'),
    _r(<String>['drink', 'drank', 'পান'], Icons.local_drink_rounded, 0xFF4285F4,
        'Drinking'),
    _r(<String>['read', 'reading', 'পড়ি', 'পড়া'],
        Icons.chrome_reader_mode_rounded, 0xFF4285F4, 'Reading'),
    _r(<String>['write', 'writing', 'wrote', 'লিখি', 'লেখা'],
        Icons.edit_note_rounded, 0xFF7756D8, 'Writing'),
    _r(<String>['speak', 'speaking', 'বল', 'কথা'],
        Icons.record_voice_over_rounded, 0xFF4285F4, 'Speaking'),
    _r(<String>['listen', 'listening', 'শুনি'], Icons.hearing_rounded,
        0xFF0D9E70, 'Listening'),
    _r(<String>['talk', 'talking'], Icons.forum_rounded, 0xFF7756D8, 'Talking'),
    _r(<String>['call', 'কল'], Icons.call_rounded, 0xFF0D9E70, 'Calling'),
    _r(<String>['help', 'helped', 'সাহায্য'], Icons.volunteer_activism_rounded,
        0xFF16A36A, 'Helping'),
    _r(<String>['teach', 'teaches', 'শেখাই'], Icons.school_rounded, 0xFF7756D8,
        'Teaching'),
    _r(<String>['study', 'studying', 'পড়াশোনা'], Icons.school_rounded,
        0xFF4285F4, 'Studying'),
    _r(<String>['run', 'running', 'দৌড়'], Icons.directions_run_rounded,
        0xFF16A36A, 'Running'),
    _r(<String>['walk', 'walking', 'হাঁটা'], Icons.directions_walk_rounded,
        0xFF16A36A, 'Walking'),
    _r(<String>['drive', 'driving'], Icons.drive_eta_rounded, 0xFF4285F4,
        'Driving'),
    _r(<String>['swim', 'সাঁতার'], Icons.pool_rounded, 0xFF4285F4, 'Swimming'),
    _r(<String>['sleep', 'sleeping', 'ঘুম'], Icons.bedtime_rounded, 0xFF7756D8,
        'Sleeping'),
    _r(<String>['open', 'opened', 'খোলা'], Icons.lock_open_rounded, 0xFF16A36A,
        'Opening'),
    _r(<String>['close', 'closed', 'বন্ধ'], Icons.lock_rounded, 0xFFE94B4B,
        'Closing'),
    _r(<String>['play', 'playing', 'খেলে'], Icons.sports_rounded, 0xFF16A36A,
        'Playing'),
    _r(<String>['watch', 'watching', 'দেখি'], Icons.visibility_rounded,
        0xFF4285F4, 'Watching'),
    _r(<String>['sing', 'sang', 'গান'], Icons.music_note_rounded, 0xFFE94B4B,
        'Singing'),
    _r(<String>['dance', 'danced', 'নাচ'], Icons.music_video_rounded,
        0xFFE94B4B, 'Dancing'),
    _r(<String>['travel', 'ভ্রমণ'], Icons.travel_explore_rounded, 0xFF4285F4,
        'Travel'),
    _r(<String>['go', 'going', 'went', 'যাই', 'যাওয়া'],
        Icons.directions_walk_rounded, 0xFF0D9E70, 'Going'),
    _r(<String>['come', 'coming', 'came', 'আসি', 'আসা'], Icons.login_rounded,
        0xFF16A36A, 'Coming'),
    _r(<String>['leave', 'left', 'চলে'], Icons.logout_rounded, 0xFFE94B4B,
        'Leaving'),
    _r(<String>['wait', 'waiting', 'অপেক্ষা'], Icons.hourglass_top_rounded,
        0xFFFFA51F, 'Waiting'),
    _r(<String>['happy', 'খুশি', 'সুখী'], Icons.sentiment_satisfied_alt_rounded,
        0xFFFFA51F, 'Happy'),
    _r(<String>['sad', 'দুঃখিত'], Icons.sentiment_dissatisfied_rounded,
        0xFF4285F4, 'Sad'),
    _r(<String>['cry', 'crying', 'কাঁদ'],
        Icons.sentiment_very_dissatisfied_rounded, 0xFF4285F4, 'Crying'),
    _r(<String>['sick', 'fever', 'অসুস্থ', 'জ্বর'], Icons.sick_rounded,
        0xFFE94B4B, 'Sick'),
    _r(<String>['busy', 'ব্যস্ত'], Icons.timer_rounded, 0xFFE94B4B, 'Busy'),
    _r(<String>['late', 'দেরি'], Icons.schedule_rounded, 0xFFE94B4B, 'Late'),
    _r(<String>['ready', 'প্রস্তুত'], Icons.check_circle_rounded, 0xFF16A36A,
        'Ready'),
    _r(<String>['problem', 'সমস্যা'], Icons.report_problem_rounded, 0xFFE94B4B,
        'Problem'),
    _r(<String>['idea', 'আইডিয়া'], Icons.lightbulb_rounded, 0xFFFFA51F,
        'Idea'),
    _r(<String>['success', 'সফল'], Icons.emoji_events_rounded, 0xFFFFA51F,
        'Success'),
    _r(<String>['truth', 'true', 'সত্য'], Icons.verified_rounded, 0xFF16A36A,
        'Truth'),
    _r(<String>['fear', 'ভয়'], Icons.warning_rounded, 0xFFE94B4B, 'Fear'),
    _r(<String>['careful', 'সাবধান'], Icons.health_and_safety_rounded,
        0xFFFFA51F, 'Careful'),
    _r(<String>['time', 'সময়'], Icons.access_time_rounded, 0xFF4285F4, 'Time'),
    _r(<String>['morning', 'সকাল'], Icons.wb_sunny_rounded, 0xFFFFA51F,
        'Morning'),
    _r(<String>['night', 'রাত'], Icons.nightlight_round, 0xFF7756D8, 'Night'),
    _r(<String>['country', 'বাংলাদেশ'], Icons.public_rounded, 0xFF16A36A,
        'Country'),
    _r(<String>['answer', 'answered'], Icons.question_answer_rounded,
        0xFF4285F4, 'Answer'),
    _r(<String>['argue', 'arguing'], Icons.forum_rounded, 0xFFE94B4B,
        'Discussion'),
    _r(<String>['arrive'], Icons.place_rounded, 0xFF4285F4, 'Arrival'),
    _r(<String>['ate rice', 'eat rice', 'dinner', 'lunch'],
        Icons.restaurant_rounded, 0xFFE94B4B, 'Meal'),
    _r(<String>['begin question', 'begin'], Icons.play_circle_rounded,
        0xFF16A36A, 'Beginning'),
    _r(<String>['bird', 'birds'], Icons.pets_rounded, 0xFF16A36A, 'Bird'),
    _r(<String>['birth', 'birthday'], Icons.cake_rounded, 0xFFE94B4B,
        'Birthday'),
    _r(<String>['break', 'broke'], Icons.broken_image_rounded, 0xFFE94B4B,
        'Broken'),
    _r(<String>['door'], Icons.door_back_door, 0xFFFFA51F, 'Door'),
    _r(<String>['buy', 'bought', 'shop', 'shopping'],
        Icons.shopping_cart_rounded, 0xFF16A36A, 'Shopping'),
    _r(<String>['can do', 'doing', 'do work'], Icons.task_alt_rounded,
        0xFF16A36A, 'Doing'),
    _r(<String>['cat', 'dog', 'doll', 'pet'], Icons.pets_rounded, 0xFFFFA51F,
        'Pet'),
    _r(<String>['clean', 'cleaned'], Icons.cleaning_services_rounded,
        0xFF16A36A, 'Cleaning'),
    _r(<String>['clock'], Icons.access_time_rounded, 0xFF4285F4, 'Clock'),
    _r(<String>['cold'], Icons.ac_unit_rounded, 0xFF4285F4, 'Cold'),
    _r(<String>['color', 'orange'], Icons.palette_rounded, 0xFFE94B4B, 'Color'),
    _r(<String>['correct question', 'correct'], Icons.fact_check_rounded,
        0xFF16A36A, 'Correct'),
    _r(<String>['course'], Icons.school_rounded, 0xFF4285F4, 'Course'),
    _r(<String>['cricket'], Icons.sports_cricket_rounded, 0xFF16A36A,
        'Cricket'),
    _r(<String>['difficult'], Icons.psychology_rounded, 0xFFE94B4B,
        'Difficult'),
    _r(<String>['easy'], Icons.lightbulb_rounded, 0xFFFFA51F, 'Easy'),
    _r(<String>['earth'], Icons.public_rounded, 0xFF16A36A, 'Earth'),
    _r(<String>['english', 'language', 'languages'], Icons.translate_rounded,
        0xFF4285F4, 'Language'),
    _r(<String>['experience'], Icons.workspace_premium_rounded, 0xFFFFA51F,
        'Experience'),
    _r(<String>['explain'], Icons.menu_book_rounded, 0xFF4285F4, 'Explanation'),
    _r(<String>['feeling', 'doing well'], Icons.sentiment_satisfied_alt_rounded,
        0xFFFFA51F, 'Feeling'),
    _r(<String>['finish', 'finish work'], Icons.task_alt_rounded, 0xFF16A36A,
        'Finished'),
    _r(<String>['follow me'], Icons.follow_the_signs_rounded, 0xFF4285F4,
        'Follow'),
    _r(<String>['form'], Icons.assignment_rounded, 0xFF4285F4, 'Form'),
    _r(<String>['funny'], Icons.sentiment_very_satisfied_rounded, 0xFFFFA51F,
        'Funny'),
    _r(<String>['have opportunity', 'opportunity'], Icons.lightbulb_rounded,
        0xFFFFA51F, 'Opportunity'),
    _r(<String>['have project', 'project'], Icons.work_rounded, 0xFF7756D8,
        'Project'),
    _r(<String>['has tail', 'tail'], Icons.pets_rounded, 0xFFFFA51F, 'Tail'),
    _r(<String>['has voice', 'hear', 'hearing'],
        Icons.record_voice_over_rounded, 0xFF4285F4, 'Voice'),
    _r(<String>['healthy'], Icons.health_and_safety_rounded, 0xFF16A36A,
        'Healthy'),
    _r(<String>['helmet'], Icons.health_and_safety_rounded, 0xFFFFA51F,
        'Helmet'),
    _r(<String>['hot'], Icons.local_fire_department_rounded, 0xFFE94B4B, 'Hot'),
    _r(<String>['inside'], Icons.home_rounded, 0xFF16A36A, 'Inside'),
    _r(<String>['invite', 'invited'], Icons.event_rounded, 0xFF7756D8,
        'Invitation'),
    _r(<String>['job'], Icons.work_rounded, 0xFFFFA51F, 'Job'),
    _r(<String>['kind'], Icons.volunteer_activism_rounded, 0xFF16A36A, 'Kind'),
    _r(<String>['know', 'knew'], Icons.psychology_rounded, 0xFF7756D8,
        'Knowledge'),
    _r(<String>['lie', 'lies', 'truth'], Icons.gavel_rounded, 0xFFE94B4B,
        'Truth'),
    _r(<String>['light'], Icons.light_mode_rounded, 0xFFFFA51F, 'Light'),
    _r(<String>['like', 'love'], Icons.favorite_rounded, 0xFFE94B4B, 'Love'),
    _r(<String>['live'], Icons.home_rounded, 0xFF16A36A, 'Living'),
    _r(<String>['look', 'see', 'saw'], Icons.visibility_rounded, 0xFF4285F4,
        'Seeing'),
    _r(<String>['man', 'men'], Icons.person_rounded, 0xFF4285F4, 'Person'),
    _r(<String>['meet', 'met', 'meeting'], Icons.handshake_rounded, 0xFF16A36A,
        'Meeting'),
    _r(<String>['monday'], Icons.calendar_today_rounded, 0xFF4285F4, 'Monday'),
    _r(<String>['music'], Icons.music_note_rounded, 0xFFE94B4B, 'Music'),
    _r(<String>['name'], Icons.badge_rounded, 0xFF7756D8, 'Name'),
    _r(<String>['need'], Icons.priority_high_rounded, 0xFFE94B4B, 'Need'),
    _r(<String>['neighbours'], Icons.groups_rounded, 0xFF7756D8, 'Neighbours'),
    _r(<String>['new', 'old'], Icons.new_releases_rounded, 0xFFFFA51F,
        'New or old'),
    _r(<String>['no smoking'], Icons.smoke_free_rounded, 0xFFE94B4B,
        'No smoking'),
    _r(<String>['noise'], Icons.volume_up_rounded, 0xFFE94B4B, 'Noise'),
    _r(<String>['object'], Icons.category_rounded, 0xFF7756D8, 'Object'),
    _r(<String>['okay'], Icons.check_circle_rounded, 0xFF16A36A, 'Okay'),
    _r(<String>['outside'], Icons.landscape_rounded, 0xFF16A36A, 'Outside'),
    _r(<String>['person'], Icons.person_rounded, 0xFF4285F4, 'Person'),
    _r(<String>['please'], Icons.volunteer_activism_rounded, 0xFF16A36A,
        'Please'),
    _r(<String>['practice', 'practiced'], Icons.fitness_center_rounded,
        0xFF16A36A, 'Practice'),
    _r(<String>['promise'], Icons.handshake_rounded, 0xFF7756D8, 'Promise'),
    _r(<String>['quiet'], Icons.volume_off_rounded, 0xFF4285F4, 'Quiet'),
    _r(<String>['rest'], Icons.hotel_rounded, 0xFF7756D8, 'Rest'),
    _r(<String>['right'], Icons.check_rounded, 0xFF16A36A, 'Right'),
    _r(<String>['road'], Icons.route_rounded, 0xFF4285F4, 'Road'),
    _r(<String>['rules'], Icons.rule_rounded, 0xFF7756D8, 'Rules'),
    _r(<String>['solve'], Icons.lightbulb_rounded, 0xFFFFA51F, 'Solution'),
    _r(<String>['stay'], Icons.home_rounded, 0xFF16A36A, 'Staying'),
    _r(<String>['tell'], Icons.chat_rounded, 0xFF4285F4, 'Telling'),
    _r(<String>['touch'], Icons.touch_app_rounded, 0xFF4285F4, 'Touching'),
    _r(<String>['umbrella'], Icons.umbrella_rounded, 0xFF4285F4, 'Umbrella'),
    _r(<String>['visit'], Icons.location_on_rounded, 0xFF4285F4, 'Visiting'),
    _r(<String>['watch', 'watching'], Icons.visibility_rounded, 0xFF4285F4,
        'Watching'),
    _r(<String>['window'], Icons.window_rounded, 0xFF4285F4, 'Window'),
    _r(<String>['boy'], Icons.person_rounded, 0xFF16A36A, 'Boy'),
    _r(<String>['girl'], Icons.face_rounded, 0xFF7756D8, 'Girl'),
    _r(<String>['company'], Icons.business_center_rounded, 0xFF7756D8,
        'Company'),
    _r(<String>['device'], Icons.devices_rounded, 0xFF4285F4, 'Device'),
    _r(<String>['dhaka'], Icons.location_city_rounded, 0xFF4285F4, 'Dhaka'),
    _r(<String>['draw picture', 'picture'], Icons.image_rounded, 0xFF7756D8,
        'Picture'),
    _r(<String>['egg'], Icons.circle_rounded, 0xFFFFA51F, 'Egg'),
    _r(<String>['gift'], Icons.card_giftcard_rounded, 0xFFE94B4B, 'Gift'),
    _r(<String>['hand'], Icons.back_hand_rounded, 0xFFFFA51F, 'Hand'),
    _r(<String>['knife'], Icons.restaurant_rounded, 0xFFE94B4B, 'Knife'),
    _r(<String>['learn', 'learners', 'learning'], Icons.menu_book_rounded,
        0xFF4285F4, 'Learning'),
    _r(<String>['letter'], Icons.mail_rounded, 0xFF4285F4, 'Letter'),
    _r(<String>['market'], Icons.storefront_rounded, 0xFFFFA51F, 'Market'),
    _r(<String>['movie'], Icons.movie_rounded, 0xFF7756D8, 'Movie'),
    _r(<String>['question'], Icons.help_outline_rounded, 0xFF0D9E9A,
        'Question'),
    _r(<String>['sit'], Icons.event_seat_rounded, 0xFF7756D8, 'Sitting'),
    _r(<String>['stand'], Icons.accessibility_new_rounded, 0xFF16A36A,
        'Standing'),
    _r(<String>['start'], Icons.play_circle_rounded, 0xFF16A36A, 'Starting'),
    _r(<String>['ticket'], Icons.confirmation_number_rounded, 0xFFFFA51F,
        'Ticket'),
    _r(<String>['tired'], Icons.battery_alert_rounded, 0xFFE94B4B, 'Tired'),
    _r(<String>['together'], Icons.groups_rounded, 0xFF16A36A, 'Together'),
    _r(<String>['two boxes', 'one box'], Icons.inventory_2_rounded, 0xFFFFA51F,
        'Box'),
    _r(<String>['vehicle'], Icons.directions_car_rounded, 0xFF4285F4,
        'Vehicle'),
    _r(<String>['wake', 'wake up'], Icons.alarm_rounded, 0xFFFFA51F,
        'Waking up'),
    _r(<String>['want'], Icons.favorite_border_rounded, 0xFFE94B4B, 'Want'),
    _r(<String>['not do'], Icons.block_rounded, 0xFFE94B4B, 'Not doing'),
    _r(<String>['not mine'], Icons.inventory_2_rounded, 0xFFE94B4B, 'Not mine'),
    _r(<String>['not there'], Icons.location_off_rounded, 0xFFE94B4B,
        'Not there'),
    _r(<String>['thing near'], Icons.category_rounded, 0xFFFFA51F, 'Thing'),
    _r(<String>['this', 'those'], Icons.touch_app_rounded, 0xFF4285F4,
        'This or those'),
  ];
}

class _VisualRule {
  const _VisualRule(this.words, this.info);

  final List<String> words;
  final _VisualInfo info;
}