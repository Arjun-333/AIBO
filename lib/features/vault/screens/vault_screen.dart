import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/ocr/ocr_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/vault/vault_service.dart';
import '../models/document_record.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  List<DocumentRecord> _documents = [];
  String _selectedCategory = 'all';
  bool _isLoading = true;

  final Map<String, String> _categoryLabels = {
    'all': 'All Docs',
    'residence_card': 'Residence Card',
    'passport': 'Passport',
    'insurance': 'Health Insurance',
    'bills': 'Bills & Taxes',
    'lease': 'Lease / Housing',
    'other': 'Other',
  };

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final docs = await DatabaseHelper.instance.getDocuments(
      docType: _selectedCategory == 'all' ? null : _selectedCategory,
    );
    if (mounted) {
      setState(() {
        _documents = docs;
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddDocumentDialog() async {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String docType = 'residence_card';
    bool isOcrProcessing = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            title: const Text('Store Encrypted Document', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Document Title (e.g. My Residence Card)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: docType,
                    decoration: const InputDecoration(labelText: 'Category'),
                    dropdownColor: AppTheme.surfaceDark,
                    items: _categoryLabels.entries
                        .where((e) => e.key != 'all')
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => docType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Notes / Extracted OCR Data'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: isOcrProcessing
                        ? null
                        : () async {
                            setDialogState(() => isOcrProcessing = true);
                            // Simulate scanning document bytes locally
                            final fakeBytes = Uint8List(100);
                            final result = await OcrService.instance.processImageBytes(fakeBytes);
                            setDialogState(() {
                              isOcrProcessing = false;
                              final buffer = StringBuffer(notesCtrl.text);
                              if (result.detectedDates.isNotEmpty) {
                                buffer.writeln('📅 Due/Expiry: ${result.detectedDates.join(", ")}');
                              }
                              if (result.detectedAmounts.isNotEmpty) {
                                buffer.writeln('💰 Amount: ${result.detectedAmounts.join(", ")}');
                              }
                              if (result.detectedKeywords.isNotEmpty) {
                                buffer.writeln('🏷️ Keywords: ${result.detectedKeywords.join(", ")}');
                              }
                              notesCtrl.text = buffer.toString().trim();
                            });
                          },
                    icon: isOcrProcessing
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.document_scanner, size: 18),
                    label: Text(isOcrProcessing ? 'Reading Japanese Text...' : 'Scan / Extract Text (On-Device OCR)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.trim().isNotEmpty) {
                    // Encrypt file bytes locally
                    final fakeImage = Uint8List.fromList(List.generate(256, (i) => i % 256));
                    final encFileName = await VaultService.instance.saveEncryptedDocument(
                      imageBytes: fakeImage,
                      originalFileName: '${titleCtrl.text.trim()}.jpg',
                    );

                    final doc = DocumentRecord(
                      title: titleCtrl.text.trim(),
                      docType: docType,
                      encryptedFilePath: encFileName,
                      notes: notesCtrl.text.trim(),
                    );

                    await DatabaseHelper.instance.insertDocument(doc);
                    Navigator.pop(ctx);
                    _loadDocuments();
                  }
                },
                child: const Text('Encrypt & Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _viewDocumentDetails(DocumentRecord doc) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text(doc.title, style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _categoryLabels[doc.docType] ?? doc.docType,
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.surfaceLightDark),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: AppTheme.accentTeal, size: 36),
                  SizedBox(height: 6),
                  Text(
                    'AES-256 Encrypted on Device',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (doc.notes.isNotEmpty) ...[
              const Text('NOTES & EXTRACTED DATA:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white54)),
              const SizedBox(height: 4),
              Text(doc.notes, style: const TextStyle(fontSize: 13, height: 1.4)),
            ],
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.accentRose),
            onPressed: () async {
              if (doc.id != null) {
                await VaultService.instance.deleteEncryptedDocument(doc.encryptedFilePath);
                await DatabaseHelper.instance.deleteDocument(doc.id!);
                Navigator.pop(ctx);
                _loadDocuments();
              }
            },
            child: const Text('Delete Document'),
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
      appBar: AppBar(
        title: const Text('Document Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            tooltip: 'Add Document',
            onPressed: _showAddDocumentDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Security Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surfaceDark,
            child: const Row(
              children: [
                Icon(Icons.security, color: AppTheme.accentTeal, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '100% Offline & AES-256 Encrypted. Never sent to cloud.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),

          // Category Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categoryLabels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final entry = _categoryLabels.entries.elementAt(idx);
                final isSelected = _selectedCategory == entry.key;
                return ChoiceChip(
                  label: Text(entry.value, style: const TextStyle(fontSize: 11)),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.surfaceDark,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = entry.key);
                      _loadDocuments();
                    }
                  },
                );
              },
            ),
          ),

          // Documents List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _documents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.folder_special_outlined, size: 48, color: Colors.white24),
                            const SizedBox(height: 12),
                            const Text('No documents stored yet', style: TextStyle(color: Colors.white54)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _showAddDocumentDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Store Document'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _documents.length,
                        itemBuilder: (context, index) {
                          final doc = _documents[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.file_present_outlined, color: AppTheme.primary),
                              ),
                              title: Text(doc.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${_categoryLabels[doc.docType] ?? doc.docType} • ${doc.notes.isNotEmpty ? doc.notes : 'No notes'}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Colors.white54),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                              onTap: () => _viewDocumentDetails(doc),
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
