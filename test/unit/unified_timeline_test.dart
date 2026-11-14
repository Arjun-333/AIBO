import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/core/timeline/unified_timeline_model.dart';

void main() {
  group('Unified Timeline Model Tests', () {
    test('Timeline event priority, categories, and icon emojis', () {
      final now = DateTime.now();
      final billEvent = LifeTimelineEvent(
        id: 'test_bill_1',
        category: LifeEventCategory.billDue,
        title: 'Electricity Bill (¥4,500)',
        subtitle: 'TEPCO • Pay at 7-Eleven',
        eventTime: now.add(const Duration(days: 1)),
        isUrgent: true,
      );

      expect(billEvent.categoryIconEmoji, '💴');
      expect(billEvent.categoryLabel.contains('Bill Payment'), isTrue);
      expect(billEvent.isUrgent, isTrue);

      final medEvent = LifeTimelineEvent(
        id: 'test_med_1',
        category: LifeEventCategory.medicationDose,
        title: 'Loxonin S (20:30)',
        subtitle: '1 tablet with water',
        eventTime: now,
        isCompleted: true,
      );

      expect(medEvent.categoryIconEmoji, '💊');
      expect(medEvent.isCompleted, isTrue);

      final trashEvent = LifeTimelineEvent(
        id: 'test_trash_1',
        category: LifeEventCategory.trashCollection,
        title: 'Burnable Garbage',
        subtitle: 'Before 8am',
        eventTime: now.add(const Duration(days: 2)),
      );

      expect(trashEvent.categoryIconEmoji, '🗑️');
    });
  });
}
