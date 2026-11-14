import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../database/database_helper.dart';

/// Snapshot data payload for the Android Home Screen Widget.
class WidgetSnapshot {
  final String dateDisplayJa;
  final String spentTodayDisplay;
  final String nextMedicationDue;
  final String activeTrashAlert;
  final int pendingTaskCount;
  final DateTime updatedAt;

  const WidgetSnapshot({
    required this.dateDisplayJa,
    required this.spentTodayDisplay,
    required this.nextMedicationDue,
    required this.activeTrashAlert,
    required this.pendingTaskCount,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'date_ja': dateDisplayJa,
        'spent_today': spentTodayDisplay,
        'next_med': nextMedicationDue,
        'trash_alert': activeTrashAlert,
        'pending_tasks': pendingTaskCount,
        'updated_at': updatedAt.toIso8601String(),
      };
}

/// Service to synchronize essential daily metrics to the Android Home Screen Widget.
///
/// Features displayed on the widget:
/// 1. Today's date with Japanese day of week (e.g., 2026年11月13日 (金))
/// 2. Yen spent today vs budget
/// 3. Next tablet/medication dose time
/// 4. Today's garbage collection category (Burnable, PET bottles, etc.)
///
/// Operates 100% offline with zero cost.
class WidgetDataService {
  static final WidgetDataService instance = WidgetDataService._init();
  WidgetDataService._init();

  static const MethodChannel _widgetChannel = MethodChannel('com.aibo.aibo/widget');

  /// Computes the latest metrics from SQLite and writes the widget snapshot.
  Future<WidgetSnapshot> updateWidgetSnapshot() async {
    final now = DateTime.now();

    // 1. Japanese Date
    const weekdaysJa = ['月', '火', '水', '木', '金', '土', '日'];
    final dateDisplay = '${now.year}年${now.month}月${now.day}日 (${weekdaysJa[now.weekday - 1]})';

    // 2. Spending today
    int spentToday = 0;
    try {
      final expenses = await DatabaseHelper.instance.getExpenses();
      for (final exp in expenses) {
        if (exp.date.year == now.year && exp.date.month == now.month && exp.date.day == now.day) {
          spentToday += exp.amount;
        }
      }
    } catch (_) {}

    // 3. Next medication
    String nextMed = 'None scheduled';
    try {
      final meds = await DatabaseHelper.instance.getMedications();
      final active = meds.where((m) => m.isActive && !m.isTakenToday).toList();
      if (active.isNotEmpty) {
        active.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
        nextMed = '${active.first.nameEn} (${active.first.scheduledTime})';
      } else {
        nextMed = 'All doses taken (完了)';
      }
    } catch (_) {}

    // 4. Pending tasks & garbage
    int pendingTasks = 0;
    String trashAlert = 'Check local ward schedule';
    try {
      final tasks = await DatabaseHelper.instance.getTasks();
      pendingTasks = tasks.where((t) => !t.isCompleted).length;

      // Trash rules heuristic by weekday
      switch (now.weekday) {
        case DateTime.tuesday:
        case DateTime.friday:
          trashAlert = 'Burnable (燃えるごみ)';
          break;
        case DateTime.wednesday:
          trashAlert = 'PET / Plastics (プラ・資源)';
          break;
        case DateTime.thursday:
          trashAlert = 'Non-burnable / Cans (燃えないごみ・缶)';
          break;
        default:
          trashAlert = 'No collection today';
      }
    } catch (_) {}

    final snapshot = WidgetSnapshot(
      dateDisplayJa: dateDisplay,
      spentTodayDisplay: '¥${spentToday.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
      nextMedicationDue: nextMed,
      activeTrashAlert: trashAlert,
      pendingTaskCount: pendingTasks,
      updatedAt: now,
    );

    // Save snapshot to local app documents directory for widget retrieval
    try {
      final docs = await getApplicationDocumentsDirectory();
      final file = File(p.join(docs.path, 'widget_snapshot.json'));
      await file.writeAsString(jsonEncode(snapshot.toJson()));
    } catch (e) {
      debugPrint('[WidgetDataService] Could not write snapshot file: $e');
    }

    // Notify native Android widget receiver via Platform Channel
    try {
      await _widgetChannel.invokeMethod('updateAppWidget', snapshot.toJson());
    } catch (e) {
      // Graceful fallback if platform channel not registered in headless preview
      debugPrint('[WidgetDataService] Platform channel notice: $e');
    }

    return snapshot;
  }
}
