import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/core/ocr/document_understanding_service.dart';
import 'package:aibo/core/ocr/structured_document_model.dart';

void main() {
  group('DocumentUnderstandingService Tests', () {
    final service = DocumentUnderstandingService.instance;

    test('Classifies and extracts Japanese Residence Card (在留カード)', () {
      const sampleOcrText = '''
        在留カード RESIDENCE CARD
        番号 AB12345678CD
        氏名 TESTER ARJUN
        在留資格: 技術・人文知識・国際業務
        在留期間の満了の日: 令和9年4月15日
      ''';

      final doc = service.parseJapaneseDocumentText(text: sampleOcrText);

      expect(doc.docType, JapaneseDocumentType.residenceCard);
      expect(doc.documentIdentifier, 'AB12345678CD');
      expect(doc.dueOrExpiryDate, isNotNull);
      expect(doc.dueOrExpiryDate!.year, 2027); // Reiwa 9 = 2027
      expect(doc.dueOrExpiryDate!.month, 4);
      expect(doc.dueOrExpiryDate!.day, 15);
      expect(doc.keyInstructionsEn.contains('Renewal application opens 3 months prior'), isTrue);
    });

    test('Classifies and extracts Japanese Electricity Bill (TEPCO)', () {
      const sampleOcrText = '''
        東京電力エナジーパートナー株式会社
        電気ご使用量のお知らせ・請求書
        ご請求予定金額: ¥4,500
        支払期日: 2026年11月25日
        バーコード コンビニエンスストアでお支払いいただけます
      ''';

      final doc = service.parseJapaneseDocumentText(text: sampleOcrText);

      expect(doc.docType, JapaneseDocumentType.utilityElectricity);
      expect(doc.issuerOrProvider.contains('TEPCO'), isTrue);
      expect(doc.amountJpy, 4500.0);
      expect(doc.dueOrExpiryDate, isNotNull);
      expect(doc.dueOrExpiryDate!.year, 2026);
      expect(doc.dueOrExpiryDate!.month, 11);
      expect(doc.dueOrExpiryDate!.day, 25);
      expect(doc.isPayableAtKonbini, isTrue);
      expect(doc.paymentStatus, 'pending');
    });

    test('Classifies and extracts Tokyo Metropolitan Water Bill', () {
      const sampleOcrText = '''
        東京都水道局 水道料金・下水道料金納入通知書
        請求金額 3,200円
        納入期限 令和8年12月10日
      ''';

      final doc = service.parseJapaneseDocumentText(text: sampleOcrText);

      expect(doc.docType, JapaneseDocumentType.utilityWater);
      expect(doc.amountJpy, 3200.0);
      expect(doc.dueOrExpiryDate!.year, 2026); // Reiwa 8 = 2026
      expect(doc.dueOrExpiryDate!.month, 12);
      expect(doc.dueOrExpiryDate!.day, 10);
    });

    test('Classifies and extracts Konbini Store Receipt', () {
      const sampleOcrText = '''
        セブン-イレブン 新宿東口店
        領収証 レシート
        おにぎり  ¥150
        緑茶      ¥160
        合計      ¥310
        内消費税   ¥22
        お預り    ¥1,000
        お釣り    ¥690
        2026/10/25
      ''';

      final doc = service.parseJapaneseDocumentText(text: sampleOcrText);

      expect(doc.docType, JapaneseDocumentType.receipt);
      expect(doc.paymentStatus, 'paid');
      expect(doc.amountJpy, isNotNull);
    });
  });
}
