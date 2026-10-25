class DocumentRecord {
  final int? id;
  final String title;
  final String docType; // 'residence_card', 'passport', 'my_number', 'insurance', 'lease', 'other'
  final String encryptedFilePath;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentRecord({
    this.id,
    required this.title,
    required this.docType,
    required this.encryptedFilePath,
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'doc_type': docType,
      'encrypted_file_path': encryptedFilePath,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory DocumentRecord.fromMap(Map<String, dynamic> map) {
    return DocumentRecord(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      docType: map['doc_type'] as String? ?? 'other',
      encryptedFilePath: map['encrypted_file_path'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
