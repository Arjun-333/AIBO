class EmergencyCard {
  final int? id;
  final String fullName;
  final String bloodType;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String allergies;
  final String medicalNotes;
  final String residenceCardNumber;
  final String insuranceNumber;
  final DateTime updatedAt;

  EmergencyCard({
    this.id,
    required this.fullName,
    required this.bloodType,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.allergies = '',
    this.medicalNotes = '',
    this.residenceCardNumber = '',
    this.insuranceNumber = '',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'blood_type': bloodType,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'allergies': allergies,
      'medical_notes': medicalNotes,
      'residence_card_number': residenceCardNumber,
      'insurance_number': insuranceNumber,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory EmergencyCard.fromMap(Map<String, dynamic> map) {
    return EmergencyCard(
      id: map['id'] as int?,
      fullName: map['full_name'] as String? ?? '',
      bloodType: map['blood_type'] as String? ?? 'Unknown',
      emergencyContactName: map['emergency_contact_name'] as String? ?? '',
      emergencyContactPhone: map['emergency_contact_phone'] as String? ?? '',
      allergies: map['allergies'] as String? ?? '',
      medicalNotes: map['medical_notes'] as String? ?? '',
      residenceCardNumber: map['residence_card_number'] as String? ?? '',
      insuranceNumber: map['insurance_number'] as String? ?? '',
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  EmergencyCard copyWith({
    int? id,
    String? fullName,
    String? bloodType,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? allergies,
    String? medicalNotes,
    String? residenceCardNumber,
    String? insuranceNumber,
    DateTime? updatedAt,
  }) {
    return EmergencyCard(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      bloodType: bloodType ?? this.bloodType,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      allergies: allergies ?? this.allergies,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      residenceCardNumber: residenceCardNumber ?? this.residenceCardNumber,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
