import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/vault/models/document_record.dart';

void main() {
  group('DocumentRecord Model Tests', () {
    test('Serializes to map and deserializes correctly', () {
      final doc = DocumentRecord(
        id: 7,
        title: 'Japan Residence Card (Front)',
        docType: 'residence_card',
        encryptedFilePath: 'doc_1700000000_residence.enc',
        notes: 'Expires: 2027年04月15日 • Status: Engineer/Humanities',
      );

      final map = doc.toMap();
      expect(map['id'], 7);
      expect(map['title'], 'Japan Residence Card (Front)');
      expect(map['doc_type'], 'residence_card');
      expect(map['encrypted_file_path'], 'doc_1700000000_residence.enc');
      expect(map['notes'], 'Expires: 2027年04月15日 • Status: Engineer/Humanities');

      final restored = DocumentRecord.fromMap(map);
      expect(restored.id, 7);
      expect(restored.title, 'Japan Residence Card (Front)');
      expect(restored.docType, 'residence_card');
      expect(restored.encryptedFilePath, 'doc_1700000000_residence.enc');
      expect(restored.notes.contains('2027年'), isTrue);
    });

    test('Handles default values gracefully', () {
      final map = {
        'title': 'Tokyo Gas Utility Bill (10月分)',
        'encrypted_file_path': 'doc_gas_bill.enc',
      };

      final doc = DocumentRecord.fromMap(map);
      expect(doc.title, 'Tokyo Gas Utility Bill (10月分)');
      expect(doc.docType, 'other'); // Default fallback
      expect(doc.notes, '');
    });
  });
}
