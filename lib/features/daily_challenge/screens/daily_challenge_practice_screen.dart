import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/constants/app_colors.dart';
import '../../question_making/services/question_making_audio_service.dart';
import '../data/daily_challenge_data.dart';
import '../models/daily_challenge_item.dart';
import '../services/daily_challenge_progress_service.dart';

class DailyChallengePracticeScreen
    extends StatefulWidget {
  const DailyChallengePracticeScreen({
    super.key,
  });

  @override
  State<DailyChallengePracticeScreen> createState() =>
      _DailyChallengePracticeScreenState();
}

class _DailyChallengePracticeScreenState
    extends State<DailyChallengePracticeScreen> {
  late final List<DailyChallengeItem> _items;

  final stt.SpeechToText _speech =
  stt.SpeechToText();

  int _currentIndex = 0;
  int _correct = 0;
  int _skipped = 0;

  String? _selectedOption;
  List<String> _selectedWords = <String>[];
  List<String> _availableWords = <String>[];

  bool _checked = false;
  bool _answered = false;
  bool _isListening = false;
  bool _speechAvailable = false;

  String _recognizedText = '';

  DailyChallengeItem get _item =>
      _items[_currentIndex];

  double get _progress =>
      ((_currentIndex + 1) / _items.length)
          .clamp(0.0, 1.0);

  bool get _buildCorrect {
    return _normalize(
      _selectedWords.join(' '),
    ) ==
        _normalize(_item.english);
  }

  @override
  void initState() {
    super.initState();

    _items = DailyChallengeData.today();

    _prepareItem();

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

  void _prepareItem() {
    _selectedOption = null;
    _selectedWords = <String>[];
    _availableWords = <String>[];
    _checked = false;
    _answered = false;
    _recognizedText = '';

    if (_item.type ==
        DailyChallengeItemType.basicSentence ||
        _item.type ==
            DailyChallengeItemType.questionMaking) {
      _availableWords =
      List<String>.from(_item.words)
        ..shuffle(Random());
    }
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[.!?,]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Color _itemColor() {
    switch (_item.type) {
      case DailyChallengeItemType.rule:
        return Colors.green;
      case DailyChallengeItemType.basicSentence:
        return Colors.blue;
      case DailyChallengeItemType.questionMaking:
        return Colors.orange;
      case DailyChallengeItemType.speaking:
        return Colors.deepPurple;
    }
  }

  IconData _itemIcon() {
    switch (_item.type) {
      case DailyChallengeItemType.rule:
        return Icons.menu_book_rounded;
      case DailyChallengeItemType.basicSentence:
        return Icons.chat_bubble_rounded;
      case DailyChallengeItemType.questionMaking:
        return Icons.quiz_rounded;
      case DailyChallengeItemType.speaking:
        return Icons.mic_rounded;
    }
  }

  String _itemLabel() {
    switch (_item.type) {
      case DailyChallengeItemType.rule:
        return 'RULE QUESTION';
      case DailyChallengeItemType.basicSentence:
        return 'BASIC SENTENCE';
      case DailyChallengeItemType.questionMaking:
        return 'BUILD QUESTION';
      case DailyChallengeItemType.speaking:
        return 'SPEAKING';
    }
  }

  Future<void> _speak(String text) async {
    await QuestionMakingAudioService.speak(text);
  }

  void _selectOption(String option) {
    if (_answered) {
      return;
    }

    setState(() {
      _selectedOption = option;
      _checked = false;
    });
  }

  void _selectWord(String word) {
    if (_answered) {
      return;
    }

    setState(() {
      _checked = false;
      _availableWords.remove(word);
      _selectedWords.add(word);
    });

    unawaited(_speak(word));
  }

  void _removeWord(String word) {
    if (_answered) {
      return;
    }

    setState(() {
      _checked = false;
      _selectedWords.remove(word);
      _availableWords.add(word);
    });
  }

  Future<void> _checkAnswer() async {
    if (_answered) {
      return;
    }

    if (_item.type ==
        DailyChallengeItemType.rule) {
      if (_selectedOption == null) {
        return;
      }

      if (!_checked) {
        setState(() {
          _checked = true;
        });

        await QuestionMakingAudioService.feedback(
          correct:
          _selectedOption == _item.correctAnswer,
        );

        return;
      }

      if (_selectedOption == _item.correctAnswer) {
        await _finishItem(isCorrect: true);
      } else {
        setState(() {
          _checked = false;
          _selectedOption = null;
        });
      }

      return;
    }

    if (_selectedWords.length !=
        _item.words.length) {
      return;
    }

    if (!_checked) {
      setState(() {
        _checked = true;
      });

      await QuestionMakingAudioService.feedback(
        correct: _buildCorrect,
      );

      return;
    }

    if (_buildCorrect) {
      await _finishItem(isCorrect: true);
    } else {
      setState(() {
        _checked = false;
        _selectedWords = <String>[];
        _availableWords =
        List<String>.from(_item.words)
          ..shuffle(Random());
      });
    }
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

    final bool correct =
        _normalize(_recognizedText) ==
            _normalize(_item.english);

    await QuestionMakingAudioService.feedback(
      correct: correct,
    );

    await _finishItem(
      isCorrect: correct,
    );
  }

  Future<void> _finishItem({
    required bool isCorrect,
  }) async {
    if (_answered) {
      return;
    }

    setState(() {
      _answered = true;
    });

    await DailyChallengeProgressService.markAnswer(
      itemId: _item.id,
      correct: isCorrect,
    );

    if (isCorrect) {
      _correct++;
    }

    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    if (!mounted) {
      return;
    }

    if (_currentIndex >= _items.length - 1) {
      final bool xpAwarded =
      await DailyChallengeProgressService
          .completeChallenge();

      final DailyChallengeState state =
      await DailyChallengeProgressService
          .getState();

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) {
            return DailyChallengeResultScreen(
              total: _items.length,
              correct: _correct,
              skipped: _skipped,
              xpAwarded: xpAwarded,
              streak: state.streak,
            );
          },
        ),
      );

      return;
    }

    setState(() {
      _currentIndex++;
      _prepareItem();
    });
  }

  Future<void> _skip() async {
    if (_answered) {
      return;
    }

    _skipped++;

    await QuestionMakingAudioService.speak(
      'Skipped',
    );

    await _finishItem(
      isCorrect: false,
    );
  }

  Widget _buildRuleView() {
    final Color color = _itemColor();

    return _Panel(
      color: color,
      icon: _itemIcon(),
      label: _itemLabel(),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _item.bengali,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          ..._item.options.map(
                (String option) {
              final bool selected =
                  _selectedOption == option;

              final bool correct =
                  _checked &&
                      option == _item.correctAnswer;

              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: InkWell(
                  onTap: () {
                    _selectOption(option);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: correct
                          ? Colors.green.withAlpha(20)
                          : selected
                          ? color.withAlpha(20)
                          : Colors.white,
                      borderRadius:
                      BorderRadius.circular(14),
                      border: Border.all(
                        color: correct
                            ? Colors.green
                            : selected
                            ? color
                            : Colors.black.withAlpha(30),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: correct
                            ? Colors.green
                            : AppColors.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_checked) ...<Widget>[
            const SizedBox(height: 8),
            _Feedback(
              correct:
              _selectedOption == _item.correctAnswer,
            ),
          ],
          const SizedBox(height: 15),
          _ActionButton(
            label: _checked &&
                _selectedOption ==
                    _item.correctAnswer
                ? 'Continue'
                : _checked
                ? 'Try Again'
                : 'Check Answer',
            color: color,
            icon: _checked &&
                _selectedOption ==
                    _item.correctAnswer
                ? Icons.arrow_forward_rounded
                : Icons.check_rounded,
            onPressed: _selectedOption == null
                ? null
                : () {
              unawaited(_checkAnswer());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWordsView() {
    final Color color = _itemColor();

    return _Panel(
      color: color,
      icon: _itemIcon(),
      label: _itemLabel(),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _item.bengali,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Voice hint',
                onPressed: () {
                  _speak(_item.english);
                },
                icon: Icon(
                  Icons.volume_up_rounded,
                  color: color,
                  size: 27,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap the speaker for a voice hint',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 17),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 76,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _checked
                    ? (_buildCorrect
                    ? Colors.green
                    : Colors.red)
                    : color.withAlpha(60),
              ),
            ),
            child: _selectedWords.isEmpty
                ? const Center(
              child: Text(
                'Build the sentence here',
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
                      _removeWord(word);
                    },
                    borderRadius:
                    BorderRadius.circular(10),
                    child: _WordChip(
                      word: word,
                      color: _checked
                          ? (_buildCorrect
                          ? Colors.green
                          : Colors.red)
                          : color,
                    ),
                  );
                },
              ).toList(),
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Words you can use',
            style: TextStyle(
              color: AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
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
          if (_checked) ...<Widget>[
            const SizedBox(height: 18),
            _Feedback(
              correct: _buildCorrect,
            ),
          ],
          const SizedBox(height: 23),
          _ActionButton(
            label: _checked
                ? (_buildCorrect
                ? 'Continue'
                : 'Try Again')
                : 'Check Answer',
            color: color,
            icon: _checked && _buildCorrect
                ? Icons.arrow_forward_rounded
                : _checked
                ? Icons.refresh_rounded
                : Icons.check_rounded,
            onPressed: _selectedWords.length ==
                _item.words.length
                ? () {
              unawaited(_checkAnswer());
            }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakingView() {
    final Color color = _itemColor();

    return _Panel(
      color: color,
      icon: _itemIcon(),
      label: _itemLabel(),
      child: Column(
        children: <Widget>[
          Text(
            _item.bengali,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 28),
          InkWell(
            onTap: _isListening
                ? () {
              unawaited(_stopListening());
            }
                : () {
              unawaited(_startListening());
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
                    color: color.withAlpha(60),
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
          const SizedBox(height: 16),
          Text(
            _isListening
                ? 'Listening...'
                : 'Tap the microphone',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (_recognizedText.isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: color.withAlpha(70),
                ),
              ),
              child: Text(
                'Recognized:\n$_recognizedText',
                style: const TextStyle(
                  color: AppColors.navy,
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
              unawaited(_submitSpeaking());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;

    switch (_item.type) {
      case DailyChallengeItemType.rule:
        content = _buildRuleView();
      case DailyChallengeItemType.basicSentence:
      case DailyChallengeItemType.questionMaking:
        content = _buildWordsView();
      case DailyChallengeItemType.speaking:
        content = _buildSpeakingView();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        title: const Text(
          'Daily Challenge',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 18,
            ),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${_items.length}',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w900,
                ),
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
                4,
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
                          _itemColor(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(_progress * 100).round()}%',
                    style: TextStyle(
                      color: _itemColor(),
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
                  22,
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
                  unawaited(_skip());
                },
                icon: const Icon(
                  Icons.skip_next_rounded,
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

class DailyChallengeResultScreen
    extends StatelessWidget {
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
    final int percentage = total == 0
        ? 0
        : ((correct / total) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Challenge Result',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            28,
          ),
          child: Column(
            children: <Widget>[
              const Icon(
                Icons.celebration_rounded,
                color: AppColors.amber,
                size: 72,
              ),
              const SizedBox(height: 15),
              Text(
                percentage >= 80
                    ? 'Challenge Complete!'
                    : 'Good effort!',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$correct/$total correct',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 25),
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 13,
                  ),
                ),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Your Score',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                    color: Colors.black.withAlpha(18),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _ResultValue(
                        icon: Icons.star_rounded,
                        value: xpAwarded
                            ? '+50 XP'
                            : '+0 XP',
                        label: 'Earned',
                        color: AppColors.amber,
                      ),
                    ),
                    Expanded(
                      child: _ResultValue(
                        icon: Icons.check_circle_rounded,
                        value: '$correct',
                        label: 'Correct',
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: _ResultValue(
                        icon: Icons.local_fire_department_rounded,
                        value: '$streak',
                        label: 'Day Streak',
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                '$skipped question(s) skipped',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                          (Route<dynamic> route) {
                        return route.isFirst;
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Widget child;

  const _Panel({
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
          color: color.withAlpha(60),
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
                  color: color.withAlpha(22),
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
                  letterSpacing: 1.2,
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

class _Feedback extends StatelessWidget {
  final bool correct;

  const _Feedback({
    required this.correct,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
    correct ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(17),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withAlpha(70),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            correct
                ? Icons.check_circle_rounded
                : Icons.refresh_rounded,
            color: color,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              correct
                  ? 'Perfect!'
                  : 'Not quite. Try again.',
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

class _ResultValue extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ResultValue({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(
          icon,
          color: color,
          size: 27,
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.navy,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}