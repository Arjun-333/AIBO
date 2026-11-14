import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../medication/models/medication_reminder.dart';

/// NotificationSettingsScreen — lets the user view, toggle, and manage
/// all scheduled local alarms (medication reminders) in one place.
///
/// No network calls. All changes are persisted locally in SQLite and
/// reflected immediately in the Android AlarmManager schedule.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  List<MedicationReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final list = await DatabaseHelper.instance.getMedications();
    if (mounted) {
      setState(() {
        _reminders = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleActive(MedicationReminder med) async {
    final updated = MedicationReminder(
      id: med.id,
      nameEn: med.nameEn,
      nameJa: med.nameJa,
      dosage: med.dosage,
      timing: med.timing,
      scheduledTime: med.scheduledTime,
      instructions: med.instructions,
      category: med.category,
      isActive: !med.isActive, // flip
      lastTakenAt: med.lastTakenAt,
      createdAt: med.createdAt,
    );

    await DatabaseHelper.instance.updateMedication(updated);

    if (updated.isActive) {
      await NotificationService.instance.scheduleMedicationReminder(updated);
    } else if (med.id != null) {
      await NotificationService.instance.cancelMedicationReminder(med.id!);
    }

    _loadReminders();
  }

  Future<void> _rescheduleAll() async {
    final meds = await DatabaseHelper.instance.getMedications();
    await NotificationService.instance.rescheduleAll(meds);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${meds.where((m) => m.isActive).length} reminders rescheduled ✓'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _reminders.where((m) => m.isActive).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reschedule all active alarms',
            onPressed: _rescheduleAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Status banner ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: AppTheme.surfaceDark,
                  child: Row(
                    children: [
                      Icon(
                        active > 0 ? Icons.alarm_on : Icons.alarm_off,
                        color: active > 0 ? AppTheme.primary : Colors.white38,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          active > 0
                              ? '$active active alarm${active == 1 ? '' : 's'} scheduled via Android AlarmManager.'
                              : 'No active reminders. Add a medication to schedule alarms.',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Info card ───────────────────────────────────────────────
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
                        Text('⏰  How Alarms Work', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(height: 6),
                        Text(
                          '• Alarms fire even when the app is closed or the phone is in Doze mode.\n'
                          '• Alarms survive app restarts and are restored at boot.\n'
                          '• Toggle the switch below to enable/disable each reminder.\n'
                          '• Tap ↺ in the top bar to reschedule all alarms after a reboot.',
                          style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Reminder list ───────────────────────────────────────────
                Expanded(
                  child: _reminders.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off_outlined, size: 48, color: Colors.white24),
                              SizedBox(height: 12),
                              Text(
                                'No medication reminders yet.\nAdd one from the Tablets screen.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white38, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _reminders.length,
                          itemBuilder: (context, idx) {
                            final med = _reminders[idx];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: med.isActive
                                        ? AppTheme.primary.withOpacity(0.15)
                                        : Colors.white10,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.medication_outlined,
                                    color: med.isActive ? AppTheme.primary : Colors.white30,
                                  ),
                                ),
                                title: Text(
                                  med.nameEn,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: med.isActive ? Colors.white : Colors.white38,
                                  ),
                                ),
                                subtitle: Text(
                                  '${med.scheduledTime} • ${med.timing} • ${med.dosage}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: med.isActive ? Colors.white54 : Colors.white24,
                                  ),
                                ),
                                trailing: Switch(
                                  value: med.isActive,
                                  activeColor: AppTheme.primary,
                                  onChanged: (_) => _toggleActive(med),
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
