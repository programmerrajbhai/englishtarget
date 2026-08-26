import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/rule_learning_controller.dart';
import '../models/rule_content.dart';
import 'rule_test_screen.dart';

class RuleDetailsScreen extends StatefulWidget {
  final RuleContent rule;

  const RuleDetailsScreen({
    super.key,
    required this.rule,
  });

  @override
  State<RuleDetailsScreen> createState() =>
      _RuleDetailsScreenState();
}

class _RuleDetailsScreenState
    extends State<RuleDetailsScreen> {
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
    return _currentIndex ==
        widget.rule.examples.length - 1;
  }

  double get _exampleProgress {
    if (widget.rule.examples.isEmpty) return 0;

    return (_currentIndex + 1) /
        widget.rule.examples.length;
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
      final completed =
      await _controller.completeLearning();

      if (!mounted) return;

      if (completed) {
        _showMessage(
          'Learning complete হয়েছে। এখন Rule Test দিন।',
          color: AppColors.primary,
        );
      }

      setState(() {});
      return;
    }

    _openTest();
  }

  void _openTest() {
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
  }

  String _resolveVisualKey(RuleExample example) {
    if (example.visualKey.isNotEmpty &&
        example.visualKey != 'default') {
      return example.visualKey;
    }

    final text = '${example.bengali} '
        '${example.english}'
        .toLowerCase();

    if (text.contains('student') ||
        text.contains('ছাত্র') ||
        text.contains('ছাত্রী')) {
      return 'student';
    }

    if (text.contains('learn') ||
        text.contains('english') ||
        text.contains('শিখি')) {
      return 'learning';
    }

    if (text.contains('friend') ||
        text.contains('বন্ধু')) {
      return 'friends';
    }

    if (text.contains('speak') ||
        text.contains('বলো')) {
      return 'speaking';
    }

    if (text.contains('boy') ||
        text.contains('ছেলে')) {
      return 'boy';
    }

    if (text.contains('girl') ||
        text.contains('মেয়ে')) {
      return 'girl';
    }

    if (text.contains('work') ||
        text.contains('কাজ')) {
      return 'work';
    }

    if (text.contains('sing') ||
        text.contains('গান')) {
      return 'singing';
    }

    if (text.contains('phone') ||
        text.contains('ফোন')) {
      return 'phone';
    }

    if (text.contains('live') ||
        text.contains('বাংলাদেশে')) {
      return 'home';
    }

    if (text.contains('together') ||
        text.contains('একসঙ্গে')) {
      return 'learning_together';
    }

    if (text.contains('football') ||
        text.contains('মাঠে')) {
      return 'football';
    }

    if (text.contains('ready') ||
        text.contains('প্রস্তুত')) {
      return 'ready';
    }

    return 'default';
  }

  _VisualInfo _visualInfo(String key) {
    switch (key) {
      case 'student':
        return const _VisualInfo(
          icon: Icons.school_rounded,
          color: Color(0xFF16A36A),
          label: 'Student',
        );

      case 'learning':
        return const _VisualInfo(
          icon: Icons.menu_book_rounded,
          color: Color(0xFF4285F4),
          label: 'Learning English',
        );

      case 'friends':
      case 'friend':
        return const _VisualInfo(
          icon: Icons.groups_rounded,
          color: Color(0xFF7756D8),
          label: 'Friends',
        );

      case 'speaking':
        return const _VisualInfo(
          icon: Icons.record_voice_over_rounded,
          color: Color(0xFF4285F4),
          label: 'Speaking',
        );

      case 'boy':
        return const _VisualInfo(
          icon: Icons.person_rounded,
          color: Color(0xFF16A36A),
          label: 'A boy',
        );

      case 'girl':
        return const _VisualInfo(
          icon: Icons.face_rounded,
          color: Color(0xFF7756D8),
          label: 'A girl',
        );

      case 'work':
        return const _VisualInfo(
          icon: Icons.work_rounded,
          color: Color(0xFFFFA51F),
          label: 'Work',
        );

      case 'singing':
        return const _VisualInfo(
          icon: Icons.music_note_rounded,
          color: Color(0xFFE94B4B),
          label: 'Singing',
        );

      case 'phone':
        return const _VisualInfo(
          icon: Icons.phone_android_rounded,
          color: Color(0xFF0D9E70),
          label: 'Phone',
        );

      case 'home':
        return const _VisualInfo(
          icon: Icons.home_rounded,
          color: Color(0xFF4285F4),
          label: 'Home',
        );

      case 'learning_together':
        return const _VisualInfo(
          icon: Icons.groups_rounded,
          color: Color(0xFF16A36A),
          label: 'Learning together',
        );

      case 'football':
        return const _VisualInfo(
          icon: Icons.sports_soccer_rounded,
          color: Color(0xFF16A36A),
          label: 'Playing football',
        );

      case 'ready':
        return const _VisualInfo(
          icon: Icons.check_circle_rounded,
          color: Color(0xFF16A36A),
          label: 'Ready',
        );

      default:
        return _VisualInfo(
          icon: widget.rule.icon,
          color: widget.rule.color,
          label: 'Example scene',
        );
    }
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
    final visual = _visualInfo(
      _resolveVisualKey(_currentExample),
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
            Expanded(
              child: _controller.isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              )
                  : LayoutBuilder(
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
                            formula:
                            widget.rule.formula,
                          ),
                          const SizedBox(height: 20),
                          _ExampleProgress(
                            current:
                            _currentIndex + 1,
                            total: widget
                                .rule.examples.length,
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
                              example:
                              _currentExample,
                              color: visual.color,
                              isSpeaking:
                              _isSpeaking,
                              onSpeak:
                              _speakSentence,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _TipCard(
                            example:
                            _currentExample,
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
              isCompleted:
              progress.learnCompleted,
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
          _StepItem(
            title: 'Learn',
            icon: Icons.menu_book_rounded,
            active: true,
          ),
          const _StepLine(),
          _StepItem(
            title: 'Test',
            icon: Icons.quiz_rounded,
            active: false,
          ),
          const _StepLine(),
          _StepItem(
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
    final color = active
        ? AppColors.primary
        : AppColors.textSecondary;

    return Column(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: active
                ? AppColors.mint
                : const Color(0xFFF1F3F2),
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
          borderRadius:
          BorderRadius.circular(20),
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
        borderRadius:
        BorderRadius.circular(20),
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
              borderRadius:
              BorderRadius.circular(15),
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
              crossAxisAlignment:
              CrossAxisAlignment.start,
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
        borderRadius:
        BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius:
              BorderRadius.circular(12),
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
              crossAxisAlignment:
              CrossAxisAlignment.start,
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
          borderRadius:
          BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor:
            const Color(0xFFE1EAE5),
            valueColor:
            const AlwaysStoppedAnimation<
                Color>(
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
        borderRadius:
        BorderRadius.circular(24),
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
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(22),
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
        borderRadius:
        BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
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
    final firstWord =
        example.english.split(' ').first;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC8DFF7),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color: AppColors.amber,
            size: 23,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '"$firstWord" sentence-এর গুরুত্বপূর্ণ word হিসেবে ব্যবহার হয়েছে।',
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
                onPressed: isFirst || isLoading
                    ? null
                    : onPrevious,
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
                  onPressed:
                  isLoading ? null : onNext,
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