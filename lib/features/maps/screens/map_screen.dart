import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../models/saved_location.dart';
import '../services/map_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapService _mapService = MapService.instance;
  List<SavedLocation> _userLocations = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = true;

  // Reference origin coordinate (Defaults to Shinjuku Station central hub: 35.6909, 139.7003)
  double _currentLat = 35.6909;
  double _currentLng = 139.7003;
  String _originName = 'Shinjuku Hub (新宿駅)';

  SavedLocation? _selectedLocation;

  final List<Map<String, dynamic>> _categories = const [
    {'id': 'all', 'label': 'All Points', 'icon': Icons.map_outlined},
    {'id': 'koban', 'label': '👮 Police Koban (交番)', 'icon': Icons.local_police_outlined},
    {'id': 'station', 'label': '🚉 Stations (駅)', 'icon': Icons.train_outlined},
    {'id': 'ward_office', 'label': '🏛️ Offices (役所)', 'icon': Icons.account_balance_outlined},
    {'id': 'immigration', 'label': '🛂 Immigration (入管)', 'icon': Icons.badge_outlined},
    {'id': 'hospital', 'label': '🏥 Hospitals (病院)', 'icon': Icons.local_hospital_outlined},
    {'id': 'home', 'label': '🏠 My Places (自宅・保存)', 'icon': Icons.home_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final customLocations = await DatabaseHelper.instance.getSavedLocations();
    if (mounted) {
      setState(() {
        _userLocations = customLocations;
        _isLoading = false;
        if (_selectedLocation == null && _allLocations.isNotEmpty) {
          _selectedLocation = _allLocations.first;
        }
      });
    }
  }

  List<SavedLocation> get _allLocations {
    final curated = _mapService.getTokyoEssentialLocations();
    return [..._userLocations, ...curated];
  }

  List<SavedLocation> get _filteredLocations {
    return _allLocations.where((loc) {
      final matchesCategory = _selectedCategory == 'all' || loc.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          loc.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          loc.nameJa.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          loc.address.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _openExternalMap(double lat, double lng, String label) async {
    final uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
    final webUri = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=16/$lat/$lng');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch maps application')),
        );
      }
    }
  }

  Future<void> _showAddLocationModal() async {
    final nameEnCtrl = TextEditingController();
    final nameJaCtrl = TextEditingController();
    final latCtrl = TextEditingController(text: _currentLat.toStringAsFixed(4));
    final lngCtrl = TextEditingController(text: _currentLng.toStringAsFixed(4));
    final addressCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String category = 'home';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Save Offline Waypoint',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameEnCtrl,
                  style: const TextStyle(color: AppTheme.inkBlack),
                  decoration: const InputDecoration(
                    labelText: 'Name (English)',
                    hintText: 'e.g. My Apartment / Local Ward Office',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameJaCtrl,
                  style: const TextStyle(color: AppTheme.inkBlack),
                  decoration: const InputDecoration(
                    labelText: 'Name (Japanese / Furigana)',
                    hintText: 'e.g. 自宅 (じたく) / 区役所',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: AppTheme.inkBlack),
                        decoration: const InputDecoration(labelText: 'Latitude (緯度)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: lngCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: AppTheme.inkBlack),
                        decoration: const InputDecoration(labelText: 'Longitude (経度)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  style: const TextStyle(color: AppTheme.inkBlack),
                  decoration: const InputDecoration(
                    labelText: 'Street Address (住所)',
                    hintText: 'e.g. Shinjuku-ku, Tokyo',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  style: const TextStyle(color: AppTheme.inkBlack),
                  decoration: const InputDecoration(
                    labelText: 'Landmarks / Navigation Notes',
                    hintText: 'Near Exit 4, next to 7-Eleven',
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Category', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.where((c) => c['id'] != 'all').map((c) {
                    final isSelected = category == c['id'];
                    return ChoiceChip(
                      label: Text(c['label'] as String),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceLightDark,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setModalState(() => category = c['id'] as String);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppTheme.primary,
                    ),
                    onPressed: () async {
                      if (nameEnCtrl.text.trim().isEmpty) return;
                      final lat = double.tryParse(latCtrl.text.trim()) ?? 35.6895;
                      final lng = double.tryParse(lngCtrl.text.trim()) ?? 139.6917;

                      final newLoc = SavedLocation(
                        nameEn: nameEnCtrl.text.trim(),
                        nameJa: nameJaCtrl.text.trim(),
                        category: category,
                        latitude: lat,
                        longitude: lng,
                        address: addressCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                        isFavorite: true,
                      );

                      await DatabaseHelper.instance.insertLocation(newLoc);
                      Navigator.pop(ctx);
                      _loadLocations();
                    },
                    child: const Text('Save Offline Landmark', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSetOriginModal() {
    final latCtrl = TextEditingController(text: _currentLat.toStringAsFixed(4));
    final lngCtrl = TextEditingController(text: _currentLng.toStringAsFixed(4));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set Reference Origin Coordinate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'AIBO uses this reference point to compute 100% offline distance and compass bearing to all waypoints:',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Shinjuku (新宿)'),
                  onPressed: () {
                    setState(() {
                      _currentLat = 35.6909;
                      _currentLng = 139.7003;
                      _originName = 'Shinjuku Hub (新宿駅)';
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ActionChip(
                  label: const Text('Shibuya (渋谷)'),
                  onPressed: () {
                    setState(() {
                      _currentLat = 35.6580;
                      _currentLng = 139.7016;
                      _originName = 'Shibuya Station (渋谷駅)';
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ActionChip(
                  label: const Text('Tokyo Station (東京駅)'),
                  onPressed: () {
                    setState(() {
                      _currentLat = 35.6812;
                      _currentLng = 139.7671;
                      _originName = 'Tokyo Station (東京駅)';
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Custom Lat'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: lngCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Custom Lng'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final lat = double.tryParse(latCtrl.text.trim());
                  final lng = double.tryParse(lngCtrl.text.trim());
                  if (lat != null && lng != null) {
                    setState(() {
                      _currentLat = lat;
                      _currentLng = lng;
                      _originName = 'Custom (${lat.toStringAsFixed(3)}, ${lng.toStringAsFixed(3)})';
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Apply Coordinates'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Maps & Navigation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppTheme.accentTeal),
            tooltip: 'Set Reference Coordinate',
            onPressed: _showSetOriginModal,
          ),
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            tooltip: 'Save Offline Landmark',
            onPressed: _showAddLocationModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Origin & Bounding Box Banner
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.navigation_outlined, color: AppTheme.accentTeal, size: 18),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CURRENT ORIGIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white54)),
                              Text(_originName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTeal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('OSM Cache: 100% Offline', style: TextStyle(fontSize: 10, color: AppTheme.accentTeal, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                // Selected Waypoint Compass Radar Card
                if (_selectedLocation != null) _buildWaypointRadarCard(_selectedLocation!),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, size: 20, color: Colors.white54),
                      hintText: 'Search landmarks, koban, station exits...',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.white38),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      filled: true,
                      fillColor: AppTheme.surfaceDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),

                // Category Filter Bar
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = _selectedCategory == cat['id'];
                      return ChoiceChip(
                        avatar: Icon(cat['icon'] as IconData, size: 14, color: isSelected ? Colors.white : Colors.white60),
                        label: Text(cat['label'] as String),
                        selected: isSelected,
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceDark,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat['id'] as String);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // Landmarks & POI List
                Expanded(
                  child: _filteredLocations.isEmpty
                      ? Center(
                          child: Text(
                            'No landmarks found.',
                            style: TextStyle(color: Colors.white.withOpacity(0.5)),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: _filteredLocations.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final loc = _filteredLocations[index];
                            final distance = _mapService.calculateDistanceMeters(
                              _currentLat,
                              _currentLng,
                              loc.latitude,
                              loc.longitude,
                            );
                            final bearing = _mapService.calculateBearing(
                              _currentLat,
                              _currentLng,
                              loc.latitude,
                              loc.longitude,
                            );
                            final cardinal = _mapService.getCompassDirection(bearing);
                            final isSelected = _selectedLocation?.id == loc.id && _selectedLocation?.nameEn == loc.nameEn;

                            return Card(
                              color: isSelected ? AppTheme.surfaceLightDark : AppTheme.surfaceDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected ? AppTheme.accentTeal : Colors.white10,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: ListTile(
                                onTap: () => setState(() => _selectedLocation = loc),
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.primaryDark,
                                  child: Text(cardinal, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentTeal)),
                                ),
                                title: Text(
                                  loc.nameEn,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                                ),
                                subtitle: Text(
                                  loc.nameJa.isNotEmpty ? '${loc.nameJa} • ${loc.address}' : loc.address,
                                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _mapService.formatDistance(distance),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.accentTeal),
                                    ),
                                    Text(
                                      '${bearing.toStringAsFixed(0)}°',
                                      style: const TextStyle(fontSize: 10, color: Colors.white38),
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

  Widget _buildWaypointRadarCard(SavedLocation loc) {
    final distance = _mapService.calculateDistanceMeters(_currentLat, _currentLng, loc.latitude, loc.longitude);
    final bearing = _mapService.calculateBearing(_currentLat, _currentLng, loc.latitude, loc.longitude);
    final cardinal = _mapService.getCompassDirection(bearing);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.surfaceLightDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentTeal.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.nameEn,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    if (loc.nameJa.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        loc.nameJa,
                        style: const TextStyle(fontSize: 12, color: AppTheme.accentTeal, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
              // Compass Heading Radar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.navigation,
                      color: AppTheme.accentTeal,
                      size: 24,
                    ),
                    const SizedBox(height: 2),
                    Text('$cardinal • ${bearing.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (loc.notes.isNotEmpty)
            Text(
              loc.notes,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Straight-line: ${_mapService.formatDistance(distance)}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                    tooltip: 'Copy GPS Coordinates',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: '${loc.latitude}, ${loc.longitude}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coordinates copied to clipboard')),
                      );
                    },
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      side: const BorderSide(color: AppTheme.accentTeal),
                    ),
                    onPressed: () => _openExternalMap(loc.latitude, loc.longitude, loc.nameEn),
                    icon: const Icon(Icons.directions, size: 14, color: AppTheme.accentTeal),
                    label: const Text('Open Maps', style: TextStyle(fontSize: 11, color: AppTheme.accentTeal)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
