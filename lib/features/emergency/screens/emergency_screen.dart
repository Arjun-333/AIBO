import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../models/emergency_card.dart';

class EmergencyScreen extends StatefulWidget {
  final bool isQuickAccess;

  const EmergencyScreen({super.key, this.isQuickAccess = false});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EmergencyCard? _card;
  bool _isLoading = true;

  final List<Map<String, String>> _emergencyPhrases = [
    {
      'kanji': '助けてください！',
      'furigana': 'たすけてください',
      'romaji': 'Tasukete kudasai!',
      'english': 'Please help me!',
      'audioHint': 'Ta-soo-keh-teh koo-dah-sai',
    },
    {
      'kanji': '救急車を呼んでください。',
      'furigana': 'きゅうきゅうしゃ を よんでください',
      'romaji': 'Kyuukyuusha o yonde kudasai.',
      'english': 'Please call an ambulance.',
      'audioHint': 'Kyoo-kyoo-shah oh yon-deh koo-dah-sai',
    },
    {
      'kanji': '警察を呼んでください。',
      'furigana': 'けいさつ を よんでください',
      'romaji': 'Keisatsu o yonde kudasai.',
      'english': 'Please call the police.',
      'audioHint': 'Kay-saht-soo oh yon-deh koo-dah-sai',
    },
    {
      'kanji': '日本語がわかりません。',
      'furigana': 'にほんご が わかりません',
      'romaji': 'Nihongo ga wakarimasen.',
      'english': "I don't understand Japanese.",
      'audioHint': 'Nee-hon-goh gah wah-kah-ree-mah-sen',
    },
    {
      'kanji': '病院に連れて行ってください。',
      'furigana': 'びょういん に つれていってください',
      'romaji': 'Byouin ni tsureteitte kudasai.',
      'english': 'Please take me to a hospital.',
      'audioHint': 'Byoh-in nee tsoo-reh-tay-eet-tay koo-dah-sai',
    },
    {
      'kanji': 'アレルギーがあります。',
      'furigana': 'あれるぎー が あります',
      'romaji': 'Arerugii ga arimasu.',
      'english': 'I have an allergy.',
      'audioHint': 'Ah-reh-roo-gee gah ah-ree-mah-soo',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEmergencyCard();
  }

  Future<void> _loadEmergencyCard() async {
    final card = await DatabaseHelper.instance.getEmergencyCard();
    setState(() {
      _card = card;
      _isLoading = false;
    });
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open dialer for $phoneNumber')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emergency, color: AppTheme.accentRose, size: 24),
            const SizedBox(width: 8),
            Text(widget.isQuickAccess ? 'EMERGENCY / 緊急' : 'Emergency Center'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentRose,
          labelColor: AppTheme.accentRose,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.phone_in_talk), text: 'Dial 110/119'),
            Tab(icon: Icon(Icons.translate), text: 'Phrases'),
            Tab(icon: Icon(Icons.badge), text: 'Medical Card'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDialerTab(),
                _buildPhrasesTab(),
                _buildMedicalCardTab(),
              ],
            ),
    );
  }

  Widget _buildDialerTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildEmergencyBanner(),
        const SizedBox(height: 20),
        _buildDialCard(
          number: '110',
          title: 'Police / 警察 (Keisatsu)',
          description: 'Accidents, crime, theft, immediate danger',
          color: Colors.blueAccent,
          icon: Icons.local_police,
        ),
        const SizedBox(height: 12),
        _buildDialCard(
          number: '119',
          title: 'Ambulance & Fire / 救急・消防',
          description: 'Medical emergency, severe illness, fire',
          color: AppTheme.accentRose,
          icon: Icons.medical_services,
        ),
        const SizedBox(height: 12),
        _buildDialCard(
          number: '#7119',
          title: 'Emergency Medical Consultation',
          description: 'Non-life-threatening advice (Tokyo/major cities)',
          color: Colors.amber.shade700,
          icon: Icons.help_outline,
        ),
        if (_card?.emergencyContactPhone.isNotEmpty ?? false) ...[
          const SizedBox(height: 24),
          const Text(
            'PERSONAL EMERGENCY CONTACT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          _buildDialCard(
            number: _card!.emergencyContactPhone,
            title: _card!.emergencyContactName.isNotEmpty
                ? _card!.emergencyContactName
                : 'Primary Emergency Contact',
            description: 'Your saved personal contact',
            color: AppTheme.accentTeal,
            icon: Icons.person_pin,
          ),
        ],
      ],
    );
  }

  Widget _buildEmergencyBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentRose.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentRose.withOpacity(0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.accentRose, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tap any card to immediately launch your phone dialer. Works 100% offline.',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialCard({
    required String number,
    required String title,
    required String description,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: InkWell(
        onTap: () => _makeCall(number),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhrasesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _emergencyPhrases.length,
      itemBuilder: (context, index) {
        final phrase = _emergencyPhrases[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phrase['kanji']!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phrase['furigana']!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.accentTeal,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        phrase['english']!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Text(
                      phrase['audioHint']!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white38,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicalCardTab() {
    if (_card == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentRose.withOpacity(0.5), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EMERGENCY MEDICAL CARD',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppTheme.accentRose,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentRose,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'BLOOD: ${_card!.bloodType}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Colors.white24),
              _buildInfoRow('Full Name', _card!.fullName),
              _buildInfoRow('Emergency Contact', '${_card!.emergencyContactName} (${_card!.emergencyContactPhone})'),
              _buildInfoRow('Allergies', _card!.allergies),
              _buildInfoRow('Medical Notes', _card!.medicalNotes.isNotEmpty ? _card!.medicalNotes : 'None specified'),
              if (_card!.residenceCardNumber.isNotEmpty)
                _buildInfoRow('Residence Card #', _card!.residenceCardNumber),
              if (_card!.insuranceNumber.isNotEmpty)
                _buildInfoRow('Insurance Card #', _card!.insuranceNumber),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _showEditCardDialog,
          icon: const Icon(Icons.edit),
          label: const Text('Edit Emergency Card Information'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            value.isNotEmpty ? value : '—',
            style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showEditCardDialog() {
    final nameCtrl = TextEditingController(text: _card?.fullName);
    final bloodCtrl = TextEditingController(text: _card?.bloodType);
    final contactNameCtrl = TextEditingController(text: _card?.emergencyContactName);
    final contactPhoneCtrl = TextEditingController(text: _card?.emergencyContactPhone);
    final allergiesCtrl = TextEditingController(text: _card?.allergies);
    final notesCtrl = TextEditingController(text: _card?.medicalNotes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Edit Emergency Info', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 8),
              TextField(controller: bloodCtrl, decoration: const InputDecoration(labelText: 'Blood Type (e.g. O+, A-)')),
              const SizedBox(height: 8),
              TextField(controller: contactNameCtrl, decoration: const InputDecoration(labelText: 'Emergency Contact Name')),
              const SizedBox(height: 8),
              TextField(controller: contactPhoneCtrl, decoration: const InputDecoration(labelText: 'Emergency Contact Phone')),
              const SizedBox(height: 8),
              TextField(controller: allergiesCtrl, decoration: const InputDecoration(labelText: 'Allergies')),
              const SizedBox(height: 8),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Medical Notes / Conditions')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final updated = _card!.copyWith(
                fullName: nameCtrl.text,
                bloodType: bloodCtrl.text,
                emergencyContactName: contactNameCtrl.text,
                emergencyContactPhone: contactPhoneCtrl.text,
                allergies: allergiesCtrl.text,
                medicalNotes: notesCtrl.text,
              );
              await DatabaseHelper.instance.updateEmergencyCard(updated);
              Navigator.pop(ctx);
              _loadEmergencyCard();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
