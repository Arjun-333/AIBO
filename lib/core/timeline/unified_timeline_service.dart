import 'package:flutter/foundation.dart';
import '../context/personal_context_service.dart';
import '../database/database_helper.dart';
import '../ocr/structured_document_model.dart';
import 'unified_timeline_model.dart';

/// UnifiedTimelineService — Fulfills the "Life OS" vision by synthesizing
/// all life data (bills, medications, tasks, garbage, renewals) into a single
/// chronological timeline and emitting proactive, non-hallucinated alerts.
class UnifiedTimelineService {
  static final UnifiedTimelineService instance = UnifiedTimelineService._init();
  UnifiedTimelineService._init();

  /// Compiles a unified chronological life timeline for the next 14 days
  Future<List<LifeTimelineEvent>> getUnifiedTimeline() async {
    final events = <LifeTimelineEvent>[];
    final now = DateTime.now();

    // 1. Fetch Structured Documents (Bills & Expirations)
    try {
      final docs = await DatabaseHelper.instance.getStructuredDocuments();
      for (final doc in docs) {
        if (doc.dueOrExpiryDate != null) {
          final isBill = doc.docType == JapaneseDocumentType.utilityElectricity ||
              doc.docType == JapaneseDocumentType.utilityGas ||
              doc.docType == JapaneseDocumentType.utilityWater ||
              doc.docType == JapaneseDocumentType.taxSlip ||
              doc.docType == JapaneseDocumentType.nationalPension;

          final daysLeft = doc.dueOrExpiryDate!.difference(now).inDays;
          final isUrgent = daysLeft >= 0 && daysLeft <= 3;

          events.add(LifeTimelineEvent(
            id: 'doc_${doc.id}',
            category: isBill ? LifeEventCategory.billDue : LifeEventCategory.documentRenewal,
            title: doc.amountJpy != null
                ? '${doc.title} — ¥${doc.amountJpy!.toInt()}'
                : doc.title,
            subtitle: '${doc.issuerOrProvider} • ${doc.keyInstructionsEn}',
            eventTime: doc.dueOrExpiryDate!,
            isCompleted: doc.paymentStatus == 'paid',
            isUrgent: isUrgent,
            actionType: isBill ? 'mark_paid' : 'view_doc',
            referenceId: doc.id,
          ));
        }
      }
    } catch (e) {
      debugPrint('[UnifiedTimelineService] Documents query error: $e');
    }

    // 2. Fetch Daily Medication Reminders (Today's doses)
    try {
      final meds = await DatabaseHelper.instance.getMedications();
      for (final med in meds) {
        if (med.isActive) {
          final parts = med.scheduledTime.split(':');
          final hour = int.tryParse(parts[0]) ?? 8;
          final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
          final doseTime = DateTime(now.year, now.month, now.day, hour, minute);

          events.add(LifeTimelineEvent(
            id: 'med_${med.id}',
            category: LifeEventCategory.medicationDose,
            title: '${med.nameEn} (${med.scheduledTime})',
            subtitle: '${med.dosage} • ${med.instructions}',
            eventTime: doseTime,
            isCompleted: med.isTakenToday,
            isUrgent: !med.isTakenToday && now.isAfter(doseTime),
            actionType: 'mark_taken',
            referenceId: med.id,
          ));
        }
      }
    } catch (e) {
      debugPrint('[UnifiedTimelineService] Medications query error: $e');
    }

    // 3. Fetch Tasks & Planner Reminders
    try {
      final tasks = await DatabaseHelper.instance.getTasks();
      for (final task in tasks) {
        if (task.dueDate != null) {
          final isUrgent = !task.isCompleted && task.dueDate!.difference(now).inHours < 24;
          events.add(LifeTimelineEvent(
            id: 'task_${task.id}',
            category: LifeEventCategory.scheduledTask,
            title: task.title,
            subtitle: task.category,
            eventTime: task.dueDate!,
            isCompleted: task.isCompleted,
            isUrgent: isUrgent,
            actionType: 'complete_task',
            referenceId: task.id,
          ));
        }
      }
    } catch (e) {
      debugPrint('[UnifiedTimelineService] Tasks query error: $e');
    }

    // 4. Synthesize Garbage Collection Days for the current week
    try {
      final context = await PersonalContextService.instance.getContext();
      _injectGarbageScheduleEvents(events, context, now);
    } catch (e) {
      debugPrint('[UnifiedTimelineService] Garbage schedule error: $e');
    }

    // 5. Inject Visa Expiration Alert if within 90-day renewal window
    try {
      final context = await PersonalContextService.instance.getContext();
      if (context.residenceExpiryDate != null) {
        final daysLeft = context.daysUntilVisaExpiry;
        if (daysLeft != null && daysLeft <= 90) {
          events.add(LifeTimelineEvent(
            id: 'visa_renewal_alert',
            category: LifeEventCategory.documentRenewal,
            title: 'Residence Card Expiry in $daysLeft Days (在留期間満了)',
            subtitle: 'Immigration Bureau allows renewals starting 3 months before expiry. Prepare tax slips and employer certificate.',
            eventTime: context.residenceExpiryDate!,
            isUrgent: daysLeft <= 30,
            actionType: 'view_ward',
          ));
        }
      }
    } catch (_) {}

    // Sort all events chronologically
    events.sort((a, b) => a.eventTime.compareTo(b.eventTime));
    return events;
  }

  /// Extracts proactive urgent alerts for the top of the dashboard
  Future<List<LifeTimelineEvent>> getProactiveAlerts() async {
    final all = await getUnifiedTimeline();
    return all.where((e) => e.isUrgent && !e.isCompleted).toList();
  }

  // ---------------------------------------------------------------------------
  // Garbage Schedule Evaluation
  // ---------------------------------------------------------------------------

  void _injectGarbageScheduleEvents(
    List<LifeTimelineEvent> events,
    dynamic context,
    DateTime now,
  ) {
    // Generate events for the next 7 days
    for (int i = 0; i < 7; i++) {
      final day = now.add(Duration(days: i));
      final morningTime = DateTime(day.year, day.month, day.day, 8, 0);

      // Tuesday & Friday: Burnable
      if (day.weekday == DateTime.tuesday || day.weekday == DateTime.friday) {
        events.add(LifeTimelineEvent(
          id: 'trash_burnable_${day.year}_${day.month}_${day.day}',
          category: LifeEventCategory.trashCollection,
          title: 'Burnable Garbage (燃えるごみ)',
          subtitle: 'Dispose in semi-transparent bags at neighborhood station by 08:00 AM.',
          eventTime: morningTime,
          isUrgent: i == 0 || (i == 1 && now.hour >= 18), // Urgent if today or tonight for tomorrow
        ));
      }

      // Wednesday: Recyclable Plastics
      if (day.weekday == DateTime.wednesday) {
        events.add(LifeTimelineEvent(
          id: 'trash_plastic_${day.year}_${day.month}_${day.day}',
          category: LifeEventCategory.trashCollection,
          title: 'Plastics & PET Bottles (資源・プラ)',
          subtitle: 'Rinse bottles, remove caps & labels. Dispose before 08:00 AM.',
          eventTime: morningTime,
          isUrgent: i == 0 || (i == 1 && now.hour >= 18),
        ));
      }
    }
  }
}
