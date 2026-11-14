class PersonalContext {
  final int? id;
  final String fullName;
  final String katakanaName;
  final String homeWard;
  final String homeAddressJa;
  final String nearestStation;
  final String commuteRoute;
  final String workplaceSchool;
  final String jlptLevel;
  final String residenceStatus;
  final DateTime? residenceExpiryDate;
  final double monthlyBudgetJpy;
  final double dailyBudgetJpy;
  final bool hasMyNumberCard;
  final String nationalPensionStatus;
  final String burnableGarbageDays;
  final String recyclablePlasticsDays;
  final String nonBurnableDays;
  final DateTime updatedAt;

  const PersonalContext({
    this.id,
    this.fullName = 'Resident User',
    this.katakanaName = '',
    this.homeWard = 'Shinjuku-ku (新宿区)',
    this.homeAddressJa = '',
    this.nearestStation = 'Shinjuku Station (新宿駅)',
    this.commuteRoute = 'JR Yamanote Line',
    this.workplaceSchool = '',
    this.jlptLevel = 'N4 (Conversational)',
    this.residenceStatus = 'Engineer / Specialist in Humanities (技術・人文知識・国際業務)',
    this.residenceExpiryDate,
    this.monthlyBudgetJpy = 240000.0,
    this.dailyBudgetJpy = 8000.0,
    this.hasMyNumberCard = true,
    this.nationalPensionStatus = 'Standard Contribution (納付)',
    this.burnableGarbageDays = 'Tuesday, Friday (火・金)',
    this.recyclablePlasticsDays = 'Wednesday (水)',
    this.nonBurnableDays = '2nd & 4th Thursday (第2・4木曜)',
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  /// Calculates days remaining until the residence card / visa expires
  int? get daysUntilVisaExpiry {
    if (residenceExpiryDate == null) return null;
    final now = DateTime.now();
    final difference = residenceExpiryDate!.difference(now).inDays;
    return difference;
  }

  /// Whether the user is within the 3-month renewal application window
  bool get isVisaRenewalWindowOpen {
    final days = daysUntilVisaExpiry;
    if (days == null) return false;
    return days <= 90;
  }

  /// Builds a sanitized, non-identifying context prompt string for LLM injection
  String toSanitizedLlmContext() {
    final buffer = StringBuffer();
    buffer.writeln('USER CONTEXT & SURROUNDINGS:');
    buffer.writeln('• Residence Area: $homeWard');
    buffer.writeln('• Nearest Station: $nearestStation');
    if (commuteRoute.isNotEmpty) buffer.writeln('• Primary Commute: $commuteRoute');
    buffer.writeln('• Target Japanese Level: $jlptLevel');
    buffer.writeln('• Visa / Status: $residenceStatus');
    if (residenceExpiryDate != null) {
      final days = daysUntilVisaExpiry;
      buffer.writeln('• Visa Expiry: ${residenceExpiryDate!.year}-${residenceExpiryDate!.month.toString().padLeft(2, '0')}-${residenceExpiryDate!.day.toString().padLeft(2, '0')} (${days ?? 0} days remaining)');
    }
    buffer.writeln('• Local Garbage Schedule: Burnable on $burnableGarbageDays, Plastics on $recyclablePlasticsDays');
    return buffer.toString().trim();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'katakana_name': katakanaName,
      'home_ward': homeWard,
      'home_address_ja': homeAddressJa,
      'nearest_station': nearestStation,
      'commute_route': commuteRoute,
      'workplace_school': workplaceSchool,
      'jlpt_level': jlptLevel,
      'residence_status': residenceStatus,
      'residence_expiry_date': residenceExpiryDate?.toIso8601String(),
      'monthly_budget_jpy': monthlyBudgetJpy,
      'daily_budget_jpy': dailyBudgetJpy,
      'has_my_number_card': hasMyNumberCard ? 1 : 0,
      'national_pension_status': nationalPensionStatus,
      'burnable_garbage_days': burnableGarbageDays,
      'recyclable_plastics_days': recyclablePlasticsDays,
      'non_burnable_days': nonBurnableDays,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory PersonalContext.fromMap(Map<String, dynamic> map) {
    return PersonalContext(
      id: map['id'] as int?,
      fullName: map['full_name'] as String? ?? 'Resident User',
      katakanaName: map['katakana_name'] as String? ?? '',
      homeWard: map['home_ward'] as String? ?? 'Shinjuku-ku (新宿区)',
      homeAddressJa: map['home_address_ja'] as String? ?? '',
      nearestStation: map['nearest_station'] as String? ?? 'Shinjuku Station (新宿駅)',
      commuteRoute: map['commute_route'] as String? ?? 'JR Yamanote Line',
      workplaceSchool: map['workplace_school'] as String? ?? '',
      jlptLevel: map['jlpt_level'] as String? ?? 'N4 (Conversational)',
      residenceStatus: map['residence_status'] as String? ?? 'Engineer / Specialist in Humanities',
      residenceExpiryDate: map['residence_expiry_date'] != null
          ? DateTime.tryParse(map['residence_expiry_date'] as String)
          : null,
      monthlyBudgetJpy: (map['monthly_budget_jpy'] as num?)?.toDouble() ?? 240000.0,
      dailyBudgetJpy: (map['daily_budget_jpy'] as num?)?.toDouble() ?? 8000.0,
      hasMyNumberCard: (map['has_my_number_card'] as int? ?? 1) == 1,
      nationalPensionStatus: map['national_pension_status'] as String? ?? 'Standard Contribution (納付)',
      burnableGarbageDays: map['burnable_garbage_days'] as String? ?? 'Tuesday, Friday (火・金)',
      recyclablePlasticsDays: map['recyclable_plastics_days'] as String? ?? 'Wednesday (水)',
      nonBurnableDays: map['non_burnable_days'] as String? ?? '2nd & 4th Thursday (第2・4木曜)',
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  PersonalContext copyWith({
    int? id,
    String? fullName,
    String? katakanaName,
    String? homeWard,
    String? homeAddressJa,
    String? nearestStation,
    String? commuteRoute,
    String? workplaceSchool,
    String? jlptLevel,
    String? residenceStatus,
    DateTime? residenceExpiryDate,
    double? monthlyBudgetJpy,
    double? dailyBudgetJpy,
    bool? hasMyNumberCard,
    String? nationalPensionStatus,
    String? burnableGarbageDays,
    String? recyclablePlasticsDays,
    String? nonBurnableDays,
    DateTime? updatedAt,
  }) {
    return PersonalContext(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      katakanaName: katakanaName ?? this.katakanaName,
      homeWard: homeWard ?? this.homeWard,
      homeAddressJa: homeAddressJa ?? this.homeAddressJa,
      nearestStation: nearestStation ?? this.nearestStation,
      commuteRoute: commuteRoute ?? this.commuteRoute,
      workplaceSchool: workplaceSchool ?? this.workplaceSchool,
      jlptLevel: jlptLevel ?? this.jlptLevel,
      residenceStatus: residenceStatus ?? this.residenceStatus,
      residenceExpiryDate: residenceExpiryDate ?? this.residenceExpiryDate,
      monthlyBudgetJpy: monthlyBudgetJpy ?? this.monthlyBudgetJpy,
      dailyBudgetJpy: dailyBudgetJpy ?? this.dailyBudgetJpy,
      hasMyNumberCard: hasMyNumberCard ?? this.hasMyNumberCard,
      nationalPensionStatus: nationalPensionStatus ?? this.nationalPensionStatus,
      burnableGarbageDays: burnableGarbageDays ?? this.burnableGarbageDays,
      recyclablePlasticsDays: recyclablePlasticsDays ?? this.recyclablePlasticsDays,
      nonBurnableDays: nonBurnableDays ?? this.nonBurnableDays,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
