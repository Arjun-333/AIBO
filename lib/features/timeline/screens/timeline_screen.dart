import 'package:flutter/material.dart';
import '../../../core/services/sound_motion_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/timeline/unified_timeline_model.dart';
import '../../../core/timeline/unified_timeline_service.dart';

/// TimelineScreen — Visualizes the user's unified Life OS timeline in Japan.
/// Combines bills, document expirations, medication schedules, garbage days, and tasks.
class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<LifeTimelineEvent> _events = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    setState(() => _isLoading = true);
    final list = await UnifiedTimelineService.instance.getUnifiedTimeline();
    if (mounted) {
      setState(() {
        _events = list;
        _isLoading = false;
      });
    }
  }

  List<LifeTimelineEvent> get _filteredEvents {
    if (_selectedFilter == 'all') return _events;
    if (_selectedFilter == 'bills') {
      return _events.where((e) => e.category == LifeEventCategory.billDue || e.category == LifeEventCategory.documentRenewal).toList();
    }
    if (_selectedFilter == 'meds') {
      return _events.where((e) => e.category == LifeEventCategory.medicationDose).toList();
    }
    if (_selectedFilter == 'garbage') {
      return _events.where((e) => e.category == LifeEventCategory.trashCollection).toList();
    }
    return _events;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredEvents;

    return Scaffold(
      backgroundColor: AppTheme.washiCream,
      appBar: AppBar(
        title: const Text('Unified Life Timeline (生活タイムライン)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTimeline,
            tooltip: 'Refresh Timeline',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All Events'),
                  const SizedBox(width: 8),
                  _buildFilterChip('bills', '💴 Bills & Visas'),
                  const SizedBox(width: 8),
                  _buildFilterChip('meds', '💊 Tablets'),
                  const SizedBox(width: 8),
                  _buildFilterChip('garbage', '🗑️ Garbage Days'),
                ],
              ),
            ),
          ),

          // Events Timeline List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.inkBlack))
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.event_available_outlined, size: 54, color: AppTheme.mutedGrey),
                            const SizedBox(height: 12),
                            const Text(
                              'Your Japan Life Timeline is clear!',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.inkBlack),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Scan a bill in Document Vault or add a tablet\nto automatically populate this timeline.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: AppTheme.charcoal),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, idx) {
                          final event = filtered[idx];
                          return _buildTimelineCard(event);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: AppTheme.inkBlack,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.charcoal),
      backgroundColor: Colors.white,
      onSelected: (_) => setState(() => _selectedFilter = filterKey),
    );
  }

  Widget _buildTimelineCard(LifeTimelineEvent event) {
    final now = DateTime.now();
    final isToday = event.eventTime.year == now.year &&
        event.eventTime.month == now.month &&
        event.eventTime.day == now.day;

    final dateStr = isToday
        ? 'TODAY'
        : '${event.eventTime.month}/${event.eventTime.day} (${_getWeekdayJa(event.eventTime.weekday)})';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: event.isUrgent ? AppTheme.vermilionRed : AppTheme.warmBorder,
          width: event.isUrgent ? 1.8 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji / Category Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: event.isUrgent ? AppTheme.vermilionRed.withOpacity(0.12) : AppTheme.washiCream,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(event.categoryIconEmoji, style: const TextStyle(fontSize: 22)),
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
                      event.categoryLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: event.isUrgent ? AppTheme.vermilionRed : AppTheme.mutedGrey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isToday ? AppTheme.matchaTeal.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isToday ? AppTheme.matchaTeal : AppTheme.charcoal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.inkBlack),
                ),
                const SizedBox(height: 4),
                Text(
                  event.subtitle,
                  style: const TextStyle(fontSize: 12, color: AppTheme.charcoal, height: 1.3),
                ),
                if (event.isCompleted) ...[
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.check_circle, size: 14, color: AppTheme.matchaTeal),
                      SizedBox(width: 4),
                      Text('Completed / Logged (済)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.matchaTeal)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekdayJa(int weekday) {
    const list = ['月', '火', '水', '木', '金', '土', '日'];
    return list[weekday - 1];
  }
}
