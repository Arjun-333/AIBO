import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/core/voice/voice_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('VoiceService & Bilingual STT Tests', () {
    final voiceService = VoiceService.instance;

    test('Locale switching between Japanese and English', () {
      voiceService.setLocale('en-US');
      expect(voiceService.currentLocale, 'en-US');

      voiceService.setLocale('ja-JP');
      expect(voiceService.currentLocale, 'ja-JP');
    });

    test('Unsupported voice environments do not fabricate a transcript', () async {
      String capturedResult = '';
      bool statusNotified = false;
      String unavailableMessage = '';

      final started = await voiceService.startListening(
        onResult: (text) {
          capturedResult = text;
        },
        onStatusChanged: () {
          statusNotified = true;
        },
        onUnavailable: (message) {
          unavailableMessage = message;
        },
      );

      expect(started, false);
      expect(statusNotified, true);
      expect(capturedResult, isEmpty);
      expect(unavailableMessage.isNotEmpty, true);
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
