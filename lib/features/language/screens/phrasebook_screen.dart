import 'package:flutter/material.dart';
import '../../../core/llm/llm_service.dart';
import '../../../core/theme/app_theme.dart';
import '../data/phrase_data.dart';

class PhrasebookScreen extends StatefulWidget {
  const PhrasebookScreen({super.key});

  @override
  State<PhrasebookScreen> createState() => _PhrasebookScreenState();
}

class _PhrasebookScreenState extends State<PhrasebookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  // AI Translation tool state
  final TextEditingController _translateInputCtrl = TextEditingController();
  String _translationResult = '';
  bool _isTranslating = false;

  final List<String> _categories = [
    'All',
    'Transit',
    'Konbini',
    'Ward Office',
    'Dining',
    'Medical',
    'Garbage',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  List<JapanesePhrase> get _filteredPhrases {
    return PhraseData.phrases.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          p.japanese.contains(q) ||
          p.furigana.contains(q) ||
          p.romaji.toLowerCase().contains(q) ||
          p.english.toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _performAiTranslation() async {
    final query = _translateInputCtrl.text.trim();
    if (query.isEmpty || _isTranslating) return;

    setState(() {
      _isTranslating = true;
      _translationResult = '';
    });

    try {
      final prompt = '''
Please translate the following to natural Japanese for someone living in Japan:
"$query"

Format your response exactly as:
1. Japanese (Kanji / Kana): [Natural Japanese translation]
2. Furigana reading: [Hiragana reading]
3. Romaji: [Romaji pronunciation]
4. Politeness note: [When to use this phrase / politeness level]
''';

      final reply = await LlmService.instance.sendMessage(prompt: prompt);
      setState(() {
        _translationResult = reply;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() {
        _translationResult = 'Translation error: ${e.toString().replaceAll("Exception: ", "")}';
        _isTranslating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Japanese Language Helper'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentTeal,
          labelColor: AppTheme.accentTeal,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_outlined), text: 'Offline Phrases'),
            Tab(icon: Icon(Icons.auto_awesome), text: 'AI Translation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOfflinePhraseTab(),
          _buildAiTranslationTab(),
        ],
      ),
    );
  }

  Widget _buildOfflinePhraseTab() {
    final phrases = _filteredPhrases;

    return Column(
      children: [
        // Offline Status Badge & Search
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search English, Romaji, or Kanji...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      backgroundColor: AppTheme.surfaceDark,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedCategory = cat);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Phrases List
        Expanded(
          child: phrases.isEmpty
              ? Center(
                  child: Text(
                    'No phrases match "$_searchQuery"',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: phrases.length,
                  itemBuilder: (context, index) {
                    final item = phrases[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentTeal.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.category.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentTeal),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.japanese,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.furigana,
                              style: const TextStyle(fontSize: 13, color: AppTheme.accentTeal),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.romaji,
                              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6), fontStyle: FontStyle.italic),
                            ),
                            const Divider(height: 18, color: Colors.white12),
                            Text(
                              item.english,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                            if (item.contextTip.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.tips_and_updates_outlined, size: 14, color: Colors.amber),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item.contextTip,
                                      style: const TextStyle(fontSize: 12, color: Colors.white60),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAiTranslationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.bolt, color: AppTheme.primary, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Powered by your connected Gemini / NVIDIA Nemotron AI. Provides furigana readings and politeness context.',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _translateInputCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter English sentence to translate to polite Japanese...',
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _isTranslating ? null : _performAiTranslation,
          icon: _isTranslating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.translate),
          label: Text(_isTranslating ? 'Translating...' : 'Translate to Japanese'),
        ),
        const SizedBox(height: 20),
        if (_translationResult.isNotEmpty) ...[
          const Text(
            'TRANSLATION RESULT',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentTeal.withOpacity(0.4)),
            ),
            child: SelectableText(
              _translationResult,
              style: const TextStyle(fontSize: 14.5, height: 1.5, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }
}
