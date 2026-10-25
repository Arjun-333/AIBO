class SavedLocation {
  final int? id;
  final String nameEn;
  final String nameJa;
  final String category; // 'home', 'station', 'koban', 'ward_office', 'hospital', 'konbini', 'immigration', 'other'
  final double latitude;
  final double longitude;
  final String address;
  final String notes;
  final bool isFavorite;
  final DateTime createdAt;

  SavedLocation({
    this.id,
    required this.nameEn,
    this.nameJa = '',
    required this.category,
    required this.latitude,
    required this.longitude,
    this.address = '',
    this.notes = '',
    this.isFavorite = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ja': nameJa,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'notes': notes,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavedLocation.fromMap(Map<String, dynamic> map) {
    return SavedLocation(
      id: map['id'] as int?,
      nameEn: map['name_en'] as String? ?? '',
      nameJa: map['name_ja'] as String? ?? '',
      category: map['category'] as String? ?? 'other',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
