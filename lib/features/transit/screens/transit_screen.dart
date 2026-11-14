import 'package:flutter/material.dart';
import '../../../core/services/sound_motion_service.dart';
import '../../../core/theme/app_theme.dart';
import '../services/transit_service.dart';

class TransitScreen extends StatefulWidget {
  const TransitScreen({super.key});

  @override
  State<TransitScreen> createState() => _TransitScreenState();
}

class _TransitScreenState extends State<TransitScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TransitService _transitService = TransitService.instance;
  String _searchQuery = '';
  List<TrainStatusReport> _statuses = [];
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTrainStatuses();
  }

  Future<void> _loadTrainStatuses() async {
    setState(() => _isLoadingStatus = true);
    final reports = await _transitService.fetchTrainStatuses();
    if (mounted) {
      setState(() {
        _statuses = reports;
        _isLoadingStatus = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.washiCream,
      appBar: AppBar(
        title: const Text('Tokyo Transit Guide (電車ナビ)'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.inkBlack,
          unselectedLabelColor: AppTheme.mutedGrey,
          indicatorColor: AppTheme.inkBlack,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(icon: Icon(Icons.directions_subway_outlined), text: 'Lines & Exits'),
            Tab(icon: Icon(Icons.credit_card_outlined), text: 'IC Cards (Suica)'),
            Tab(icon: Icon(Icons.handshake_outlined), text: 'Train Manners'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLinesAndExitsTab(),
          _buildIcCardTab(),
          _buildMannersTab(),
        ],
      ),
    );
  }

  Widget _buildLinesAndExitsTab() {
    final lines = _transitService.getTokyoLines();
    final exits = _transitService.getStationExitGuides();

    final filteredExits = exits.where((e) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return e.stationEn.toLowerCase().contains(q) ||
          e.stationJa.contains(q) ||
          e.exitName.toLowerCase().contains(q) ||
          e.bestFor.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search Station or Exit
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val.trim()),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.charcoal),
            hintText: 'Search station exit (e.g. Shinjuku, Hachiko, Yaesu)...',
            hintStyle: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        const SizedBox(height: 14),

        // ── Real-Time / Cached Operation Status (ODPT Integration) ─────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.warmBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _statuses.any((s) => s.isLive) ? Icons.cell_tower : Icons.schedule,
                        size: 16,
                        color: _statuses.any((s) => s.isLive) ? AppTheme.matchaTeal : AppTheme.mutedGrey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statuses.any((s) => s.isLive) ? 'LIVE TRANSIT STATUS (ODPT)' : 'SCHEDULED TRANSIT OPERATION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: _statuses.any((s) => s.isLive) ? AppTheme.matchaTeal : AppTheme.charcoal,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _loadTrainStatuses,
                    child: _isLoadingStatus
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh, size: 18, color: AppTheme.mutedGrey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_statuses.isNotEmpty)
                ..._statuses.take(3).map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: s.statusText.contains('Normal') || s.statusText.contains('平常')
                                  ? AppTheme.matchaTeal
                                  : AppTheme.crimsonRed,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${s.lineName}: ${s.statusText}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.inkBlack),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: s.isLive ? AppTheme.matchaTeal.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              s.isLive ? 'Live' : 'Cached',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: s.isLive ? AppTheme.matchaTeal : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Major Train Lines
        const Text(
          'MAJOR TOKYO TRAIN & SUBWAY LINES',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal),
        ),
        const SizedBox(height: 10),

        ...lines.map((line) {
          final lineColor = Color(line.colorValue);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.warmBorder, width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    line.code,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            line.nameEn,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.inkBlack),
                          ),
                          Text(
                            line.operator,
                            style: const TextStyle(fontSize: 10, color: AppTheme.mutedGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(line.nameJa, style: const TextStyle(fontSize: 11, color: AppTheme.charcoal)),
                      const SizedBox(height: 6),
                      Text(
                        'Key Stations: ${line.majorStations.join(" • ")}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.charcoal),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        line.tips,
                        style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 20),

        // Station Exit Navigation Guide
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'STATION EXIT NAVIGATION (迷わない出口ガイド)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal),
            ),
            Text('${filteredExits.length} exits', style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey)),
          ],
        ),
        const SizedBox(height: 10),

        ...filteredExits.map((exit) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.warmBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${exit.stationEn} (${exit.stationJa})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.charcoal),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.matchaTeal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        exit.exitName,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.matchaTeal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Best For: ${exit.bestFor}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.inkBlack)),
                const SizedBox(height: 4),
                Text('Landmarks: ${exit.landmarks}', style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildIcCardTab() {
    final icGuides = _transitService.getIcCardGuide();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Suica & Pasmo Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E6F68), Color(0xFF1E4E49)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('JAPAN IC TRANSIT PASS', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  Icon(Icons.contactless, color: Colors.white, size: 24),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'Suica & PASMO Guide',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'One card for all trains, subways, buses, and konbini payments across Tokyo.',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        ...icGuides.map((g) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.warmBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.matchaTeal),
                    const SizedBox(width: 8),
                    Text(
                      g['title']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.inkBlack),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  g['detail']!,
                  style: const TextStyle(fontSize: 12, color: AppTheme.charcoal, height: 1.4),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMannersTab() {
    final rules = _transitService.getMannerRules();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.warmBorder, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'TOKYO COMMUTER CODE (電車のマナー)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal),
              ),
              SizedBox(height: 6),
              Text(
                'Tokyo trains operate on quiet consideration for fellow passengers. Follow these key etiquette guidelines for a seamless daily commute:',
                style: TextStyle(fontSize: 12, color: AppTheme.mutedGrey),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ...rules.map((r) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.warmBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.volume_off_outlined, size: 18, color: AppTheme.vermilionRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        r['title']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.inkBlack),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  r['rule']!,
                  style: const TextStyle(fontSize: 12, color: AppTheme.charcoal, height: 1.4),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
