class ExpenseModel {
  final int? id;
  final double amountJpy;
  final String category; // 'groceries', 'utilities', 'rent', 'dining', 'transit', 'misc'
  final String note;
  final DateTime timestamp;

  ExpenseModel({
    this.id,
    required this.amountJpy,
    required this.category,
    this.note = '',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount_jpy': amountJpy,
      'category': category,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      amountJpy: (map['amount_jpy'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? 'misc',
      note: map['note'] as String? ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
