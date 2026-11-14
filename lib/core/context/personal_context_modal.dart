import 'package:flutter/material.dart';
import '../../core/services/sound_motion_service.dart';
import '../../core/theme/app_theme.dart';
import 'personal_context_model.dart';
import 'personal_context_service.dart';

/// Modal dialog allowing the user to configure their personal Japan Life context:
/// Ward/City, Japanese address, nearest train station, JLPT level, and visa expiry.
class PersonalContextModal extends StatefulWidget {
  const PersonalContextModal({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const PersonalContextModal(),
    );
  }

  @override
  State<PersonalContextModal> createState() => _PersonalContextModalState();
}

class _PersonalContextModalState extends State<PersonalContextModal> {
  final _wardCtrl = TextEditingController();
  final _addressJaCtrl = TextEditingController();
  final _stationCtrl = TextEditingController();
  final _commuteCtrl = TextEditingController();
  String _jlptLevel = 'N4 (Conversational)';
  final _visaStatusCtrl = TextEditingController();
  DateTime? _visaExpiryDate;
  bool _isLoading = true;

  final List<String> _jlptOptions = [
    'N5 (Beginner)',
    'N4 (Conversational)',
    'N3 (Intermediate)',
    'N2 (Business)',
    'N1 (Fluent)',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentContext();
  }

  Future<void> _loadCurrentContext() async {
    final ctx = await PersonalContextService.instance.getContext();
    if (mounted) {
      setState(() {
        _wardCtrl.text = ctx.homeWard;
        _addressJaCtrl.text = ctx.homeAddressJa;
        _stationCtrl.text = ctx.nearestStation;
        _commuteCtrl.text = ctx.commuteRoute;
        _jlptLevel = ctx.jlptLevel;
        _visaStatusCtrl.text = ctx.residenceStatus;
        _visaExpiryDate = ctx.residenceExpiryDate;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveContext() async {
    final current = await PersonalContextService.instance.getContext();
    final updated = current.copyWith(
      homeWard: _wardCtrl.text.trim(),
      homeAddressJa: _addressJaCtrl.text.trim(),
      nearestStation: _stationCtrl.text.trim(),
      commuteRoute: _commuteCtrl.text.trim(),
      jlptLevel: _jlptLevel,
      residenceStatus: _visaStatusCtrl.text.trim(),
      residenceExpiryDate: _visaExpiryDate,
      updatedAt: DateTime.now(),
    );

    await PersonalContextService.instance.updateContext(updated);
    if (mounted) {
      Navigator.pop(context);
      SoundMotionService.instance.showJapaneseNotification(
        context,
        title: 'Context Engine Updated (個人設定保存)',
        messageJa: 'AIBO is now context-aware of ${_wardCtrl.text.trim()} & ${_stationCtrl.text.trim()}.',
        iconEmoji: '🧠',
        accentColor: AppTheme.matchaTeal,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator(color: AppTheme.inkBlack)));
    }

    return Padding(
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
                const Row(
                  children: [
                    Icon(Icons.tune, color: AppTheme.inkBlack, size: 22),
                    SizedBox(width: 8),
                    Text('Personal Context Engine', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'AIBO uses this structured context to ground answers, route to your ward office, plan transit, and flag document expirations.',
              style: TextStyle(fontSize: 12, color: AppTheme.charcoal, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Home Ward
            TextField(
              controller: _wardCtrl,
              decoration: const InputDecoration(
                labelText: 'Residence Ward / Municipality (区・市)',
                hintText: 'e.g. Shinjuku-ku (新宿区) or Shibuya-ku',
                filled: true,
                fillColor: AppTheme.washiCream,
              ),
            ),
            const SizedBox(height: 12),

            // Nearest Station
            TextField(
              controller: _stationCtrl,
              decoration: const InputDecoration(
                labelText: 'Nearest Train Station (最寄り駅)',
                hintText: 'e.g. Shin-Okubo Station (新大久保駅)',
                filled: true,
                fillColor: AppTheme.washiCream,
              ),
            ),
            const SizedBox(height: 12),

            // Commute Line
            TextField(
              controller: _commuteCtrl,
              decoration: const InputDecoration(
                labelText: 'Primary Commute Line (利用路線)',
                hintText: 'e.g. JR Yamanote Line or Tokyo Metro Marunouchi',
                filled: true,
                fillColor: AppTheme.washiCream,
              ),
            ),
            const SizedBox(height: 12),

            // Japanese Target Level
            DropdownButtonFormField<String>(
              value: _jlptOptions.contains(_jlptLevel) ? _jlptLevel : _jlptOptions[1],
              decoration: const InputDecoration(
                labelText: 'Japanese Proficiency Level (日本語レベル)',
                filled: true,
                fillColor: AppTheme.washiCream,
              ),
              items: _jlptOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _jlptLevel = val);
              },
            ),
            const SizedBox(height: 12),

            // Residence Status
            TextField(
              controller: _visaStatusCtrl,
              decoration: const InputDecoration(
                labelText: 'Visa / Residence Status (在留資格)',
                hintText: 'e.g. Engineer / Specialist in Humanities',
                filled: true,
                fillColor: AppTheme.washiCream,
              ),
            ),
            const SizedBox(height: 12),

            // Visa Expiry Date Picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _visaExpiryDate ?? DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _visaExpiryDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.washiCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warmBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Residence Card Expiration (在留期間満了日)', style: TextStyle(fontSize: 11, color: AppTheme.charcoal)),
                        const SizedBox(height: 2),
                        Text(
                          _visaExpiryDate != null
                              ? '${_visaExpiryDate!.year}-${_visaExpiryDate!.month.toString().padLeft(2, '0')}-${_visaExpiryDate!.day.toString().padLeft(2, '0')}'
                              : 'Tap to set expiration date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _visaExpiryDate != null ? AppTheme.inkBlack : AppTheme.mutedGrey,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.calendar_today, size: 18, color: AppTheme.charcoal),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.inkBlack,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saveContext,
                child: const Text('Save Life Context', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
