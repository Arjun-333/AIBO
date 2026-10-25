class TaskModel {
  final int? id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  final String category; // 'garbage', 'admin', 'daily', 'bills', 'work'
  final bool isCompleted;
  final DateTime createdAt;

  TaskModel({
    this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = 'medium',
    this.category = 'daily',
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority,
      'category': category,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: map['due_date'] != null ? DateTime.tryParse(map['due_date'] as String) : null,
      priority: map['priority'] as String? ?? 'medium',
      category: map['category'] as String? ?? 'daily',
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
