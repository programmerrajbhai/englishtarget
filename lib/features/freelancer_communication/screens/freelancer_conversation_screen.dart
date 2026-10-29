import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/microphone_disclosure.dart';
import '../models/freelancer_lesson.dart';
import '../services/freelancer_progress_service.dart';

enum BuyerAvatarState { idle, speaking, listening, thinking, success, retry }

class FreelancerConversationScreen extends StatefulWidget {
  final FreelancerLesson lesson;

  const FreelancerConversationScreen({super.key, required this.lesson});

  @override
  State<FreelancerConversationScreen> createState() =>
      _FreelancerConversationScreenState();
}

class _FreelancerConversationScreenState
    extends State<FreelancerConversationScreen> {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _replyController = TextEditingController();

  int _turnIndex = 0;
  int _totalScore = 0;
  int _lastScore = 0;
  bool _speechReady = false;
  bool _isListening = false;
  bool _checked = false;
  BuyerAvatarState _avatarState = BuyerAvatarState.idle;

  BuyerTurn get _turn => widget.lesson.conversation[_turnIndex];

  @override
  void initState() {
    super.initState();
    unawaited(_setupAndSpeak());
  }

  Future<void> _setupAndSpeak() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _speakBuyer();
  }

  Future<void> _speakBuyer() async {
    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _avatarState = BuyerAvatarState.speaking;
    });
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(_turn.buyerMessage);
    if (!mounted) return;
    setState(() => _avatarState = BuyerAvatarState.idle);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
          _avatarState = BuyerAvatarState.idle;
        });
      }
      return;
    }

    final bool accepted = await MicrophoneDisclosure.ensureAccepted(context);
    if (!accepted || !mounted) return;

    if (!_speechReady) {
      _speechReady = await _speech.initialize(
        onStatus: (String status) {
          if (!mounted) return;
          final bool listening = status == 'listening';
          setState(() {
            _isListening = listening;
            if (!listening && _avatarState == BuyerAvatarState.listening) {
              _avatarState = BuyerAvatarState.idle;
            }
          });
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _avatarState = BuyerAvatarState.retry;
          });
        },
      );
    }

    if (!_speechReady || !mounted) {
      _showMessage(
        'Speech recognition is unavailable. You can type your reply.',
      );
      return;
    }

    await _tts.stop();
    setState(() {
      _replyController.clear();
      _checked = false;
      _lastScore = 0;
      _isListening = true;
      _avatarState = BuyerAvatarState.listening;
    });

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
          _replyController.text = result.recognizedWords;
          _replyController.selection = TextSelection.collapsed(
            offset: _replyController.text.length,
          );
        });
      },
    );
  }

  Future<void> _checkReply() async {
    final String reply = _replyController.text.trim();
    if (reply.isEmpty) {
      _showMessage('Type or speak your reply first.');
      return;
    }

    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _avatarState = BuyerAvatarState.thinking;
    });

    await Future<void>.delayed(const Duration(milliseconds: 550));
    final int score = _bestReplyScore(reply, _turn.acceptedReplies);
    if (!mounted) return;
    setState(() {
      _checked = true;
      _lastScore = score;
      _avatarState = score >= 60
          ? BuyerAvatarState.success
          : BuyerAvatarState.retry;
    });
  }

  Future<void> _nextTurn() async {
    _totalScore += _lastScore;
    if (_turnIndex >= widget.lesson.conversation.length - 1) {
      await _finishConversation();
      return;
    }

    setState(() {
      _turnIndex++;
      _replyController.clear();
      _checked = false;
      _lastScore = 0;
      _avatarState = BuyerAvatarState.idle;
    });
    await _speakBuyer();
  }

  void _retry() {
    setState(() {
      _replyController.clear();
      _checked = false;
      _lastScore = 0;
      _avatarState = BuyerAvatarState.idle;
    });
  }

  Future<void> _finishConversation() async {
    final int finalScore = (_totalScore / widget.lesson.conversation.length)
        .round();
    await FreelancerProgressService.completeLesson(
      widget.lesson.id,
      finalScore,
    );
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 78,
                  height: 78,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.primary,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Conversation Complete!',
                  style: TextStyle(
                    color: AppColors.navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Communication score: $finalScore%',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  finalScore >= 75
                      ? 'Great work! Your replies were clear and professional.'
                      : 'Good attempt. Repeat this conversation to improve your score.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    if (mounted) Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue Learning',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    unawaited(_speech.stop());
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalTurns = widget.lesson.conversation.length;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: const Color(0xFFF5F8F6),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (_turnIndex + 1) / totalTurns,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_turnIndex + 1}/$totalTurns',
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(child: _BuyerAvatar(state: _avatarState)),
            const SizedBox(height: 12),
            Center(
              child: Text(
                _stateLabel(_avatarState),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .8,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _BuyerMessageCard(turn: _turn, onListen: _speakBuyer),
            const SizedBox(height: 16),
            TextField(
              controller: _replyController,
              minLines: 2,
              maxLines: 4,
              enabled: !_checked,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type or speak your reply…',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: _checked ? null : _toggleListening,
                  icon: Icon(
                    _isListening
                        ? Icons.stop_circle_rounded
                        : Icons.mic_rounded,
                    color: _isListening ? AppColors.error : AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.amber,
                  size: 18,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    _turn.hint,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (_checked) ...<Widget>[
              const SizedBox(height: 16),
              _FeedbackCard(
                score: _lastScore,
                bestReply: _turn.acceptedReplies.first,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: _checked
            ? Row(
                children: <Widget>[
                  if (_lastScore < 60) ...<Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _retry,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: _nextTurn,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _turnIndex == totalTurns - 1 ? 'See Result' : 'Next',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              )
            : FilledButton.icon(
                onPressed: _avatarState == BuyerAvatarState.thinking
                    ? null
                    : _checkReply,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text(
                  'Check My Reply',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _BuyerAvatar extends StatelessWidget {
  final BuyerAvatarState state;

  const _BuyerAvatar({required this.state});

  @override
  Widget build(BuildContext context) {
    final bool active =
        state == BuyerAvatarState.speaking ||
        state == BuyerAvatarState.listening;
    final Color accent = switch (state) {
      BuyerAvatarState.success => AppColors.primary,
      BuyerAvatarState.retry => AppColors.amber,
      BuyerAvatarState.thinking => AppColors.purple,
      _ => AppColors.blue,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      width: active ? 126 : 116,
      height: active ? 126 : 116,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withAlpha(25),
        border: Border.all(
          color: accent.withAlpha(active ? 150 : 70),
          width: active ? 4 : 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withAlpha(active ? 55 : 25),
            blurRadius: active ? 28 : 15,
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFFFF1DC), Color(0xFFE9F7F0)],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(_avatarIcon(state), size: 62, color: AppColors.navy),
            Positioned(
              right: 3,
              bottom: 4,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(_stateIcon(state), size: 15, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuyerMessageCard extends StatelessWidget {
  final BuyerTurn turn;
  final VoidCallback onListen;

  const _BuyerMessageCard({required this.turn, required this.onListen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomRight: Radius.circular(22),
          bottomLeft: Radius.circular(5),
        ),
        border: Border.all(color: AppColors.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withAlpha(8),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'AI BUYER',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onListen,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.volume_up_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Text(
            turn.buyerMessage,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            turn.banglaMeaning,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final int score;
  final String bestReply;

  const _FeedbackCard({required this.score, required this.bestReply});

  @override
  Widget build(BuildContext context) {
    final bool passed = score >= 60;
    final Color color = passed ? AppColors.primary : AppColors.amber;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                passed
                    ? Icons.check_circle_rounded
                    : Icons.tips_and_updates_rounded,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  passed
                      ? 'Professional reply — $score%'
                      : 'Improve your reply — $score%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Recommended reply',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            bestReply,
            style: const TextStyle(
              color: AppColors.navy,
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

int _bestReplyScore(String actual, List<String> expectedReplies) {
  int best = 0;
  for (final String expected in expectedReplies) {
    best = max(best, _orderedSimilarity(actual, expected));
  }
  return best;
}

int _orderedSimilarity(String actual, String expected) {
  final List<String> a = _tokens(actual);
  final List<String> b = _tokens(expected);
  if (a.isEmpty || b.isEmpty) return 0;

  final int lcs = _lcsLength(a, b);
  final Set<String> aSet = a.toSet();
  final Set<String> bSet = b.toSet();
  final int shared = aSet.intersection(bSet).length;
  final double orderScore = lcs / max(a.length, b.length);
  final double coverageScore = shared / bSet.length;
  return ((orderScore * .65 + coverageScore * .35) * 100)
      .round()
      .clamp(0, 100)
      .toInt();
}

List<String> _tokens(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r"[^a-z0-9' ]"), ' ')
    .split(RegExp(r'\s+'))
    .where((String token) => token.isNotEmpty)
    .toList(growable: false);

int _lcsLength(List<String> a, List<String> b) {
  final List<List<int>> table = List<List<int>>.generate(
    a.length + 1,
    (_) => List<int>.filled(b.length + 1, 0),
  );
  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      table[i][j] = a[i - 1] == b[j - 1]
          ? table[i - 1][j - 1] + 1
          : max(table[i - 1][j], table[i][j - 1]);
    }
  }
  return table[a.length][b.length];
}

String _stateLabel(BuyerAvatarState state) => switch (state) {
  BuyerAvatarState.speaking => 'BUYER IS SPEAKING',
  BuyerAvatarState.listening => 'LISTENING TO YOU',
  BuyerAvatarState.thinking => 'CHECKING YOUR REPLY',
  BuyerAvatarState.success => 'GREAT RESPONSE',
  BuyerAvatarState.retry => 'LET’S IMPROVE IT',
  BuyerAvatarState.idle => 'EMMA • WEBSITE CLIENT',
};

IconData _avatarIcon(BuyerAvatarState state) => switch (state) {
  BuyerAvatarState.success => Icons.sentiment_very_satisfied_rounded,
  BuyerAvatarState.retry => Icons.sentiment_neutral_rounded,
  _ => Icons.support_agent_rounded,
};

IconData _stateIcon(BuyerAvatarState state) => switch (state) {
  BuyerAvatarState.speaking => Icons.graphic_eq_rounded,
  BuyerAvatarState.listening => Icons.hearing_rounded,
  BuyerAvatarState.thinking => Icons.psychology_rounded,
  BuyerAvatarState.success => Icons.check_rounded,
  BuyerAvatarState.retry => Icons.refresh_rounded,
  BuyerAvatarState.idle => Icons.circle,
};
