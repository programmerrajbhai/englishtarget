import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/microphone_disclosure.dart';
import '../models/basic_sentence.dart';
import '../models/basic_sentence_activity.dart';
import '../models/basic_sentence_topic.dart';
import '../services/basic_sentence_funnel.dart';
import '../services/basic_sentence_progress_service.dart';
import 'basic_sentence_result_screen.dart';

class BasicSentenceSessionScreen extends StatefulWidget {
  final BasicSentenceTopic topic;

  const BasicSentenceSessionScreen({
    super.key,
    required this.topic,
  });

  @override
  State<BasicSentenceSessionScreen> createState() =>
      _BasicSentenceSessionScreenState();
}

class _BasicSentenceSessionScreenState
    extends State<BasicSentenceSessionScreen> {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  final Random _random = Random();

  late final List<BasicSentenceActivity> _activities;

  // 100% FIXED: Removed 'late' and initialized with an empty list to prevent LateInitializationError
  List<String> _shuffledWords = <String>[];

  List<String> _mcqOptions = <String>[];
  String _selectedMcqOption = '';

  int _currentIndex = 0;
  int _correct = 0;
  int _skipped = 0;
  int _speechScore = 0;

  bool _checked = false;
  bool _isCorrect = false;
  bool _isListening = false;
  bool _speechReady = false;
  bool _speechInitializing = false;

  String _buildAnswer = '';
  String _recognizedText = '';

  final Set<int> _usedWords = <int>{};

  BasicSentenceActivity? get _currentActivity {
    if (_activities.isEmpty || _currentIndex >= _activities.length) {
      return null;
    }
    return _activities[_currentIndex];
  }

  @override
  void initState() {
    super.initState();

    _activities = BasicSentenceFunnel.createSession(
      widget.topic,
    );

    _prepareActivityData();
    unawaited(_setupTts());
    unawaited(_recordCurrentActivity());
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }

  Future<void> _recordCurrentActivity() async {
    final BasicSentenceActivity? activity = _currentActivity;
    if (activity == null) return;

    await BasicSentenceProgressService.markAttended(
      topicId: widget.topic.id,
      activityId: activity.id,
    );
  }

  void _prepareActivityData() {
    final BasicSentenceActivity? activity = _currentActivity;

    // FIXED: Always reset lists before preparing new data to avoid state leaks and errors
    _shuffledWords = <String>[];
    _mcqOptions = <String>[];

    if (activity == null) {
      return;
    }

    if (activity.type == BasicSentenceActivityType.build) {
      final List<String> originalWords =
      List<String>.from(activity.sentence.words);

      _shuffledWords = List<String>.from(originalWords);

      if (_shuffledWords.length > 1) {
        int attempts = 0;
        do {
          _shuffledWords.shuffle(_random);
          attempts++;
        } while (
        _shuffledWords.join('|') == originalWords.join('|') &&
            attempts < 10);
      }
    } else if (activity.type == BasicSentenceActivityType.mcq) {
      final String correctEnglish = activity.sentence.english;
      final Set<String> options = <String>{correctEnglish};

      // Generate fake options from the same topic for natural feel
      final List<BasicSentence> allTopicSentences = <BasicSentence>[
        ...widget.topic.learnSentences,
        ...widget.topic.buildSentences,
        ...widget.topic.speakSentences,
      ]..shuffle(_random);

      for (final BasicSentence s in allTopicSentences) {
        if (options.length >= 3) break;
        if (s.english != correctEnglish) {
          options.add(s.english);
        }
      }

      _mcqOptions = options.toList()..shuffle(_random);
    }
  }

  Future<void> _speakText(String text) async {
    await _speech.stop();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> _stopAudio() async {
    await _tts.stop();
    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _isListening = false;
    });
  }

  Future<void> _initializeSpeech() async {
    if (_speechInitializing) return;

    setState(() {
      _speechInitializing = true;
    });

    try {
      final bool ready = await _speech.initialize(
        onStatus: (String status) {
          if (!mounted) return;
          setState(() {
            _isListening = status == 'listening';
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
        _speechInitializing = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _speechReady = false;
        _speechInitializing = false;
      });
    }
  }

  Future<void> _toggleMicrophone() async {
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      return;
    }

    final bool accepted =
    await MicrophoneDisclosure.ensureAccepted(context);

    if (!accepted || !mounted) {
      return;
    }

    if (!_speechReady) {
      await _initializeSpeech();

      if (!mounted) return;

      if (!_speechReady) {
        _showMessage(
          'Microphone permission denied or speech service is unavailable.',
        );
        return;
      }
    }

    await _tts.stop();

    if (!mounted) return;

    setState(() {
      _recognizedText = '';
      _speechScore = 0;
      _checked = false;
    });

    try {
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(seconds: 12),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          localeId: 'en_US',
        ),
        onResult: (SpeechRecognitionResult result) {
          if (!mounted) return;
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
      );

      if (!mounted) return;

      setState(() {
        _isListening = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      _showMessage(
        'Speaking practice শুরু করা যায়নি। আবার চেষ্টা করুন।',
      );
    }
  }

  int _calculateSpeakingScore({
    required String spoken,
    required String expected,
  }) {
    final String actualText = _normalize(spoken);
    final String expectedText = _normalize(expected);

    if (actualText.isEmpty || expectedText.isEmpty) {
      return 0;
    }

    if (actualText == expectedText) {
      return 100;
    }

    final Set<String> actualWords = actualText.split(' ').toSet();
    final Set<String> expectedWords = expectedText.split(' ').toSet();

    final int matched =
        actualWords.intersection(expectedWords).length;

    if (expectedWords.isEmpty) return 0;

    return ((matched / expectedWords.length) * 100).round().clamp(0, 100);
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll(RegExp(r"[^a-z0-9']+"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _skipActivity() async {
    await _stopAudio();
    if (!mounted) return;

    setState(() {
      _skipped++;
    });

    await _moveNext();
  }

  Future<void> _moveNext() async {
    await _stopAudio();

    if (!mounted) return;

    if (_currentIndex + 1 >= _activities.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BasicSentenceResultScreen(
            topic: widget.topic,
            total: _activities.length,
            correct: _correct,
            skipped: _skipped,
          ),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex++;
      _checked = false;
      _isCorrect = false;
      _speechScore = 0;
      _buildAnswer = '';
      _recognizedText = '';
      _selectedMcqOption = '';
      _mcqOptions.clear();
      _usedWords.clear();

      _prepareActivityData();
    });

    unawaited(_recordCurrentActivity());
  }

  void _completeLearnActivity() {
    if (_checked) {
      unawaited(_moveNext());
      return;
    }

    setState(() {
      _checked = true;
      _isCorrect = true;
      _correct++;
    });
  }

  void _selectWord(int index, String word) {
    if (_checked || _usedWords.contains(index)) {
      return;
    }

    unawaited(_speakText(word));

    setState(() {
      _usedWords.add(index);
      _buildAnswer = '$_buildAnswer $word'.trim();
    });
  }

  void _checkBuildAnswer() {
    final BasicSentenceActivity? activity = _currentActivity;
    if (activity == null) return;

    if (_checked) {
      unawaited(_moveNext());
      return;
    }

    final String expected = _normalize(activity.sentence.english);
    final bool correct = _normalize(_buildAnswer) == expected;

    setState(() {
      _checked = true;
      _isCorrect = correct;

      if (correct) {
        _correct++;
      }
    });

    if (correct) {
      unawaited(_speakText(activity.sentence.english));
    }
  }

  void _checkMcqAnswer() {
    final BasicSentenceActivity? activity = _currentActivity;
    if (activity == null) return;

    if (_checked) {
      unawaited(_moveNext());
      return;
    }

    final bool correct = _selectedMcqOption == activity.sentence.english;

    setState(() {
      _checked = true;
      _isCorrect = correct;

      if (correct) {
        _correct++;
      }
    });

    if (correct) {
      unawaited(_speakText(activity.sentence.english));
    }
  }

  void _checkSpeakingAnswer() {
    final BasicSentenceActivity? activity = _currentActivity;
    if (activity == null) return;

    if (_checked) {
      unawaited(_moveNext());
      return;
    }

    final int score = _calculateSpeakingScore(
      spoken: _recognizedText,
      expected: activity.sentence.english,
    );

    final bool correct = score >= 70;

    setState(() {
      _checked = true;
      _speechScore = score;
      _isCorrect = correct;

      if (correct) {
        _correct++;
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: AppColors.navy,
        ),
      );
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    unawaited(_speech.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BasicSentenceActivity? activity = _currentActivity;

    if (activity == null) {
      return _EmptySessionState(
        topic: widget.topic,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.topic.title),
        actions: <Widget>[
          TextButton(
            onPressed: _skipActivity,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 7, 20, 18),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _activities.length,
                        minHeight: 8,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.topic.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_currentIndex + 1}/${_activities.length}',
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: _ActivityContent(
                  activity: activity,
                  checked: _checked,
                  isCorrect: _isCorrect,
                  buildAnswer: _buildAnswer,
                  shuffledWords: _shuffledWords,
                  usedWords: _usedWords,
                  recognizedText: _recognizedText,
                  speechScore: _speechScore,
                  isListening: _isListening,
                  speechInitializing: _speechInitializing,
                  selectedMcqOption: _selectedMcqOption,
                  mcqOptions: _mcqOptions,
                  onListen: () {
                    unawaited(
                      _speakText(activity.sentence.english),
                    );
                  },
                  onLearnContinue: _completeLearnActivity,
                  onBuildCheck: _checkBuildAnswer,
                  onWordTap: _selectWord,
                  onMicrophone: _toggleMicrophone,
                  onSpeakCheck: _checkSpeakingAnswer,
                  onSpeakContinue: () {
                    unawaited(_moveNext());
                  },
                  onMcqCheck: _checkMcqAnswer,
                  onMcqOptionTap: (String option) {
                    setState(() {
                      _selectedMcqOption = option;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityContent extends StatelessWidget {
  final BasicSentenceActivity activity;
  final bool checked;
  final bool isCorrect;
  final String buildAnswer;
  final List<String> shuffledWords;
  final Set<int> usedWords;
  final String recognizedText;
  final int speechScore;
  final bool isListening;
  final bool speechInitializing;
  final String selectedMcqOption;
  final List<String> mcqOptions;

  final VoidCallback onListen;
  final VoidCallback onLearnContinue;
  final VoidCallback onBuildCheck;
  final void Function(int index, String word) onWordTap;
  final VoidCallback onMicrophone;
  final VoidCallback onSpeakCheck;
  final VoidCallback onSpeakContinue;
  final VoidCallback onMcqCheck;
  final void Function(String option) onMcqOptionTap;

  const _ActivityContent({
    required this.activity,
    required this.checked,
    required this.isCorrect,
    required this.buildAnswer,
    required this.shuffledWords,
    required this.usedWords,
    required this.recognizedText,
    required this.speechScore,
    required this.isListening,
    required this.speechInitializing,
    required this.selectedMcqOption,
    required this.mcqOptions,
    required this.onListen,
    required this.onLearnContinue,
    required this.onBuildCheck,
    required this.onWordTap,
    required this.onMicrophone,
    required this.onSpeakCheck,
    required this.onSpeakContinue,
    required this.onMcqCheck,
    required this.onMcqOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (activity.type) {
      case BasicSentenceActivityType.learn:
        return _LearnCard(
          activity: activity,
          checked: checked,
          onListen: onListen,
          onContinue: onLearnContinue,
        );

      case BasicSentenceActivityType.mcq:
        return _McqCard(
          activity: activity,
          checked: checked,
          isCorrect: isCorrect,
          selectedOption: selectedMcqOption,
          options: mcqOptions,
          onListen: onListen,
          onCheck: onMcqCheck,
          onOptionTap: onMcqOptionTap,
        );

      case BasicSentenceActivityType.build:
        return _BuildCard(
          activity: activity,
          checked: checked,
          isCorrect: isCorrect,
          answer: buildAnswer,
          shuffledWords: shuffledWords,
          usedWords: usedWords,
          onListen: onListen,
          onCheck: onBuildCheck,
          onWordTap: onWordTap,
        );

      case BasicSentenceActivityType.speak:
        return _SpeakCard(
          activity: activity,
          checked: checked,
          isCorrect: isCorrect,
          recognizedText: recognizedText,
          speechScore: speechScore,
          isListening: isListening,
          speechInitializing: speechInitializing,
          onListen: onListen,
          onMicrophone: onMicrophone,
          onCheck: onSpeakCheck,
          onContinue: onSpeakContinue,
        );
    }
  }
}

class _LearnCard extends StatelessWidget {
  final BasicSentenceActivity activity;
  final bool checked;
  final VoidCallback onListen;
  final VoidCallback onContinue;

  const _LearnCard({
    required this.activity,
    required this.checked,
    required this.onListen,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return _ActivityCard(
      color: AppColors.primary,
      label: 'LEARN',
      icon: Icons.menu_book_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Listen and understand this sentence',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            activity.sentence.bengali,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  activity.sentence.english,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onListen,
                icon: const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Listen, understand, then continue.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: onContinue,
              child: Text(
                checked ? 'Continue' : 'I understand',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _McqCard extends StatelessWidget {
  final BasicSentenceActivity activity;
  final bool checked;
  final bool isCorrect;
  final String selectedOption;
  final List<String> options;
  final VoidCallback onListen;
  final VoidCallback onCheck;
  final void Function(String option) onOptionTap;

  const _McqCard({
    required this.activity,
    required this.checked,
    required this.isCorrect,
    required this.selectedOption,
    required this.options,
    required this.onListen,
    required this.onCheck,
    required this.onOptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ActivityCard(
      color: AppColors.amber,
      label: 'QUIZ',
      icon: Icons.quiz_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Select the correct translation',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  activity.sentence.bengali,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onListen,
                icon: const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...options.map((String option) {
            final bool isSelected = selectedOption == option;
            final bool isRightAnswer = option == activity.sentence.english;

            Color borderColor = AppColors.border;
            Color bgColor = Colors.white;
            Color textColor = AppColors.navy;

            if (checked) {
              if (isRightAnswer) {
                borderColor = AppColors.mint;
                bgColor = AppColors.mint.withAlpha(30);
                textColor = AppColors.primary;
              } else if (isSelected && !isRightAnswer) {
                borderColor = AppColors.error;
                bgColor = AppColors.error.withAlpha(30);
                textColor = AppColors.error;
              }
            } else if (isSelected) {
              borderColor = AppColors.amber;
              bgColor = AppColors.amber.withAlpha(20);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: checked ? null : () => onOptionTap(option),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor,
                      width: isSelected || (checked && isRightAnswer) ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: isSelected || (checked && isRightAnswer)
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
          if (checked) ...<Widget>[
            const SizedBox(height: 10),
            _FeedbackBox(
              isCorrect: isCorrect,
              correctAnswer: activity.sentence.english,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: selectedOption.isEmpty && !checked ? null : onCheck,
              child: Text(
                checked ? 'Continue' : 'Check answer',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildCard extends StatelessWidget {
  final BasicSentenceActivity activity;
  final bool checked;
  final bool isCorrect;
  final String answer;
  final List<String> shuffledWords;
  final Set<int> usedWords;

  final VoidCallback onListen;
  final VoidCallback onCheck;
  final void Function(int index, String word) onWordTap;

  const _BuildCard({
    required this.activity,
    required this.checked,
    required this.isCorrect,
    required this.answer,
    required this.shuffledWords,
    required this.usedWords,
    required this.onListen,
    required this.onCheck,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ActivityCard(
      color: AppColors.blue,
      label: 'BUILD',
      icon: Icons.extension_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Arrange the words correctly',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  activity.sentence.bengali,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onListen,
                icon: const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              minHeight: 72,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5FAFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.blue.withAlpha(60),
              ),
            ),
            child: Text(
              answer.isEmpty ? 'Tap the words below' : answer,
              style: TextStyle(
                color: answer.isEmpty
                    ? AppColors.textSecondary
                    : AppColors.navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: <Widget>[
              for (int index = 0; index < shuffledWords.length; index++)
                ActionChip(
                  label: Text(shuffledWords[index]),
                  onPressed: checked || usedWords.contains(index)
                      ? null
                      : () {
                    onWordTap(
                      index,
                      shuffledWords[index],
                    );
                  },
                ),
            ],
          ),
          if (checked) ...<Widget>[
            const SizedBox(height: 20),
            _FeedbackBox(
              isCorrect: isCorrect,
              correctAnswer: activity.sentence.english,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: answer.isEmpty && !checked ? null : onCheck,
              child: Text(
                checked ? 'Continue' : 'Check answer',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeakCard extends StatelessWidget {
  final BasicSentenceActivity activity;
  final bool checked;
  final bool isCorrect;
  final String recognizedText;
  final int speechScore;
  final bool isListening;
  final bool speechInitializing;

  final VoidCallback onListen;
  final VoidCallback onMicrophone;
  final VoidCallback onCheck;
  final VoidCallback onContinue;

  const _SpeakCard({
    required this.activity,
    required this.checked,
    required this.isCorrect,
    required this.recognizedText,
    required this.speechScore,
    required this.isListening,
    required this.speechInitializing,
    required this.onListen,
    required this.onMicrophone,
    required this.onCheck,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return _ActivityCard(
      color: AppColors.purple,
      label: 'SPEAK',
      icon: Icons.mic_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Say this sentence in English',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            activity.sentence.bengali,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onListen,
              icon: const Icon(
                Icons.volume_up_rounded,
                color: AppColors.purple,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: onMicrophone,
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),
                width: isListening ? 108 : 94,
                height: isListening ? 108 : 94,
                decoration: BoxDecoration(
                  color: isListening
                      ? AppColors.purple
                      : AppColors.purple.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.purple,
                    width: 4,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.purple.withAlpha(
                        isListening ? 80 : 25,
                      ),
                      blurRadius: isListening ? 24 : 12,
                      spreadRadius: isListening ? 4 : 0,
                    ),
                  ],
                ),
                child: Icon(
                  isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: isListening ? Colors.white : AppColors.purple,
                  size: 44,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              speechInitializing
                  ? 'Preparing microphone...'
                  : isListening
                  ? 'Listening...'
                  : 'Tap the microphone and speak',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (recognizedText.isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F4FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'Recognized: $recognizedText',
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          if (checked) ...<Widget>[
            const SizedBox(height: 18),
            _FeedbackBox(
              isCorrect: isCorrect,
              correctAnswer:
              '${activity.sentence.english}  Score: $speechScore%',
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: checked
                  ? onContinue
                  : recognizedText.isEmpty
                  ? null
                  : onCheck,
              child: Text(
                checked ? 'Continue' : 'Check speaking',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;
  final Widget child;

  const _ActivityCard({
    required this.color,
    required this.label,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

class _FeedbackBox extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;

  const _FeedbackBox({
    required this.isCorrect,
    required this.correctAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = isCorrect ? AppColors.primary : AppColors.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        isCorrect ? 'Perfect!' : 'Correct answer: $correctAnswer',
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptySessionState extends StatelessWidget {
  final BasicSentenceTopic topic;

  const _EmptySessionState({
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(topic.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.library_books_rounded,
                color: topic.color,
                size: 64,
              ),
              const SizedBox(height: 18),
              const Text(
                'Sentence data is not available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'এই topic-এর data যোগ করলে ২৫টি practice automaticভাবে আসবে।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to topics'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}