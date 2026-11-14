import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// A named region of Tokyo that can be downloaded as a tile cache.
class DownloadableRegion {
  final String id;
  final String nameEn;
  final String nameJa;
  final String description;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final int zoomMin;
  final int zoomMax;

  const DownloadableRegion({
    required this.id,
    required this.nameEn,
    required this.nameJa,
    required this.description,
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
    this.zoomMin = 12,
    this.zoomMax = 16,
  });

  /// Approximate tile count across all zoom levels (for size estimation).
  int estimateTileCount() {
    int total = 0;
    for (int z = zoomMin; z <= zoomMax; z++) {
      final minTX = _lngToTileX(minLng, z);
      final maxTX = _lngToTileX(maxLng, z);
      final minTY = _latToTileY(maxLat, z); // note: Y axis is flipped for tiles
      final maxTY = _latToTileY(minLat, z);
      total += (maxTX - minTX + 1) * (maxTY - minTY + 1);
    }
    return total;
  }

  /// Rough size estimate in MB (average ~15 KB per tile for zoom 12-16).
  double estimateSizeMb() => (estimateTileCount() * 15) / 1024.0;
}

/// Download status for a region.
enum TileDownloadStatus { notDownloaded, downloading, downloaded, error }

/// MapTileService handles OSM tile downloading, caching, and cache management.
///
/// Tile source: OpenStreetMap (ODbL licence). Tiles are cached to the app's
/// documents directory and served from disk when offline.
///
/// Note: OSM tile servers have a Usage Policy. AIBO caches tiles for personal
/// offline use, which is explicitly permitted under the ODbL ADR (ADR-006).
class MapTileService {
  static final MapTileService instance = MapTileService._init();
  MapTileService._init();

  // OSM tile server (ADR-006 — OpenStreetMap ODbL)
  static const String _tileServerUrl = 'https://tile.openstreetmap.org';

  // User-agent header as required by OSM Tile Usage Policy
  static const String _userAgent = 'AIBO-PersonalApp/1.0 (offline personal use; github.com/aibo)';

  // Cache TTL — tiles expire after 7 days (keep data reasonably fresh)
  static const Duration _tileTtl = Duration(days: 7);

  // ── Pre-defined downloadable regions ──────────────────────────────────────

  static const List<DownloadableRegion> availableRegions = [
    DownloadableRegion(
      id: 'tokyo_central',
      nameEn: 'Tokyo Central (Yamanote Loop)',
      nameJa: '東京中心部（山手線内）',
      description: 'Covers the full Yamanote Line loop: Shinjuku, Shibuya, Harajuku, Akihabara, Ueno, Ikebukuro.',
      minLat: 35.63, maxLat: 35.75, minLng: 139.68, maxLng: 139.80,
      zoomMin: 12, zoomMax: 16,
    ),
    DownloadableRegion(
      id: 'shinjuku_ward',
      nameEn: 'Shinjuku Ward (新宿区)',
      nameJa: '新宿区',
      description: 'High-density tile cache for Shinjuku ward including Kabukicho, Ookubo, Yotsuya.',
      minLat: 35.67, maxLat: 35.71, minLng: 139.68, maxLng: 139.74,
      zoomMin: 14, zoomMax: 17,
    ),
    DownloadableRegion(
      id: 'shibuya_ward',
      nameEn: 'Shibuya & Harajuku (渋谷・原宿)',
      nameJa: '渋谷区',
      description: 'Detailed tile coverage of Shibuya crossing, Daikanyama, Harajuku, Omotesando.',
      minLat: 35.64, maxLat: 35.67, minLng: 139.69, maxLng: 139.73,
      zoomMin: 14, zoomMax: 17,
    ),
    DownloadableRegion(
      id: 'akihabara_ueno',
      nameEn: 'Akihabara & Ueno (秋葉原・上野)',
      nameJa: '台東区',
      description: 'Covers Akihabara, Ueno Park, Asakusa, Tokyo National Museum.',
      minLat: 35.69, maxLat: 35.73, minLng: 139.76, maxLng: 139.80,
      zoomMin: 14, zoomMax: 17,
    ),
  ];

  // ── Tile path resolution ──────────────────────────────────────────────────

  Future<Directory> _cacheDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'map_tiles'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _tilePath(Directory cacheDir, int z, int x, int y) =>
      p.join(cacheDir.path, '$z', '$x', '$y.png');

  // ── Tile serving ──────────────────────────────────────────────────────────

  /// Returns tile bytes from cache if fresh, otherwise fetches from OSM and caches.
  Future<Uint8List?> getTile(int z, int x, int y) async {
    final dir = await _cacheDir();
    final tilePath = _tilePath(dir, z, x, y);
    final file = File(tilePath);

    // Serve from cache if the file exists and is not stale
    if (await file.exists()) {
      final stat = await file.stat();
      if (DateTime.now().difference(stat.modified) < _tileTtl) {
        return file.readAsBytes();
      }
    }

    // Fetch from OSM
    try {
      final uri = Uri.parse('$_tileServerUrl/$z/$x/$y.png');
      final response = await http.get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Cache to disk
        await Directory(p.dirname(tilePath)).create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('[MapTileService] Tile fetch error z=$z x=$x y=$y: $e');
    }

    // Fall back to cached (possibly stale) version if offline
    if (await file.exists()) return file.readAsBytes();
    return null;
  }

  // ── Bulk download ─────────────────────────────────────────────────────────

  /// Downloads all tiles for [region], calling [onProgress] with (downloaded, total).
  ///
  /// Returns the number of tiles successfully downloaded.
  Future<int> downloadRegion(
    DownloadableRegion region, {
    required void Function(int downloaded, int total) onProgress,
    bool Function()? isCancelled,
  }) async {
    final dir = await _cacheDir();
    int downloaded = 0;
    int failed = 0;
    final totalEstimate = region.estimateTileCount();

    for (int z = region.zoomMin; z <= region.zoomMax; z++) {
      final minTX = _lngToTileX(region.minLng, z);
      final maxTX = _lngToTileX(region.maxLng, z);
      final minTY = _latToTileY(region.maxLat, z);
      final maxTY = _latToTileY(region.minLat, z);

      for (int x = minTX; x <= maxTX; x++) {
        for (int y = minTY; y <= maxTY; y++) {
          if (isCancelled?.call() == true) {
            debugPrint('[MapTileService] Download cancelled by user at z=$z x=$x y=$y');
            return downloaded;
          }

          final tilePath = _tilePath(dir, z, x, y);
          final file = File(tilePath);

          // Skip if already cached and fresh
          if (await file.exists()) {
            final stat = await file.stat();
            if (DateTime.now().difference(stat.modified) < _tileTtl) {
              downloaded++;
              onProgress(downloaded, totalEstimate);
              continue;
            }
          }

          try {
            final uri = Uri.parse('$_tileServerUrl/$z/$x/$y.png');
            final response = await http.get(uri, headers: {'User-Agent': _userAgent})
                .timeout(const Duration(seconds: 10));

            if (response.statusCode == 200) {
              await Directory(p.dirname(tilePath)).create(recursive: true);
              await file.writeAsBytes(response.bodyBytes);
              downloaded++;
            } else {
              failed++;
            }
          } catch (e) {
            failed++;
            debugPrint('[MapTileService] Failed z=$z x=$x y=$y: $e');
          }

          onProgress(downloaded, totalEstimate);

          // Polite delay between requests (OSM Usage Policy)
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
    }

    debugPrint('[MapTileService] Region "${region.nameEn}" done: $downloaded downloaded, $failed failed.');
    return downloaded;
  }

  /// Deletes all cached tiles for [region].
  Future<void> deleteRegion(DownloadableRegion region) async {
    final dir = await _cacheDir();
    for (int z = region.zoomMin; z <= region.zoomMax; z++) {
      final minTX = _lngToTileX(region.minLng, z);
      final maxTX = _lngToTileX(region.maxLng, z);
      final minTY = _latToTileY(region.maxLat, z);
      final maxTY = _latToTileY(region.minLat, z);

      for (int x = minTX; x <= maxTX; x++) {
        for (int y = minTY; y <= maxTY; y++) {
          final file = File(_tilePath(dir, z, x, y));
          if (await file.exists()) await file.delete();
        }
      }
    }
    debugPrint('[MapTileService] Deleted cache for "${region.nameEn}".');
  }

  /// Returns the on-disk size in MB for all cached tiles.
  Future<double> getCachedSizeMb() async {
    final dir = await _cacheDir();
    int totalBytes = 0;
    if (await dir.exists()) {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }
    }
    return totalBytes / (1024 * 1024);
  }

  /// Checks whether tiles for [region] are present in cache.
  Future<TileDownloadStatus> getRegionStatus(DownloadableRegion region) async {
    final dir = await _cacheDir();
    int z = (region.zoomMin + region.zoomMax) ~/ 2; // sample at mid-zoom
    final x = _lngToTileX((region.minLng + region.maxLng) / 2, z);
    final y = _latToTileY((region.minLat + region.maxLat) / 2, z);
    final file = File(_tilePath(dir, z, x, y));
    return await file.exists() ? TileDownloadStatus.downloaded : TileDownloadStatus.notDownloaded;
  }

  // ── Tile coordinate math ─────────────────────────────────────────────────

  static int _lngToTileX(double lng, int zoom) =>
      ((lng + 180) / 360 * pow(2, zoom)).floor();

  static int _latToTileY(double lat, int zoom) {
    final rad = lat * pi / 180;
    return ((1 - log(tan(rad) + 1 / cos(rad)) / pi) / 2 * pow(2, zoom)).floor();
  }
}
