import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/core/context/personal_context_model.dart';
import 'package:aibo/core/context/personal_context_service.dart';

void main() {
  group('PersonalContext & Context Engine Tests', () {
    test('PersonalContext model serialization and visa expiry calculation', () {
      final now = DateTime.now();
      final expiry = now.add(const Duration(days: 45));

      final context = PersonalContext(
        fullName: 'Arjun Tester',
        homeWard: 'Shinjuku-ku (新宿区)',
        nearestStation: 'Shin-Okubo Station (新大久保駅)',
        commuteRoute: 'JR Yamanote Line',
        jlptLevel: 'N3 (Intermediate)',
        residenceStatus: 'Engineer / Specialist in Humanities',
        residenceExpiryDate: expiry,
      );

      expect(context.daysUntilVisaExpiry, inInclusiveRange(44, 46));
      expect(context.isVisaRenewalWindowOpen, isTrue);

      final map = context.toMap();
      final restored = PersonalContext.fromMap(map);

      expect(restored.fullName, 'Arjun Tester');
      expect(restored.homeWard, 'Shinjuku-ku (新宿区)');
      expect(restored.nearestStation, 'Shin-Okubo Station (新大久保駅)');
      expect(restored.jlptLevel, 'N3 (Intermediate)');
      expect(restored.isVisaRenewalWindowOpen, isTrue);
    });

    test('toSanitizedLlmContext does not leak raw private credentials or full address', () {
      final context = const PersonalContext(
        fullName: 'Private User Name',
        homeAddressJa: '東京都新宿区大久保1-2-3 ハイツ402',
        homeWard: 'Shinjuku-ku (新宿区)',
        nearestStation: 'Shin-Okubo Station',
      );

      final sanitized = context.toSanitizedLlmContext();

      // Must include area and ward
      expect(sanitized.contains('Shinjuku-ku (新宿区)'), isTrue);
      expect(sanitized.contains('Shin-Okubo Station'), isTrue);

      // Must NOT include detailed building or apartment number
      expect(sanitized.contains('大久保1-2-3'), isFalse);
      expect(sanitized.contains('ハイツ402'), isFalse);
    });

    test('Ward office directory returns verified official details for Tokyo wards', () {
      final shinjuku = PersonalContextService.getWardOfficeDetails('Shinjuku-ku (新宿区)');
      expect(shinjuku.contains('Kabukicho'), isTrue);
      expect(shinjuku.contains('East Exit'), isTrue);

      final shibuya = PersonalContextService.getWardOfficeDetails('Shibuya-ku (渋谷区)');
      expect(shibuya.contains('Udagawacho'), isTrue);
      expect(shibuya.contains('Hachiko Exit'), isTrue);
    });
  });
}
