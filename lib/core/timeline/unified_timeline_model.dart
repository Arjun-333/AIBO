enum LifeEventCategory {
  billDue,
  documentRenewal,
  medicationDose,
  trashCollection,
  scheduledTask,
  wardProcedure,
}

class LifeTimelineEvent {
  final String id;
  final LifeEventCategory category;
  final String title;
  final String subtitle;
  final DateTime eventTime;
  final bool isCompleted;
  final bool isUrgent;
  final String actionType; // 'view_doc', 'mark_taken', 'mark_paid', 'view_ward', 'complete_task'
  final dynamic referenceId; // Document ID, task ID, or med ID

  const LifeTimelineEvent({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.eventTime,
    this.isCompleted = false,
    this.isUrgent = false,
    this.actionType = 'general',
    this.referenceId,
  });

  String get categoryIconEmoji {
    switch (category) {
      case LifeEventCategory.billDue:
        return '💴';
      case LifeEventCategory.documentRenewal:
        return '🛂';
      case LifeEventCategory.medicationDose:
        return '💊';
      case LifeEventCategory.trashCollection:
        return '🗑️';
      case LifeEventCategory.scheduledTask:
        return '✅';
      case LifeEventCategory.wardProcedure:
        return '🏛️';
    }
  }

  String get categoryLabel {
    switch (category) {
      case LifeEventCategory.billDue:
        return 'Bill Payment (支払期日)';
      case LifeEventCategory.documentRenewal:
        return 'Document Expiry (更新期限)';
      case LifeEventCategory.medicationDose:
        return 'Tablet Reminder (服用)';
      case LifeEventCategory.trashCollection:
        return 'Garbage Day (ごみ収集)';
      case LifeEventCategory.scheduledTask:
        return 'To-Do / Focus (タスク)';
      case LifeEventCategory.wardProcedure:
        return 'Ward Office (区役所手続き)';
    }
  }
}
