import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/medication/models/medication_reminder.dart';
import 'package:aibo/features/medication/services/medication_service.dart';

void main() {
  group('Medication & Tablet Reminder Tests', () {
    test('MedicationReminder correctly evaluates isTakenToday flag', () {
      final now = DateTime.now();

      final takenToday = MedicationReminder(
        id: 1,
        nameEn: 'Loxonin S',
        nameJa: 'ロキソニンS',
        dosage: '1 tablet',
        lastTakenAt: now,
      );

      final notTaken = MedicationReminder(
        id: 2,
        nameEn: 'Vitamin D',
        dosage: '1 tablet',
        lastTakenAt: null,
      );

      final takenYesterday = MedicationReminder(
        id: 3,
        nameEn: 'Allergy Tablet',
        dosage: '1 tablet',
        lastTakenAt: now.subtract(const Duration(days: 1)),
      );

      expect(takenToday.isTakenToday, true);
      expect(notTaken.isTakenToday, false);
      expect(takenYesterday.isTakenToday, false);
    });

    test('MedicationReminder model serialization and deserialization', () {
      final med = MedicationReminder(
        id: 10,
        nameEn: 'EVE Quick (Ibuprofen)',
        nameJa: 'イブクイック',
        dosage: '2 tablets',
        timing: 'Evening (晩)',
        scheduledTime: '20:30',
        instructions: 'After dinner with water',
        category: 'pain',
      );

      final map = med.toMap();
      expect(map['id'], 10);
      expect(map['name_en'], 'EVE Quick (Ibuprofen)');
      expect(map['scheduled_time'], '20:30');
      expect(map['dosage'], '2 tablets');

      final fromMap = MedicationReminder.fromMap(map);
      expect(fromMap.id, 10);
      expect(fromMap.nameJa, 'イブクイック');
      expect(fromMap.timing, 'Evening (晩)');
    });

    test('Japanese OTC directory covers essential foreign medicines and translations', () {
      final service = MedicationService.instance;
      final meds = service.getJapaneseMedicineDirectory();

      expect(meds.isNotEmpty, true);

      // Verify Tylenol / Acetaminophen
      final paracetamol = meds.firstWhere((m) => m.commonNameEn.contains('Paracetamol'));
      expect(paracetamol.japaneseBrand.contains('Tylenol A'), true);

      // Verify EVE / Ibuprofen
      final ibuprofen = meds.firstWhere((m) => m.commonNameEn.contains('Ibuprofen'));
      expect(ibuprofen.japaneseBrand.contains('EVE'), true);

      // Verify Loxonin S (Type 1 OTC)
      final loxonin = meds.firstWhere((m) => m.japaneseBrand.contains('Loxonin S'));
      expect(loxonin.otcClassification.contains('Type 1'), true);
      expect(loxonin.pharmacistPromptJp.contains('ロキソニンS'), true);

      // Verify Allergy / Allegra FX
      final allergy = meds.firstWhere((m) => m.japaneseBrand.contains('Allegra'));
      expect(allergy.japaneseBrand.contains('Allegra FX'), true);
    });

    test('Japanese Drugstore chain directory contains map search terms', () {
      final service = MedicationService.instance;
      final chains = service.getJapaneseDrugstoreChains();

      expect(chains.length >= 4, true);
      expect(chains.any((c) => c.nameEn.contains('Matsumoto Kiyoshi')), true);
      expect(chains.any((c) => c.nameEn.contains('Welcia')), true);
      expect(chains.every((c) => c.mapSearchTerm.isNotEmpty), true);
    });
  });
}
