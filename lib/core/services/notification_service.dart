import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart';
import '../../features/medication/models/medication_reminder.dart';

/// NotificationService — wires flutter_local_notifications to Android AlarmManager.
///
/// Design constraints:
/// - All scheduling is 100% local/offline (no server push required).
/// - Exact alarms (setExactAndAllowWhileIdle) fire even in Doze mode.
/// - Each medication gets a stable notification ID derived from its database ID
///   so it can be cancelled individually without affecting other reminders.
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // -------------------------------------------------------------------------
  // Initialization
  // -------------------------------------------------------------------------

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Initialize the timezone database and set the local timezone (JST for Japan)
    tz.initializeTimeZones();
    final String localTimezone = await FlutterTimezone.getLocalTimezone();
    setLocalLocation(getLocation(localTimezone));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request POST_NOTIFICATIONS permission on Android 13+ (API 33+)
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    _initialized = true;
    debugPrint('[NotificationService] Initialized and permissions requested.');
  }

  void _onNotificationTap(NotificationResponse response) {
    // Future: navigate to Medication screen via Navigator or deep link.
    debugPrint('[NotificationService] Notification tapped: id=${response.id}');
  }

  // -------------------------------------------------------------------------
  // Medication reminder scheduling
  // -------------------------------------------------------------------------

  /// Schedule a daily exact alarm for [med] at its configured [scheduledTime].
  ///
  /// Uses a stable notification ID = med.id * 10 so each medication has
  /// a unique, predictable channel that can be individually cancelled.
  Future<void> scheduleMedicationReminder(MedicationReminder med) async {
    await initialize();

    if (!med.isActive || med.id == null) return;

    final notifId = _notifIdForMed(med.id!);
    final scheduledDate = _nextScheduledDateTime(med.scheduledTime);

    const androidDetails = AndroidNotificationDetails(
      'aibo_medication_channel',           // channel id
      'Medication Reminders',              // channel name
      channelDescription: 'Daily reminders to take your scheduled medication.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: '💊 Medication time',
      icon: '@mipmap/ic_launcher',
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    await _plugin.zonedSchedule(
      notifId,
      '💊 ${med.nameEn}',
      '${med.dosage} — ${med.instructions}',
      scheduledDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily at same time
    );

    debugPrint('[NotificationService] Scheduled ${med.nameEn} at ${med.scheduledTime} (id=$notifId)');
  }

  /// Cancel the alarm for a specific medication (e.g. when deleted or disabled).
  Future<void> cancelMedicationReminder(int medId) async {
    await initialize();
    await _plugin.cancel(_notifIdForMed(medId));
    debugPrint('[NotificationService] Cancelled reminder for medId=$medId');
  }

  /// Reschedule all active reminders — call after app restart or time change.
  Future<void> rescheduleAll(List<MedicationReminder> reminders) async {
    await initialize();
    // Cancel everything first to avoid duplicate alarms
    await _plugin.cancelAll();
    for (final med in reminders) {
      if (med.isActive) {
        await scheduleMedicationReminder(med);
      }
    }
    debugPrint('[NotificationService] Rescheduled ${reminders.where((m) => m.isActive).length} active reminders.');
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  static int _notifIdForMed(int medId) => medId * 10;

  /// Returns the next DateTime (today or tomorrow) for a given "HH:mm" string.
  static TZDateTime _nextScheduledDateTime(String scheduledTime) {
    final parts = scheduledTime.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

    final now = TZDateTime.now(local);
    var scheduled = TZDateTime(local, now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
