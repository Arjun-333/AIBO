import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/sound_motion_service.dart';

class VoiceService {
  static final VoiceService instance = VoiceService._init();
  VoiceService._init();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _currentLocale = 'ja-JP'; // bilingual: 'ja-JP' or 'en-US'

  bool get isListening => _isListening;
  String get currentLocale => _currentLocale;

  void setLocale(String localeCode) {
    _currentLocale = localeCode;
  }

  /// Initializes the Android SpeechRecognizer and requests microphone permission.
  ///
  /// Returns [true] if the device is ready to accept voice input.
  Future<bool> _ensureInitialized({
    Function(String message)? onUnavailable,
  }) async {
    // 1. Request microphone permission at runtime
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      onUnavailable?.call('Microphone permission was denied. Please allow it in Settings → App Permissions → AIBO.');
      return false;
    }

    // 2. Initialize speech_to_text (which wraps Android SpeechRecognizer)
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (SpeechRecognitionError e) {
          debugPrint('[VoiceService] SpeechRecognizer error: ${e.errorMsg}');
          _isListening = false;
        },
        debugLogging: kDebugMode,
      );
    }

    if (!_isInitialized) {
      onUnavailable?.call('Speech recognition is not supported on this device.');
      return false;
    }
    return true;
  }

  /// Starts bilingual speech recognition (Japanese or English based on [currentLocale]).
  ///
  /// - [onResult]         called each time partial or final transcript is ready.
  /// - [onStatusChanged]  called when listening state toggles.
  /// - [onUnavailable]    called if permission is denied or device lacks STT.
  Future<bool> startListening({
    required Function(String text) onResult,
    required VoidCallback onStatusChanged,
    Function(String message)? onUnavailable,
  }) async {
    final ready = await _ensureInitialized(onUnavailable: onUnavailable);
    if (!ready) return false;

    // Don't start a second session if already listening
    if (_isListening) {
      stopListening(onStatusChanged: onStatusChanged);
      return false;
    }

    _isListening = true;
    onStatusChanged();
    SoundMotionService.instance.playTapSound();

    await _speech.listen(
      onResult: (result) {
        // Fire on every interim word so the UI feels responsive
        onResult(result.recognizedWords);
        if (result.finalResult) {
          _isListening = false;
          onStatusChanged();
        }
      },
      localeId: _currentLocale,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation,
    );

    return true;
  }

  /// Stops an active listening session.
  void stopListening({required VoidCallback onStatusChanged}) {
    _speech.stop();
    _isListening = false;
    onStatusChanged();
    SoundMotionService.instance.playTapSound();
  }

  /// Returns available locales so the UI can offer a locale switcher.
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await _ensureInitialized();
    }
    return _speech.locales();
  }
}

