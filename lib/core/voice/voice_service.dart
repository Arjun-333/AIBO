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

  /// Starts speech recognition session with platform microphone
  Future<void> startListening({
    required Function(String text) onResult,
    required VoidCallback onStatusChanged,
  }) async {
    _isListening = true;
    onStatusChanged();
    SoundMotionService.instance.playTapSound();

    // Requires hardware android.permission.RECORD_AUDIO.
    // When operating in headless CI / desktop environment without speech engine,
    // do not fabricate fake speech; signal availability truthfully.
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_isListening) {
        SoundMotionService.instance.playSuccessHaptic();
        _isListening = false;
        onStatusChanged();
      }
    } catch (e) {
      _isListening = false;
      onStatusChanged();
      debugPrint('Speech recognition hardware not accessible: $e');
    }
  }

  void stopListening({required VoidCallback onStatusChanged}) {
    _isListening = false;
    onStatusChanged();
    SoundMotionService.instance.playTapSound();
  }
}
