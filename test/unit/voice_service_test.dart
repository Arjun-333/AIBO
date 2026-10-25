import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/core/voice/voice_service.dart';

void main() {
  group('VoiceService & Bilingual STT Tests', () {
    final voiceService = VoiceService.instance;

    test('Locale switching between Japanese and English', () {
      voiceService.setLocale('en-US');
      expect(voiceService.currentLocale, 'en-US');

      voiceService.setLocale('ja-JP');
      expect(voiceService.currentLocale, 'ja-JP');
    });

    test('Voice recognition session captures spoken queries accurately', () async {
      String capturedResult = '';
      bool statusNotified = false;

      await voiceService.startListening(
        onResult: (text) {
          capturedResult = text;
        },
        onStatusChanged: () {
          statusNotified = true;
        },
      );

      expect(statusNotified, true);
      expect(capturedResult.isNotEmpty, true);
      expect(voiceService.isListening, false);
    });

    test('Explicit stopListening terminates session cleanly', () {
      bool statusNotified = false;
      voiceService.stopListening(onStatusChanged: () {
        statusNotified = true;
      });

      expect(statusNotified, true);
      expect(voiceService.isListening, false);
    });
  });
}
