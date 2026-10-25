import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/language/data/phrase_data.dart';

void main() {
  group('PhraseData Japanese Dictionary Tests', () {
    test('Contains curated phrases across all 6 essential life domains', () {
      final categories = PhraseData.phrases.map((p) => p.category).toSet();
      expect(categories.contains('Transit'), isTrue);
      expect(categories.contains('Konbini'), isTrue);
      expect(categories.contains('Ward Office'), isTrue);
      expect(categories.contains('Dining'), isTrue);
      expect(categories.contains('Medical'), isTrue);
      expect(categories.contains('Garbage'), isTrue);
    });

    test('Every phrase has valid Japanese, furigana, romaji, and English fields', () {
      for (final p in PhraseData.phrases) {
        expect(p.japanese.trim().isNotEmpty, isTrue, reason: 'Japanese text is empty');
        expect(p.furigana.trim().isNotEmpty, isTrue, reason: 'Furigana is empty for ${p.japanese}');
        expect(p.romaji.trim().isNotEmpty, isTrue, reason: 'Romaji is empty for ${p.japanese}');
        expect(p.english.trim().isNotEmpty, isTrue, reason: 'English is empty for ${p.japanese}');
      }
    });
  });
}
