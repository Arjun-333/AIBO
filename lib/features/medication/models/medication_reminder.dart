class MedicationReminder {
  final int? id;
  final String nameEn;
  final String nameJa;
  final String dosage; // e.g. "1 tablet", "2 pills"
  final String timing; // e.g. "Morning (朝)", "Afternoon (昼)", "Evening (晩)", "Bedtime (就寝前)"
  final String scheduledTime; // e.g. "08:00", "20:00"
  final String instructions; // e.g. "After meals (食後)", "Before meals (食前)", "With water (水で服用)"
  final String category; // 'pain', 'allergy', 'stomach', 'vitamin', 'prescription', 'other'
  final bool isActive;
  final DateTime? lastTakenAt;
  final DateTime createdAt;

  MedicationReminder({
    this.id,
    required this.nameEn,
    this.nameJa = '',
    this.dosage = '1 tablet',
    this.timing = 'Morning (朝)',
    this.scheduledTime = '08:00',
    this.instructions = 'After meals (食後)',
    this.category = 'prescription',
    this.isActive = true,
    this.lastTakenAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isTakenToday {
    if (lastTakenAt == null) return false;
    final now = DateTime.now();
    return lastTakenAt!.year == now.year &&
        lastTakenAt!.month == now.month &&
        lastTakenAt!.day == now.day;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ja': nameJa,
      'dosage': dosage,
      'timing': timing,
      'scheduled_time': scheduledTime,
      'instructions': instructions,
      'category': category,
      'is_active': isActive ? 1 : 0,
      'last_taken_at': lastTakenAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory MedicationReminder.fromMap(Map<String, dynamic> map) {
    return MedicationReminder(
      id: map['id'] as int?,
      nameEn: map['name_en'] as String? ?? '',
      nameJa: map['name_ja'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '1 tablet',
      timing: map['timing'] as String? ?? 'Morning (朝)',
      scheduledTime: map['scheduled_time'] as String? ?? '08:00',
      instructions: map['instructions'] as String? ?? 'After meals (食後)',
      category: map['category'] as String? ?? 'prescription',
      isActive: (map['is_active'] as int? ?? 1) == 1,
      lastTakenAt: map['last_taken_at'] != null ? DateTime.tryParse(map['last_taken_at'] as String) : null,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
