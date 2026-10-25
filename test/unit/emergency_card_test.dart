import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/emergency/models/emergency_card.dart';

void main() {
  group('EmergencyCard Model Tests', () {
    test('Serializes to map and deserializes correctly', () {
      final card = EmergencyCard(
        id: 1,
        fullName: 'Taro Yamada',
        bloodType: 'AB+',
        emergencyContactName: 'Hanako Yamada',
        emergencyContactPhone: '+81-90-1234-5678',
        allergies: 'Penicillin',
        medicalNotes: 'Asthmatic',
        residenceCardNumber: 'AB12345678CD',
        insuranceNumber: '12345678',
      );

      final map = card.toMap();
      expect(map['full_name'], 'Taro Yamada');
      expect(map['blood_type'], 'AB+');
      expect(map['emergency_contact_phone'], '+81-90-1234-5678');
      expect(map['allergies'], 'Penicillin');

      final reconstructed = EmergencyCard.fromMap(map);
      expect(reconstructed.id, 1);
      expect(reconstructed.fullName, 'Taro Yamada');
      expect(reconstructed.bloodType, 'AB+');
      expect(reconstructed.emergencyContactName, 'Hanako Yamada');
      expect(reconstructed.emergencyContactPhone, '+81-90-1234-5678');
      expect(reconstructed.allergies, 'Penicillin');
      expect(reconstructed.medicalNotes, 'Asthmatic');
    });

    test('copyWith updates specific fields accurately', () {
      final original = EmergencyCard(
        fullName: 'Initial Name',
        bloodType: 'O+',
        emergencyContactName: 'Contact',
        emergencyContactPhone: '090-0000-0000',
      );

      final updated = original.copyWith(bloodType: 'A-', allergies: 'Peanuts');
      expect(updated.fullName, 'Initial Name');
      expect(updated.bloodType, 'A-');
      expect(updated.allergies, 'Peanuts');
      expect(updated.emergencyContactPhone, '090-0000-0000');
    });
  });
}
