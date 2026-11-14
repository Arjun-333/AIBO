enum JapaneseDocumentType {
  residenceCard,
  utilityElectricity,
  utilityGas,
  utilityWater,
  taxSlip,
  nationalPension,
  healthInsurance,
  receipt,
  generalNotice,
}

class StructuredDocument {
  final int? id;
  final int? vaultDocId;
  final JapaneseDocumentType docType;
  final String title;
  final String issuerOrProvider;
  final double? amountJpy;
  final DateTime? dueOrExpiryDate;
  final String? documentIdentifier; // Card number, customer number, account ID
  final bool isPayableAtKonbini;
  final String paymentStatus; // 'pending', 'paid', 'auto_debit', 'not_applicable'
  final String keyInstructionsJa;
  final String keyInstructionsEn;
  final String rawExtractedText;
  final bool isVerifiedByUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StructuredDocument({
    this.id,
    this.vaultDocId,
    required this.docType,
    required this.title,
    required this.issuerOrProvider,
    this.amountJpy,
    this.dueOrExpiryDate,
    this.documentIdentifier,
    this.isPayableAtKonbini = false,
    this.paymentStatus = 'not_applicable',
    this.keyInstructionsJa = '',
    this.keyInstructionsEn = '',
    required this.rawExtractedText,
    this.isVerifiedByUser = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get typeLabel {
    switch (docType) {
      case JapaneseDocumentType.residenceCard:
        return 'Residence Card (在留カード)';
      case JapaneseDocumentType.utilityElectricity:
        return 'Electricity Bill (電気料金請求書)';
      case JapaneseDocumentType.utilityGas:
        return 'Gas Bill (ガス料金請求書)';
      case JapaneseDocumentType.utilityWater:
        return 'Water Bill (水道料金請求書)';
      case JapaneseDocumentType.taxSlip:
        return 'Resident Tax Notice (住民税・納付書)';
      case JapaneseDocumentType.nationalPension:
        return 'National Pension (国民年金保険料)';
      case JapaneseDocumentType.healthInsurance:
        return 'Health Insurance Card (健康保険証)';
      case JapaneseDocumentType.receipt:
        return 'Konbini / Store Receipt (領収書・レシート)';
      case JapaneseDocumentType.generalNotice:
        return 'Municipal / Ward Notice (役所からのお知らせ)';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vault_doc_id': vaultDocId,
      'doc_type': docType.name,
      'title': title,
      'issuer_or_provider': issuerOrProvider,
      'amount_jpy': amountJpy,
      'due_or_expiry_date': dueOrExpiryDate?.toIso8601String(),
      'document_identifier': documentIdentifier,
      'is_payable_at_konbini': isPayableAtKonbini ? 1 : 0,
      'payment_status': paymentStatus,
      'key_instructions_ja': keyInstructionsJa,
      'key_instructions_en': keyInstructionsEn,
      'raw_extracted_text': rawExtractedText,
      'is_verified_by_user': isVerifiedByUser ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory StructuredDocument.fromMap(Map<String, dynamic> map) {
    JapaneseDocumentType parseType(String? val) {
      for (final t in JapaneseDocumentType.values) {
        if (t.name == val) return t;
      }
      return JapaneseDocumentType.generalNotice;
    }

    return StructuredDocument(
      id: map['id'] as int?,
      vaultDocId: map['vault_doc_id'] as int?,
      docType: parseType(map['doc_type'] as String?),
      title: map['title'] as String? ?? 'Untitled Document',
      issuerOrProvider: map['issuer_or_provider'] as String? ?? '',
      amountJpy: (map['amount_jpy'] as num?)?.toDouble(),
      dueOrExpiryDate: map['due_or_expiry_date'] != null
          ? DateTime.tryParse(map['due_or_expiry_date'] as String)
          : null,
      documentIdentifier: map['document_identifier'] as String?,
      isPayableAtKonbini: (map['is_payable_at_konbini'] as int? ?? 0) == 1,
      paymentStatus: map['payment_status'] as String? ?? 'not_applicable',
      keyInstructionsJa: map['key_instructions_ja'] as String? ?? '',
      keyInstructionsEn: map['key_instructions_en'] as String? ?? '',
      rawExtractedText: map['raw_extracted_text'] as String? ?? '',
      isVerifiedByUser: (map['is_verified_by_user'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  StructuredDocument copyWith({
    int? id,
    int? vaultDocId,
    JapaneseDocumentType? docType,
    String? title,
    String? issuerOrProvider,
    double? amountJpy,
    DateTime? dueOrExpiryDate,
    String? documentIdentifier,
    bool? isPayableAtKonbini,
    String? paymentStatus,
    String? keyInstructionsJa,
    String? keyInstructionsEn,
    String? rawExtractedText,
    bool? isVerifiedByUser,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StructuredDocument(
      id: id ?? this.id,
      vaultDocId: vaultDocId ?? this.vaultDocId,
      docType: docType ?? this.docType,
      title: title ?? this.title,
      issuerOrProvider: issuerOrProvider ?? this.issuerOrProvider,
      amountJpy: amountJpy ?? this.amountJpy,
      dueOrExpiryDate: dueOrExpiryDate ?? this.dueOrExpiryDate,
      documentIdentifier: documentIdentifier ?? this.documentIdentifier,
      isPayableAtKonbini: isPayableAtKonbini ?? this.isPayableAtKonbini,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      keyInstructionsJa: keyInstructionsJa ?? this.keyInstructionsJa,
      keyInstructionsEn: keyInstructionsEn ?? this.keyInstructionsEn,
      rawExtractedText: rawExtractedText ?? this.rawExtractedText,
      isVerifiedByUser: isVerifiedByUser ?? this.isVerifiedByUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
