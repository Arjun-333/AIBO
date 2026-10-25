import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/sound_motion_service.dart';
import '../../../core/theme/app_theme.dart';
import '../models/medication_reminder.dart';
import '../services/medication_service.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MedicationService _medService = MedicationService.instance;

  List<MedicationReminder> _reminders = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReminders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  Future<void> _toggleMedicationTaken(MedicationReminder med) async {
    final now = DateTime.now();
    final updated = MedicationReminder(
      id: med.id,
      nameEn: med.nameEn,
      nameJa: med.nameJa,
      dosage: med.dosage,
      timing: med.timing,
      scheduledTime: med.scheduledTime,
      instructions: med.instructions,
      category: med.category,
      isActive: med.isActive,
      lastTakenAt: med.isTakenToday ? null : now,
      createdAt: med.createdAt,
    );

    await DatabaseHelper.instance.updateMedication(updated);
    _loadReminders();

    if (!med.isTakenToday && mounted) {
      SoundMotionService.instance.showJapaneseNotification(
        context,
        title: 'Medication Taken (服用完了)',
        messageJa: '「${med.nameEn}」を服用しました。お大事に！ (Logged for today. Take care!)',
        iconEmoji: '💊',
        accentColor: AppTheme.matchaTeal,
      );
    }
  }

  Future<void> _deleteMedication(int id) async {
    await DatabaseHelper.instance.deleteMedication(id);
    _loadReminders();
    if (mounted) {
      SoundMotionService.instance.playTapSound();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tablet reminder removed')),
      );
    }
  }

  Future<void> _showAddMedicationModal() async {
    final nameEnCtrl = TextEditingController();
    final nameJaCtrl = TextEditingController();
    final dosageCtrl = TextEditingController(text: '1 tablet');
    final instructionCtrl = TextEditingController(text: 'After meals (食後)');
    TimeOfDay selectedTime = const TimeOfDay(hour: 8, minute: 0);
    String timing = 'Morning (朝)';
    String category = 'prescription';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                      'Add Tablet / Medication (お薬追加)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.inkBlack),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.mutedGrey),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: nameEnCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Medication Name (English)',
                    hintText: 'e.g. Loxonin S / Allergy Antihistamine / Vitamin D',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameJaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Japanese Label (Optional)',
                    hintText: 'e.g. ロキソニンS / アレルギー薬',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: dosageCtrl,
                        decoration: const InputDecoration(labelText: 'Dosage (e.g. 1 tablet, 2錠)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time, size: 16),
                        label: Text(selectedTime.format(context), style: const TextStyle(fontSize: 12)),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModalState(() => selectedTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: instructionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Instructions',
                    hintText: 'e.g. After meals (食後) with water',
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Timing Schedule', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.charcoal)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: ['Morning (朝)', 'Afternoon (昼)', 'Evening (晩)', 'Bedtime (就寝前)', 'As Needed (頓服)'].map((t) {
                    final isSelected = timing == t;
                    return ChoiceChip(
                      label: Text(t),
                      selected: isSelected,
                      selectedColor: AppTheme.inkBlack,
                      backgroundColor: AppTheme.washiCream,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.charcoal,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        if (val) setModalState(() => timing = t);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameEnCtrl.text.trim().isEmpty) return;
                      final timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                      final newMed = MedicationReminder(
                        nameEn: nameEnCtrl.text.trim(),
                        nameJa: nameJaCtrl.text.trim(),
                        dosage: dosageCtrl.text.trim(),
                        timing: timing,
                        scheduledTime: timeStr,
                        instructions: instructionCtrl.text.trim(),
                        category: category,
                      );
                      await DatabaseHelper.instance.insertMedication(newMed);
                      Navigator.pop(ctx);
                      _loadReminders();
                      SoundMotionService.instance.showJapaneseNotification(
                        context,
                        title: 'Reminder Created (リマインダー登録)',
                        messageJa: 'Daily reminder set for $timeStr',
                        iconEmoji: '⏰',
                        accentColor: AppTheme.matchaTeal,
                      );
                    },
                    child: const Text('Save Tablet Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _locateDrugstoreNearMe(String searchTerm) async {
    final query = Uri.encodeComponent(searchTerm);
    final uri = Uri.parse('geo:0,0?q=$query');
    final webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map location')),
        );
      }
    }
  }

  void _showPharmacistCardModal(JapaneseMedicineItem med) {
    SoundMotionService.instance.playTapSound();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.warmBorder, width: 1.5),
        ),
        title: Row(
          children: [
            const Text('💊 ', style: TextStyle(fontSize: 20)),
            Expanded(
              child: Text(
                med.japaneseBrand,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.inkBlack),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.washiCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warmBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SHOW THIS TO PHARMACIST (店員に見せる文章):',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.charcoal, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    med.pharmacistPromptJp,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.inkBlack, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('• Generic: ${med.genericIngredient}', style: const TextStyle(fontSize: 12, color: AppTheme.charcoal)),
            const SizedBox(height: 4),
            Text('• Classification: ${med.otcClassification}', style: TextStyle(fontSize: 11, color: med.otcClassification.contains('Type 1') ? AppTheme.vermilionRed : AppTheme.matchaTeal, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('• Dosage: ${med.dosageNote}', style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey)),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 16, color: AppTheme.charcoal),
            label: const Text('Copy Japanese Text', style: TextStyle(color: AppTheme.charcoal)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: med.pharmacistPromptJp));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Japanese text copied to clipboard!')),
              );
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.washiCream,
      appBar: AppBar(
        title: const Text('Tablet Reminder & Pharmacy (お薬ナビ)'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.inkBlack,
          unselectedLabelColor: AppTheme.mutedGrey,
          indicatorColor: AppTheme.inkBlack,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(icon: Icon(Icons.medication_outlined), text: 'Daily Reminders'),
            Tab(icon: Icon(Icons.local_pharmacy_outlined), text: 'Find in Japan'),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.inkBlack,
              foregroundColor: Colors.white,
              onPressed: _showAddMedicationModal,
              icon: const Icon(Icons.add),
              label: const Text('Add Tablet'),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindersTab(),
          _buildJapanMedicineFinderTab(),
        ],
      ),
    );
  }

  Widget _buildRemindersTab() {
    final takenTodayCount = _reminders.where((m) => m.isTakenToday).length;

    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.inkBlack))
        : RefreshIndicator(
            color: AppTheme.inkBlack,
            onRefresh: _loadReminders,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Top Progress & Status Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.warmBorder, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TODAY\'S MEDICATION SCHEDULE',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$takenTodayCount of ${_reminders.length} tablets taken',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.inkBlack),
                          ),
                          const SizedBox(height: 2),
                          const Text('Stay healthy & consistent in Japan', style: TextStyle(fontSize: 11, color: AppTheme.mutedGrey)),
                        ],
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.matchaTeal.withOpacity(0.12),
                        child: const Text('💊', style: TextStyle(fontSize: 22)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Reminder list
                if (_reminders.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.warmBorder),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.medication_liquid_outlined, size: 48, color: AppTheme.sandAccent),
                        const SizedBox(height: 12),
                        const Text('No tablet reminders scheduled.', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.charcoal)),
                        const SizedBox(height: 6),
                        const Text('Tap "Add Tablet" to set daily pill times with doses and instructions.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _showAddMedicationModal,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add your first pill'),
                        ),
                      ],
                    ),
                  )
                else
                  ..._reminders.map((med) {
                    final isTaken = med.isTakenToday;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isTaken ? AppTheme.matchaTeal : AppTheme.warmBorder,
                          width: isTaken ? 1.5 : 1.0,
                        ),
                      ),
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(
                            isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isTaken ? AppTheme.matchaTeal : AppTheme.mutedGrey,
                            size: 26,
                          ),
                          onPressed: () => _toggleMedicationTaken(med),
                        ),
                        title: Text(
                          med.nameEn,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isTaken ? AppTheme.mutedGrey : AppTheme.inkBlack,
                            decoration: isTaken ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (med.nameJa.isNotEmpty)
                              Text(med.nameJa, style: const TextStyle(fontSize: 11, color: AppTheme.charcoal)),
                            Text(
                              '${med.scheduledTime} • ${med.timing} • ${med.dosage} (${med.instructions})',
                              style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.mutedGrey),
                          onPressed: () {
                            if (med.id != null) _deleteMedication(med.id!);
                          },
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
  }

  Widget _buildJapanMedicineFinderTab() {
    final allMeds = _medService.getJapaneseMedicineDirectory();
    final chains = _medService.getJapaneseDrugstoreChains();
    final phrases = _medService.getPharmacistHelpPhrases();

    final filteredMeds = allMeds.where((m) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return m.commonNameEn.toLowerCase().contains(q) ||
          m.genericIngredient.toLowerCase().contains(q) ||
          m.japaneseBrand.toLowerCase().contains(q) ||
          m.symptoms.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search Bar
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val.trim()),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.charcoal),
            hintText: 'Search symptom or medicine (e.g. headache, ibuprofen, allergy)...',
            hintStyle: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        // Find Drugstores Near Me Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.warmBorder, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'FIND DRUGSTORES NEAR ME (薬局・ドラッグストア)',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal),
                  ),
                  Icon(Icons.near_me, size: 16, color: AppTheme.matchaTeal),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Japanese drugstores (*Kusuriya*) carry pain tablets, stomach medicine, and cold remedies. Tap to search nearby on map:',
                style: TextStyle(fontSize: 12, color: AppTheme.charcoal),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chains.map((c) {
                  return ActionChip(
                    avatar: Text(c.logoEmoji),
                    label: Text(c.nameEn),
                    backgroundColor: AppTheme.washiCream,
                    labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.inkBlack),
                    onPressed: () => _locateDrugstoreNearMe(c.mapSearchTerm),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Japanese Medicines Directory
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'JAPANESE OTC TABLETS DIRECTORY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal),
            ),
            Text('${filteredMeds.length} items', style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey)),
          ],
        ),
        const SizedBox(height: 8),

        ...filteredMeds.map((med) {
          final isType1 = med.otcClassification.contains('Type 1');
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isType1 ? AppTheme.vermilionRed.withOpacity(0.5) : AppTheme.warmBorder),
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
                            med.commonNameEn,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.inkBlack),
                          ),
                          Text(
                            'Japanese Brand: ${med.japaneseBrand}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.charcoal),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        backgroundColor: AppTheme.inkBlack,
                      ),
                      onPressed: () => _showPharmacistCardModal(med),
                      icon: const Icon(Icons.visibility, size: 14),
                      label: const Text('Show Staff', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Symptom: ${med.symptoms}', style: const TextStyle(fontSize: 12, color: AppTheme.charcoal)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isType1 ? AppTheme.vermilionRed.withOpacity(0.12) : AppTheme.matchaTeal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        med.otcClassification.split(' - ').first,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isType1 ? AppTheme.vermilionRed : AppTheme.matchaTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        med.dosageNote,
                        style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 16),

        // Useful Pharmacist Communication Phrases
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.warmBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PHARMACY CONVERSATION FLASHCARDS (薬局での会話)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.charcoal),
              ),
              const SizedBox(height: 10),
              ...phrases.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['title']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.charcoal)),
                        Text(p['jp']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.inkBlack)),
                        Text(p['en']!, style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
