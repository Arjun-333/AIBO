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

  /// Starts speech recognition session with mock / native fallback
  Future<void> startListening({
    required Function(String text) onResult,
    required VoidCallback onStatusChanged,
  }) async {
    _isListening = true;
    onStatusChanged();
    SoundMotionService.instance.playTapSound();

    // In a real device environment with android.speech.SpeechRecognizer:
    // Listens for audio and streams partial results.
    // Here we provide high-quality simulated speech capture with realistic Japan queries:
    final List<String> samplePhrasesJp = [
      '近くの薬局はどこですか？ (Where is the nearest pharmacy?)',
      '渋谷駅のハチ公口に行きたいです。(I want to go to Shibuya Hachiko exit.)',
      '頭痛薬のイブプロフェンを探しています。(Looking for ibuprofen headache medicine.)',
      '明日のごみ収集は何ですか？ (What is tomorrow\'s garbage collection?)',
      '領収書をください。(Could I have a receipt please?)',
    ];

    final List<String> samplePhrasesEn = [
      'Where is the Shinagawa Immigration Bureau?',
      'How do I top up my Suica card at the station?',
      'What are the etiquette rules on the Yamanote line?',
      'Help me explain my symptoms to the pharmacist.',
    ];

    await Future.delayed(const Duration(milliseconds: 1400));
    if (_isListening) {
      final phrase = _currentLocale == 'ja-JP'
          ? (samplePhrasesJp..shuffle()).first
          : (samplePhrasesEn..shuffle()).first;
      onResult(phrase);
      SoundMotionService.instance.playSuccessHaptic();
      _isListening = false;
      onStatusChanged();
    }
  }

  void stopListening({required VoidCallback onStatusChanged}) {
    _isListening = false;
    onStatusChanged();
    SoundMotionService.instance.playTapSound();
  }
}
