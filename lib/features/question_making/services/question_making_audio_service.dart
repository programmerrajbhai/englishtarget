import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract final class QuestionMakingAudioService {
  static final FlutterTts _tts = FlutterTts();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);

    _initialized = true;
  }

  static Future<void> speak(String text) async {
    if (text.trim().isEmpty) {
      return;
    }

    try {
      await initialize();
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  static Future<void> correctFeedback() async {
    await SystemSound.play(
      SystemSoundType.click,
    );

    await speak(
      'Correct. Perfect!',
    );
  }

  static Future<void> wrongFeedback() async {
    await SystemSound.play(
      SystemSoundType.alert,
    );

    await speak(
      'Not correct. Try again.',
    );
  }

  static Future<void> feedback({
    required bool correct,
  }) async {
    if (correct) {
      await correctFeedback();
    } else {
      await wrongFeedback();
    }
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}