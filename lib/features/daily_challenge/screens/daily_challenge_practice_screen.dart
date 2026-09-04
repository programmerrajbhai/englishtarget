import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/ads/ad_manager.dart';
import '../../../core/ads/banner_ad_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/microphone_disclosure.dart';
import '../../question_making/services/question_making_audio_service.dart';
import '../data/daily_challenge_data.dart';
import '../models/daily_challenge_item.dart';
import '../services/daily_challenge_progress_service.dart';

class DailyChallengePracticeScreen extends StatefulWidget {
  const DailyChallengePracticeScreen({super.key});

  @override
  State<DailyChallengePracticeScreen> createState() =>
      _DailyChallengePracticeScreenState();
}

class _DailyChallengePracticeScreenState
    extends State<DailyChallengePracticeScreen> {
  late final List<DailyChallengeItem> _items;
  final stt.SpeechToText _speech = stt.SpeechToText();

  int _currentIndex = 0;
  int _correct = 0;
  int _skipped = 0;

  String? _selectedOption;
  List<String> _selectedWords = <String>[];
  List<String> _availableWords = <String>[];

  bool _isChecked = false;
  bool _isCorrect = false;
  bool _answered = false;

  bool _isListening = false;
  bool _speechAvailable = false;
  bool _speechInitializing = false;
  bool _speechInitializationAttempted = false;
  String _recognizedText = '';

  DailyChallengeItem get _item => _items[_currentIndex];

  double get _progress =>
      ((_currentIndex + 1) / _items.length).clamp(0.0, 1.0);

  @override
  void initState() {
    super.initState();
    _items = DailyChallengeData.today();
    _prepareItem();
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

  void _prepareItem() {
    _selectedOption = null;
    _selectedWords = <String>[];
    _availableWords = <String>[];
    _isChecked = false;
    _isCorrect = false;
    _answered = false;
    _recognizedText = '';
    _isListening = false;

    if (_item.type == DailyChallengeItemType.basicSentence ||
        _item.type == DailyChallengeItemType.questionMaking) {
      _availableWords = List<String>.from(_item.words)..shuffle(Random());
    }
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

  // --- LOGIC METHODS ---

  void _selectOption(String option) {
    if (_isChecked) return;
    setState(() {
      _selectedOption = option;
    });
  }

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

    final bool accepted =
    await MicrophoneDisclosure.ensureAccepted(context);
    if (!accepted || !mounted) return;

    if (!_speechAvailable) {
      final bool available = await _initializeSpeech();
      if (!available || !mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
                content: Text('Microphone permission denied or service unavailable.')),
          );
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
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Speaking practice failed. Please try again.')),
        );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  Future<void> _checkAnswer() async {
    if (_isListening) await _stopListening();

    bool isCorrect = false;

    if (_item.type == DailyChallengeItemType.rule) {
      isCorrect = _selectedOption == _item.correctAnswer;
    } else if (_item.type == DailyChallengeItemType.basicSentence ||
        _item.type == DailyChallengeItemType.questionMaking) {
      isCorrect = _normalize(_selectedWords.join(' ')) == _normalize(_item.english);
    } else if (_item.type == DailyChallengeItemType.speaking) {
      final actualWords = _normalize(_recognizedText).split(' ').toSet();
      final expectedWords = _normalize(_item.english).split(' ').toSet();
      final matched = actualWords.intersection(expectedWords).length;
      final score = expectedWords.isEmpty ? 0 : ((matched / expectedWords.length) * 100).round();
      isCorrect = score >= 70; // 70% accuracy is required
    }

    setState(() {
      _isChecked = true;
      _isCorrect = isCorrect;
    });

    await QuestionMakingAudioService.feedback(correct: isCorrect);
    if (isCorrect) {
      unawaited(_speak(_item.english));
    }
  }

  Future<void> _skipActivity() async {
    if (_isChecked) return;
    if (_isListening) await _stopListening();

    setState(() {
      _skipped++;
    });

    await QuestionMakingAudioService.speak('Skipped');
    await _finishItem(isCorrect: false);
  }

  Future<void> _moveToNext() async {
    if (_isCorrect) {
      _correct++;
    }
    await _finishItem(isCorrect: _isCorrect);
  }

  Future<void> _finishItem({required bool isCorrect}) async {
    if (_answered) return;

    setState(() {
      _answered = true;
    });

    await DailyChallengeProgressService.markAnswer(
      itemId: _item.id,
      correct: isCorrect,
    );

    if (!mounted) return;

    if (_currentIndex >= _items.length - 1) {
      final bool xpAwarded =
      await DailyChallengeProgressService.completeChallenge();
      final DailyChallengeState state =
      await DailyChallengeProgressService.getState();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => DailyChallengeResultScreen(
            total: _items.length,
            correct: _correct,
            skipped: _skipped,
            xpAwarded: xpAwarded,
            streak: state.streak,
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex++;
      _prepareItem();
    });
  }

  @override
  void dispose() {
    unawaited(_speech.stop());
    unawaited(_speech.cancel());
    unawaited(QuestionMakingAudioService.stop());
    super.dispose();
  }

  // --- UI BUILDERS ---

  Widget _buildRuleView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fill in the blank',
          style: TextStyle(color: AppColors.navy, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 15),
        Text(_item.bengali, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 25),
        ..._item.options.map((String option) {
          final bool isSelected = _selectedOption == option;
          final bool isRightAnswer = option == _item.correctAnswer;

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
            borderColor = Colors.blue;
            bgColor = Colors.blue.withAlpha(20);
            textColor = Colors.blue;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: _isChecked ? null : () => _selectOption(option),
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
                      const BoxShadow(color: Color(0xFFE5E5E5), offset: Offset(0, 4))
                    else if (isSelected && !_isChecked)
                      BoxShadow(color: Colors.blue.withAlpha(80), offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: isSelected || (_isChecked && isRightAnswer) ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWordsView() {
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
                _item.bengali,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
            IconButton(
              onPressed: () => _speak(_item.english),
              icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 20),
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
            child: Text('Tap words to build', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold)),
          )
              : Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _selectedWords.map((word) => GestureDetector(
              onTap: () => _removeSelectedWord(word),
              child: _Word3DChip(word: word, color: Colors.blue),
            )).toList(),
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: _availableWords.map((word) => GestureDetector(
            onTap: () => _selectWord(word),
            child: _Word3DChip(word: word, color: AppColors.navy),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSpeakingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Speak in English',
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
                _item.bengali,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 15),
              Text(
                _item.english,
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
              color: _isListening ? Colors.red : Colors.deepPurple,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? Colors.red : Colors.deepPurple).withAlpha(60),
                  blurRadius: _isListening ? 30 : 10,
                  spreadRadius: _isListening ? 10 : 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 55),
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
        ],
        if (_speechInitializationAttempted && !_speechAvailable) ...[
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Speech service is not available.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  // --- PREMIUM BOTTOM BAR UI ---
  Widget _buildBottomBar() {
    if (!_isChecked) {
      final bool canCheck = (_item.type == DailyChallengeItemType.rule && _selectedOption != null) ||
          ((_item.type == DailyChallengeItemType.basicSentence || _item.type == DailyChallengeItemType.questionMaking) && _selectedWords.isNotEmpty) ||
          (_item.type == DailyChallengeItemType.speaking && _recognizedText.isNotEmpty);

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
      decoration: BoxDecoration(color: bgColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
              _item.english, // Always show full sentence as correction
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
                _selectedOption = null;
                _selectedWords.clear();
                if (_item.type == DailyChallengeItemType.basicSentence || _item.type == DailyChallengeItemType.questionMaking) {
                  _availableWords = List.from(_item.words)..shuffle();
                }
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
    if (_items.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final Widget content;
    switch (_item.type) {
      case DailyChallengeItemType.rule:
        content = _buildRuleView();
        break;
      case DailyChallengeItemType.basicSentence:
      case DailyChallengeItemType.questionMaking:
        content = _buildWordsView();
        break;
      case DailyChallengeItemType.speaking:
        content = _buildSpeakingView();
        break;
    }

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
  final Color color;

  const _Word3DChip({required this.word, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE5E5E5),
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Text(
        word,
        style: const TextStyle(
          color: AppColors.navy,
          fontSize: 18,
          fontWeight: FontWeight.w800,
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
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide.none,
          ),
        ).copyWith(
          side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed) || onPressed == null) {
              return const BorderSide(color: Colors.transparent, width: 0);
            }
            return BorderSide(color: shadowColor, width: 4); // Bottom shadow
          }),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0), // Text adjust
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

class DailyChallengeResultScreen extends StatelessWidget {
  final int total;
  final int correct;
  final int skipped;
  final bool xpAwarded;
  final int streak;

  const DailyChallengeResultScreen({
    super.key,
    required this.total,
    required this.correct,
    required this.skipped,
    required this.xpAwarded,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final int percentage = total == 0 ? 0 : ((correct / total) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: const Text('Challenge Result', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- STICKY BANNER AD START ---
            const BannerAdWidget(),
            // --- STICKY BANNER AD END ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.celebration_rounded, color: AppColors.amber, size: 72),
                    const SizedBox(height: 15),
                    Text(
                      percentage >= 80 ? 'Challenge Complete!' : 'Good effort!',
                      style: const TextStyle(color: AppColors.navy, fontSize: 25, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text('$correct/$total correct', style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    const SizedBox(height: 25),
                    Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: AppColors.primary, width: 13),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '$percentage%',
                            style: const TextStyle(color: AppColors.navy, fontSize: 35, fontWeight: FontWeight.w900),
                          ),
                          const Text('Your Score', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: Colors.black.withAlpha(18)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: _ResultValue(icon: Icons.star_rounded, value: xpAwarded ? '+50 XP' : '+0 XP', label: 'Earned', color: AppColors.amber)),
                          Expanded(child: _ResultValue(icon: Icons.check_circle_rounded, value: '$correct', label: 'Correct', color: AppColors.primary)),
                          Expanded(child: _ResultValue(icon: Icons.local_fire_department_rounded, value: '$streak', label: 'Day Streak', color: Colors.orange)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text('$skipped question(s) skipped', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          AdManager.instance.showInterstitialAd(
                            onAdDismissed: () {
                              // অ্যাড দেখা শেষ হলে বা কুলডাউনে থাকলে এই নেভিগেশন কাজ করবে
                              Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
                            },
                          );

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.w900)),
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

class _ResultValue extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ResultValue({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, color: color, size: 27),
        const SizedBox(height: 7),
        Text(value, style: const TextStyle(color: AppColors.navy, fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}