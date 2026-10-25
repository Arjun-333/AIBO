import 'dart:math';
import '../models/saved_location.dart';

class MapService {
  static final MapService instance = MapService._init();
  MapService._init();

  // Tokyo Metropolitan Bounding Box
  static const double tokyoMinLat = 35.50;
  static const double tokyoMaxLat = 35.85;
  static const double tokyoMinLng = 139.50;
  static const double tokyoMaxLng = 139.95;

  /// Earth radius in meters
  static const double earthRadiusMeters = 6371000.0;

  /// Haversine formula to compute great-circle distance between two GPS coordinates in meters
  double calculateDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  /// Calculates initial compass bearing in degrees (0°..360°) from point 1 to point 2
  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final y = sin(_degToRad(lon2 - lon1)) * cos(_degToRad(lat2));
    final x = cos(_degToRad(lat1)) * sin(_degToRad(lat2)) -
        sin(_degToRad(lat1)) * cos(_degToRad(lat2)) * cos(_degToRad(lon2 - lon1));
    final degrees = (_radToDeg(atan2(y, x)) + 360) % 360;
    return degrees;
  }

  /// Converts bearing degrees into readable cardinal directions
  String getCompassDirection(double bearingDegrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearingDegrees + 22.5) % 360 / 45).floor();
    return directions[index];
  }

  /// Formats distance into a clean string (e.g., '450 m' or '3.8 km')
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Checks if coordinates fall inside the Tokyo metropolitan region
  bool isWithinTokyoBoundingBox(double lat, double lon) {
    return lat >= tokyoMinLat && lat <= tokyoMaxLat && lon >= tokyoMinLng && lon <= tokyoMaxLng;
  }

  /// Returns curated, 100% offline essential landmarks for foreigners in Tokyo
  List<SavedLocation> getTokyoEssentialLocations() {
    return [
      SavedLocation(
        id: -1,
        nameEn: 'Tokyo Regional Immigration Bureau',
        nameJa: '東京出入国在留管理局 (品川入管)',
        category: 'immigration',
        latitude: 35.6268,
        longitude: 139.7547,
        address: '5-5-30 Konan, Minato-ku, Tokyo 108-0075',
        notes: 'Visa renewals, change of status, residence permits. Take bus from Shinagawa Station East Exit.',
        isFavorite: true,
      ),
      SavedLocation(
        id: -2,
        nameEn: 'Tokyo Metropolitan Government Office',
        nameJa: '東京都庁 (都庁)',
        category: 'ward_office',
        latitude: 35.6896,
        longitude: 139.6921,
        address: '2-8-1 Nishi-Shinjuku, Shinjuku-ku, Tokyo 163-8001',
        notes: 'Central Tokyo administrative hub, foreign resident advisory services, observation deck.',
        isFavorite: false,
      ),
      SavedLocation(
        id: -3,
        nameEn: 'St. Luke\'s International Hospital',
        nameJa: '聖路加国際病院',
        category: 'hospital',
        latitude: 35.6672,
        longitude: 139.7758,
        address: '9-1 Akashi-cho, Chuo-ku, Tokyo 104-8560',
        notes: 'Full 24/7 English-speaking medical emergency service and international clinic.',
        isFavorite: true,
      ),
      SavedLocation(
        id: -4,
        nameEn: 'Japanese Red Cross Medical Center',
        nameJa: '日本赤十字社医療センター',
        category: 'hospital',
        latitude: 35.6567,
        longitude: 139.7186,
        address: '4-1-22 Hiroo, Shibuya-ku, Tokyo 150-8935',
        notes: 'Emergency hospital facility with multilingual assistance support.',
        isFavorite: false,
      ),
      SavedLocation(
        id: -5,
        nameEn: 'Shibuya Station & Hachiko Police Box',
        nameJa: '渋谷駅・ハチ公前交番',
        category: 'koban',
        latitude: 35.6591,
        longitude: 139.7006,
        address: '1 Dogenzaka, Shibuya-ku, Tokyo',
        notes: 'Major transit interchange, 24/7 Police Koban for lost items and emergency reporting.',
        isFavorite: true,
      ),
      SavedLocation(
        id: -6,
        nameEn: 'Shinjuku Station (East Exit Police Box)',
        nameJa: '新宿駅東口交番',
        category: 'koban',
        latitude: 35.6917,
        longitude: 139.7013,
        address: '3 Shinjuku, Shinjuku-ku, Tokyo',
        notes: 'World\'s busiest transit hub. Police box right outside East Exit.',
        isFavorite: false,
      ),
      SavedLocation(
        id: -7,
        nameEn: 'Tokyo Central Station',
        nameJa: '東京駅 (丸の内口)',
        category: 'station',
        latitude: 35.6812,
        longitude: 139.7671,
        address: '1 Marunouchi, Chiyoda-ku, Tokyo 100-0005',
        notes: 'Main Shinkansen bullet train hub, JR Yamanote Line, Marunouchi Subway Line.',
        isFavorite: true,
      ),
    ];
  }

  double _degToRad(double deg) => deg * (pi / 180.0);
  double _radToDeg(double rad) => rad * (180.0 / pi);
}
