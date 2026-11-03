import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/sound_motion_service.dart';

class VoiceService {
  static final VoiceService instance = VoiceService._init();
  VoiceService._init();

  bool _isListening = false;
  String _currentLocale = 'ja-JP'; // or 'en-US'

  bool get isListening => _isListening;
  String get currentLocale => _currentLocale;

  void setLocale(String localeCode) {
    _currentLocale = localeCode;
  }

  /// Starts speech recognition when a platform adapter is installed.
  ///
  /// The current checkout intentionally does not fabricate a transcript in
  /// headless or unsupported environments.
  Future<bool> startListening({
    required Function(String text) onResult,
    required VoidCallback onStatusChanged,
    Function(String message)? onUnavailable,
  }) async {
    _isListening = true;
    onStatusChanged();
    SoundMotionService.instance.playTapSound();

    _isListening = false;
    onStatusChanged();
    const message = 'Voice input needs the Android SpeechRecognizer adapter and microphone permission.';
    onUnavailable?.call(message);
    debugPrint(message);
    return false;
  }

  void stopListening({required VoidCallback onStatusChanged}) {
    _isListening = false;
    onStatusChanged();
    SoundMotionService.instance.playTapSound();
  }
}
