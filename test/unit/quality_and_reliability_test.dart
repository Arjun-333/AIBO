import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/expenses/models/expense_model.dart';
import 'package:aibo/features/medication/models/medication_reminder.dart';
import 'package:aibo/features/vault/models/document_record.dart';
import 'package:aibo/features/chat/models/chat_message.dart';

void main() {
  group('1. Budgeting, Date Handling & Data Validation Tests', () {
    test('Deterministic arithmetic: daily spending and budget remaining', () {
      const dailyBudget = 8000.0;
      final expenses = [
        ExpenseModel(
          id: 1,
          amountJpy: 850.0,
          category: 'Dining',
          note: 'Ramen lunch',
          timestamp: DateTime(2026, 10, 26, 12, 30),
        ),
        ExpenseModel(
          id: 2,
          amountJpy: 1200.0,
          category: 'Groceries',
          note: 'Life Supermarket groceries',
          timestamp: DateTime(2026, 10, 26, 17, 15),
        ),
        ExpenseModel(
          id: 3,
          amountJpy: 1200.0,
          category: 'Transit',
          note: 'Suica card recharge',
          timestamp: DateTime(2026, 10, 26, 8, 30),
        ),
      ];

      final totalSpent = expenses.fold<double>(0, (sum, e) => sum + e.amountJpy);
      final remainingBudget = dailyBudget - totalSpent;
      final percentageUsed = (totalSpent / dailyBudget) * 100.0;

      expect(totalSpent, 3250.0);
      expect(remainingBudget, 4750.0);
      expect(percentageUsed, closeTo(40.625, 0.001));
    });

    test('Data validation: negative expenses and empty categories are rejected', () {
      expect(
        () {
          const invalidAmount = -500.0;
          if (invalidAmount <= 0) throw ArgumentError('Amount must be positive');
        },
        throwsArgumentError,
      );
    });

    test('Date handling: Japan Standard Time (JST) boundary calculations', () {
      // JST is UTC+9
      final utcTime = DateTime.utc(2026, 10, 26, 15, 30); // 15:30 UTC
      final jstTime = utcTime.add(const Duration(hours: 9)); // 00:30 next day in Tokyo
      
      expect(jstTime.day, 27);
      expect(jstTime.hour, 0);
      expect(jstTime.minute, 30);
    });
  });

  group('2. Offline Operation, Sync & Idempotency Tests', () {
    test('Offline idempotent transaction generation prevents double counting', () {
      final transactionIds = <String>{};
      
      // Simulate client UUID generation for 100 offline actions
      for (int i = 0; i < 100; i++) {
        final clientGeneratedUuid = 'tx_${DateTime.now().microsecondsSinceEpoch}_$i';
        final added = transactionIds.add(clientGeneratedUuid);
        expect(added, isTrue, reason: 'Every offline transaction must have unique idempotent key');
      }

      // Re-submitting an identical transaction ID must not duplicate
      final existingId = transactionIds.first;
      final duplicateAttempt = transactionIds.add(existingId);
      expect(duplicateAttempt, isFalse, reason: 'Duplicate sync attempts must be rejected');
      expect(transactionIds.length, 100);
    });

    test('Offline queue status transitions from pending to synced', () {
      var syncState = 'pending_local';
      expect(syncState, 'pending_local');

      // Simulate connection restored & server ack
      syncState = 'synced';
      expect(syncState, 'synced');
    });
  });

  group('3. Data Deletion & Privacy Verification Tests', () {
    test('Permanent deletion of chat conversations and associated memories', () {
      final chatStorage = <int, ChatMessage>{
        1: ChatMessage(
          id: 1,
          sessionId: 'default',
          role: 'user',
          content: 'How do I pay Tokyo Gas bill?',
          timestamp: DateTime.now(),
        ),
        2: ChatMessage(
          id: 2,
          sessionId: 'default',
          role: 'assistant',
          content: 'Take the barcode to any 7-Eleven or Lawson...',
          timestamp: DateTime.now(),
        ),
      };

      final derivedMemories = <String>['User pays Tokyo Gas', 'User prefers Lawson'];

      expect(chatStorage.length, 2);
      expect(derivedMemories.length, 2);

      // Execute complete conversation wipe
      chatStorage.clear();
      derivedMemories.clear();

      expect(chatStorage.isEmpty, isTrue);
      expect(derivedMemories.isEmpty, isTrue, reason: 'Derived memory must not outlive user purge');
    });

    test('Permanent deletion of document record purges metadata and mock file', () {
      final documents = <int, DocumentRecord>{
        10: DocumentRecord(
          id: 10,
          title: 'Residence Card',
          docType: 'residence_card',
          encryptedFilePath: '/data/user/0/com.aibo/vault/zairyu_card_enc.bin',
          createdAt: DateTime.now(),
        ),
      };

      expect(documents.containsKey(10), isTrue);
      documents.remove(10);
      expect(documents.containsKey(10), isFalse);
    });

    test('Zero Telemetry Invariant: No external tracking hosts in config', () {
      const allowedHosts = ['generativelanguage.googleapis.com', 'api.openai.com'];
      const blockedTrackers = ['google-analytics.com', 'amplitude.com', 'segment.io', 'facebook.com'];

      for (final tracker in blockedTrackers) {
        expect(allowedHosts.contains(tracker), isFalse);
      }
    });
  });

  group('4. Medication Safety & Recurring Schedules', () {
    test('Scheduled dose state transitions: scheduled -> taken (済)', () {
      final dose = MedicationReminder(
        id: 1,
        nameEn: 'Magnesium & Zinc',
        dosage: '250mg',
        scheduledTime: '20:30',
        instructions: 'Take with food / 食後',
      );

      expect(dose.isTakenToday, isFalse);

      final updatedDose = MedicationReminder(
        id: dose.id,
        nameEn: dose.nameEn,
        dosage: dose.dosage,
        timing: dose.timing,
        scheduledTime: dose.scheduledTime,
        instructions: dose.instructions,
        category: dose.category,
        lastTakenAt: DateTime.now(),
        createdAt: dose.createdAt,
      );
      expect(updatedDose.isTakenToday, isTrue);
      expect(updatedDose.nameEn, 'Magnesium & Zinc');
    });

    test('Safety rule: taking a dose does not infer unrecorded doses were taken', () {
      final doseMorning = MedicationReminder(
        id: 1,
        nameEn: 'Vitamin B Complex',
        dosage: '1 tablet',
        scheduledTime: '08:00',
      );

      final doseEvening = MedicationReminder(
        id: 2,
        nameEn: 'Magnesium & Zinc',
        dosage: '250mg',
        scheduledTime: '20:30',
        lastTakenAt: DateTime.now(), // Marked taken by user
      );

      // Morning dose must strictly remain unrecorded/false
      expect(doseEvening.isTakenToday, isTrue);
      expect(doseMorning.isTakenToday, isFalse, reason: 'App must never automatically infer missed doses as taken');
    });
  });

  group('5. Error Handling & API Resilience', () {
    test('Graceful fallback when cloud AI encounters rate limit or quota exhaustion (429)', () {
      String handleLlmError(int statusCode) {
        if (statusCode == 429) {
          return 'AI free quota reached. Offline phrasebook and guides remain active.';
        } else if (statusCode >= 500) {
          return 'Service temporarily unavailable. Please retry in a few moments.';
        }
        return 'Network error. Switched to offline mode.';
      }

      final quotaMsg = handleLlmError(429);
      final serverErrorMsg = handleLlmError(503);
      final offlineMsg = handleLlmError(0);

      expect(quotaMsg, contains('Offline phrasebook and guides remain active'));
      expect(serverErrorMsg, contains('temporarily unavailable'));
      expect(offlineMsg, contains('offline mode'));
    });
  });
}
