import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/maps/models/saved_location.dart';
import 'package:aibo/features/maps/services/map_service.dart';

void main() {
  group('MapService & Navigation Logic Tests', () {
    final mapService = MapService.instance;

    // Known Tokyo coordinates
    const shinjukuLat = 35.6909;
    const shinjukuLng = 139.7003;

    const shibuyaLat = 35.6580;
    const shibuyaLng = 139.7016;

    const tokyoStationLat = 35.6812;
    const tokyoStationLng = 139.7671;

    test('Computes accurate Haversine distance between Tokyo landmarks', () {
      // Shinjuku Station to Shibuya Station is approximately 3.6 to 3.7 km
      final distance = mapService.calculateDistanceMeters(
        shinjukuLat,
        shinjukuLng,
        shibuyaLat,
        shibuyaLng,
      );

      expect(distance > 3400, true);
      expect(distance < 3900, true);
      expect(mapService.formatDistance(distance).contains('km'), true);

      // Same point distance should be zero
      final zeroDist = mapService.calculateDistanceMeters(
        shinjukuLat,
        shinjukuLng,
        shinjukuLat,
        shinjukuLng,
      );
      expect(zeroDist, 0.0);
    });

    test('Calculates compass bearing and cardinal direction correctly', () {
      // Heading South from Shinjuku to Shibuya
      final bearing = mapService.calculateBearing(
        shinjukuLat,
        shinjukuLng,
        shibuyaLat,
        shibuyaLng,
      );

      // Shibuya is roughly due South of Shinjuku (approx 175° to 185°)
      expect(bearing >= 170.0 && bearing <= 190.0, true);

      final cardinal = mapService.getCompassDirection(bearing);
      expect(cardinal, 'S');

      // East from Shinjuku to Tokyo Station
      final eastBearing = mapService.calculateBearing(
        shinjukuLat,
        shinjukuLng,
        tokyoStationLat,
        tokyoStationLng,
      );
      // Tokyo Station is South-East of Shinjuku
      final eastCardinal = mapService.getCompassDirection(eastBearing);
      expect(['E', 'SE'].contains(eastCardinal), true);
    });

    test('Verifies Tokyo metropolitan bounding box constraints', () {
      // Coordinates inside Tokyo
      expect(mapService.isWithinTokyoBoundingBox(shinjukuLat, shinjukuLng), true);
      expect(mapService.isWithinTokyoBoundingBox(35.6268, 139.7547), true); // Shinagawa

      // Coordinates outside Tokyo (e.g. Osaka: 34.6937, 135.5023)
      expect(mapService.isWithinTokyoBoundingBox(34.6937, 135.5023), false);

      // London
      expect(mapService.isWithinTokyoBoundingBox(51.5074, -0.1278), false);
    });

    test('Curated essential locations list contains critical emergency & legal landmarks', () {
      final essentials = mapService.getTokyoEssentialLocations();
      expect(essentials.isNotEmpty, true);

      // Must include Immigration Bureau
      expect(essentials.any((loc) => loc.category == 'immigration'), true);

      // Must include English-speaking hospital
      expect(essentials.any((loc) => loc.category == 'hospital'), true);

      // Must include Police Koban
      expect(essentials.any((loc) => loc.category == 'koban'), true);
    });

    test('SavedLocation serialization and deserialization', () {
      final loc = SavedLocation(
        id: 7,
        nameEn: 'My Apartment (Nakano)',
        nameJa: '中野のアパート',
        category: 'home',
        latitude: 35.7058,
        longitude: 139.6658,
        address: 'Nakano-ku, Tokyo',
        notes: '3 min walk from North Exit',
        isFavorite: true,
      );

      final map = loc.toMap();
      expect(map['name_en'], 'My Apartment (Nakano)');
      expect(map['name_ja'], '中野のアパート');
      expect(map['is_favorite'], 1);

      final restored = SavedLocation.fromMap(map);
      expect(restored.id, 7);
      expect(restored.nameEn, 'My Apartment (Nakano)');
      expect(restored.latitude, 35.7058);
      expect(restored.isFavorite, true);
    });
  });
}
