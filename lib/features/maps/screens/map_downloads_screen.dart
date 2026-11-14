import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../services/map_tile_service.dart';

/// MapDownloadsScreen — lets the user download, manage, and delete
/// offline map tile packs for Tokyo neighbourhoods.
///
/// Design constraints:
/// - Downloads via OSM (ODbL). Tiles cached to app documents dir.
/// - No live tile data is fabricated as "downloaded" until actually saved.
/// - User can cancel any in-progress download.
class MapDownloadsScreen extends StatefulWidget {
  const MapDownloadsScreen({super.key});

  @override
  State<MapDownloadsScreen> createState() => _MapDownloadsScreenState();
}

class _MapDownloadsScreenState extends State<MapDownloadsScreen> {
  final Map<String, TileDownloadStatus> _statuses = {};
  final Map<String, double> _progress = {};   // 0.0 → 1.0
  final Map<String, bool> _cancelled = {};
  double _cachedSizeMb = 0;
  bool _loadingStatus = true;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    setState(() => _loadingStatus = true);
    final size = await MapTileService.instance.getCachedSizeMb();
    final Map<String, TileDownloadStatus> statuses = {};
    for (final r in MapTileService.availableRegions) {
      statuses[r.id] = await MapTileService.instance.getRegionStatus(r);
    }
    if (mounted) {
      setState(() {
        _statuses.addAll(statuses);
        _cachedSizeMb = size;
        _loadingStatus = false;
      });
    }
  }

  Future<void> _startDownload(DownloadableRegion region) async {
    setState(() {
      _statuses[region.id] = TileDownloadStatus.downloading;
      _progress[region.id] = 0.0;
      _cancelled[region.id] = false;
    });

    await MapTileService.instance.downloadRegion(
      region,
      isCancelled: () => _cancelled[region.id] ?? false,
      onProgress: (downloaded, total) {
        if (mounted) {
          setState(() {
            _progress[region.id] = total > 0 ? downloaded / total : 0.0;
          });
        }
      },
    );

    if (mounted) {
      final wasCancelled = _cancelled[region.id] ?? false;
      setState(() {
        _statuses[region.id] = wasCancelled
            ? TileDownloadStatus.notDownloaded
            : TileDownloadStatus.downloaded;
        _progress.remove(region.id);
      });
      await _refreshStatus();
    }
  }

  Future<void> _deleteRegion(DownloadableRegion region) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Offline Map?'),
        content: Text('Remove "${region.nameEn}" from device storage?\nYou can re-download it anytime with Wi-Fi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await MapTileService.instance.deleteRegion(region);
      await _refreshStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Map Downloads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh status',
            onPressed: _refreshStatus,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Storage summary banner ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surfaceDark,
            child: Row(
              children: [
                const Icon(Icons.storage_outlined, color: AppTheme.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: _loadingStatus
                      ? const Text('Calculating cache size…', style: TextStyle(fontSize: 12, color: Colors.white54))
                      : Text(
                          'Map cache: ${_cachedSizeMb.toStringAsFixed(1)} MB used on device.',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                ),
              ],
            ),
          ),

          // ── Info banner ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🗺️  Offline Map Packs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 6),
                  Text(
                    'Download a region once over Wi-Fi, then use it fully offline.\n'
                    'Tiles are sourced from OpenStreetMap (ODbL licence) and cached\n'
                    'locally for 7 days. No personal data is ever sent to OSM servers.',
                    style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          // ── Region list ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: MapTileService.availableRegions.length,
              itemBuilder: (context, idx) {
                final region = MapTileService.availableRegions[idx];
                final status = _statuses[region.id] ?? TileDownloadStatus.notDownloaded;
                final progress = _progress[region.id];
                final isDownloading = status == TileDownloadStatus.downloading;
                final isDownloaded = status == TileDownloadStatus.downloaded;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    region.nameEn,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    region.nameJa,
                                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                                  ),
                                ],
                              ),
                            ),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDownloaded
                                    ? AppTheme.primary.withOpacity(0.2)
                                    : isDownloading
                                        ? Colors.amber.withOpacity(0.2)
                                        : Colors.white10,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isDownloaded ? '✓ Offline' : isDownloading ? '⬇ Downloading' : '☁ Not saved',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDownloaded
                                      ? AppTheme.primary
                                      : isDownloading
                                          ? Colors.amber
                                          : Colors.white38,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          region.description,
                          style: const TextStyle(fontSize: 12, color: Colors.white60, height: 1.4),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '~${region.estimateSizeMb().toStringAsFixed(0)} MB • ${region.estimateTileCount()} tiles • Zoom ${region.zoomMin}–${region.zoomMax}',
                          style: const TextStyle(fontSize: 11, color: Colors.white38),
                        ),

                        // Progress bar (shown while downloading)
                        if (isDownloading && progress != null) ...[
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white10,
                            color: AppTheme.primary,
                            minHeight: 5,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}% downloaded',
                            style: const TextStyle(fontSize: 11, color: Colors.white38),
                          ),
                        ],

                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (!isDownloaded && !isDownloading)
                              ElevatedButton.icon(
                                onPressed: () => _startDownload(region),
                                icon: const Icon(Icons.download_outlined, size: 16),
                                label: const Text('Download'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 13),
                                ),
                              ),
                            if (isDownloading)
                              OutlinedButton.icon(
                                onPressed: () => setState(() => _cancelled[region.id] = true),
                                icon: const Icon(Icons.stop_outlined, size: 16),
                                label: const Text('Cancel'),
                              ),
                            if (isDownloaded) ...[
                              const Icon(Icons.check_circle_outline, color: AppTheme.primary, size: 18),
                              const SizedBox(width: 6),
                              const Text('Ready offline', style: TextStyle(fontSize: 13, color: AppTheme.primary)),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => _deleteRegion(region),
                                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                label: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
