import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'ocr_service.dart';
import 'structured_document_model.dart';

/// DocumentUnderstandingService — Converts raw Japanese OCR text into
/// actionable, structured Life OS entities with due dates, payment statuses,
/// and practical procedural guidance.
class DocumentUnderstandingService {
  static final DocumentUnderstandingService instance = DocumentUnderstandingService._init();
  DocumentUnderstandingService._init();

  /// Analyzes an image through ML Kit OCR and extracts structured Japanese entities.
  Future<StructuredDocument> analyzeDocumentImage({
    required Uint8List imageBytes,
    int? vaultDocId,
    String? fallbackTitle,
  }) async {
    final ocrResult = await OcrService.instance.processImageBytes(imageBytes);
    final text = ocrResult.rawText;

    if (text.isEmpty) {
      return StructuredDocument(
        vaultDocId: vaultDocId,
        docType: JapaneseDocumentType.generalNotice,
        title: fallbackTitle ?? 'Unrecognized Document',
        issuerOrProvider: 'Unknown',
        rawExtractedText: ocrResult.notice ?? 'No text detected',
        keyInstructionsEn: 'No text was found. Please ensure good lighting and clear camera focus.',
      );
    }

    return parseJapaneseDocumentText(
      text: text,
      vaultDocId: vaultDocId,
      fallbackTitle: fallbackTitle,
    );
  }

  /// Parses raw Japanese text into a structured document model
  StructuredDocument parseJapaneseDocumentText({
    required String text,
    int? vaultDocId,
    String? fallbackTitle,
  }) {
    // 1. Detect Residence Card (在留カード)
    if (_isResidenceCard(text)) {
      return _parseResidenceCard(text, vaultDocId, fallbackTitle);
    }

    // 2. Detect Electricity Bill (電気料金)
    if (_isElectricityBill(text)) {
      return _parseElectricityBill(text, vaultDocId, fallbackTitle);
    }

    // 3. Detect Gas Bill (ガス料金)
    if (_isGasBill(text)) {
      return _parseGasBill(text, vaultDocId, fallbackTitle);
    }

    // 4. Detect Water Bill (水道料金)
    if (_isWaterBill(text)) {
      return _parseWaterBill(text, vaultDocId, fallbackTitle);
    }

    // 5. Detect Tax / Municipal Slip (住民税・納入通知書)
    if (_isTaxSlip(text)) {
      return _parseTaxSlip(text, vaultDocId, fallbackTitle);
    }

    // 6. Detect Konbini / Store Receipt (レシート・領収書)
    if (_isReceipt(text)) {
      return _parseReceipt(text, vaultDocId, fallbackTitle);
    }

    // 7. Fallback: General Document Notice
    return _parseGeneralNotice(text, vaultDocId, fallbackTitle);
  }

  // ---------------------------------------------------------------------------
  // Classification Heuristics
  // ---------------------------------------------------------------------------

  bool _isResidenceCard(String text) {
    return text.contains('在留カード') ||
        text.contains('RESIDENCE CARD') ||
        (text.contains('在留資格') && text.contains('在留期間'));
  }

  bool _isElectricityBill(String text) {
    return text.contains('東京電力') ||
        text.contains('TEPCO') ||
        text.contains('電気ご使用量') ||
        text.contains('電気料金') ||
        text.contains('でんき');
  }

  bool _isGasBill(String text) {
    return text.contains('東京ガス') ||
        text.contains('TOKYO GAS') ||
        text.contains('ガスご使用量') ||
        text.contains('ガス料金');
  }

  bool _isWaterBill(String text) {
    return text.contains('水道局') ||
        text.contains('水道料金') ||
        text.contains('下水道料金') ||
        text.contains('水栓番号');
  }

  bool _isTaxSlip(String text) {
    return text.contains('区民税') ||
        text.contains('市民税') ||
        text.contains('都民税') ||
        text.contains('納入通知書') ||
        text.contains('納付書') ||
        text.contains('国民健康保険料') ||
        text.contains('国民年金');
  }

  bool _isReceipt(String text) {
    return text.contains('領収証') ||
        text.contains('レシート') ||
        (text.contains('合計') && (text.contains('内消費税') || text.contains('お預り')));
  }

  // ---------------------------------------------------------------------------
  // Parsers by Document Domain
  // ---------------------------------------------------------------------------

  StructuredDocument _parseResidenceCard(String text, int? vaultDocId, String? fallbackTitle) {
    DateTime? expiryDate = _extractFirstJapaneseDate(text, [
      RegExp(r'(?:在留期間の満了の日|満了日|有効期限|Expires)[\s:：]*((?:令和|平成)?\d{1,4}年\s*\d{1,2}月\s*\d{1,2}日)'),
      RegExp(r'(?:令和|平成)\s*\d{1,2}年\s*\d{1,2}月\s*\d{1,2}日'),
    ]);

    // Extract Status of Residence
    String status = 'Engineer / Specialist in Humanities / Work';
    final statusMatch = RegExp(r'在留資格[\s:：]*([^\n\r]+)').firstMatch(text);
    if (statusMatch != null) {
      status = statusMatch.group(1)!.trim();
    }

    // Extract Card Number (e.g. AB12345678CD)
    String? cardNum;
    final cardMatch = RegExp(r'[A-Z]{2}\d{8}[A-Z]{2}').firstMatch(text);
    if (cardMatch != null) {
      cardNum = cardMatch.group(0);
    }

    return StructuredDocument(
      vaultDocId: vaultDocId,
      docType: JapaneseDocumentType.residenceCard,
      title: fallbackTitle ?? 'Japan Residence Card (在留カード)',
      issuerOrProvider: 'Immigration Services Agency of Japan (出入国在留管理庁)',
      dueOrExpiryDate: expiryDate,
      documentIdentifier: cardNum,
      keyInstructionsJa: '在留期間更新の申請は、満了日の3ヶ月前から出入国在留管理局で手続き可能です。',
      keyInstructionsEn: 'Renewal application opens 3 months prior to expiration. Visit the Tokyo Regional Immigration Bureau (Shinagawa).',
      rawExtractedText: text,
      paymentStatus: 'not_applicable',
    );
  }

  StructuredDocument _parseElectricityBill(String text, int? vaultDocId, String? fallbackTitle) {
    final amount = _extractHighestYenAmount(text);
    final dueDate = _extractFirstJapaneseDate(text, [
      RegExp(r'(?:支払期日|納入期日|お支払い期日|期限)[\s:：]*((?:令和|平成)?\d{1,4}年\s*\d{1,2}月\s*\d{1,2}日)'),
      RegExp(r'\d{4}[/\-]\d{2}[/\-]\d{2}'),
    ]);
    final hasBarcode = text.contains('コンビニ') || text.contains('取扱窓口') || text.contains('バーコード');

    return StructuredDocument(
      vaultDocId: vaultDocId,
      docType: JapaneseDocumentType.utilityElectricity,
      title: fallbackTitle ?? 'Electricity Bill (電気料金)',
      issuerOrProvider: text.contains('東京電力') || text.contains('TEPCO') ? 'TEPCO (東京電力)' : 'Electric Power Utility',
      amountJpy: amount,
      dueOrExpiryDate: dueDate,
      isPayableAtKonbini: hasBarcode,
      paymentStatus: 'pending',
      keyInstructionsJa: 'コンビニのレジにバーコード付き納付書を持参して現金で支払えます。',
      keyInstructionsEn: 'Payable at convenience stores (7-Eleven, Lawson, FamilyMart) before due date using cash.',
      rawExtractedText: text,
    );
  }

  StructuredDocument _parseGasBill(String text, int? vaultDocId, String? fallbackTitle) {
    final amount = _extractHighestYenAmount(text);
    final dueDate = _extractFirstJapaneseDate(text, [
      RegExp(r'(?:払込期日|支払期日|納入期限)[\s:：]*((?:令和|平成)?\d{1,4}年\s*\d{1,2}月\s*\d{1,2}日)'),
    ]);

    return StructuredDocument(
      vaultDocId: vaultDocId,
      docType: JapaneseDocumentType.utilityGas,
      title: fallbackTitle ?? 'City Gas Bill (ガス料金)',
      issuerOrProvider: text.contains('東京ガス') ? 'Tokyo Gas (東京ガス)' : 'Gas Utility Provider',
      amountJpy: amount,
      dueOrExpiryDate: dueDate,
      isPayableAtKonbini: true,
      paymentStatus: 'pending',
      keyInstructionsJa: '期限内にコンビニまたは銀行窓口でお支払いください。',
      keyInstructionsEn: 'Pay at convenience store cash registers or bank counter before the deadline.',
      rawExtractedText: text,
    );
  }

  StructuredDocument _parseWaterBill(String text, int? vaultDocId, String? fallbackTitle) {
    final amount = _extractHighestYenAmount(text);
    final dueDate = _extractFirstJapaneseDate(text, [
      RegExp(r'(?:納入期限|納入期日|お支払期日)[\s:：]*((?:令和|平成)?\d{1,4}年\s*\d{1,2}月\s*\d{1,2}日)'),
    ]);

    return StructuredDocument(
      vaultDocId: vaultDocId,
      docType: JapaneseDocumentType.utilityWater,
      title: fallbackTitle ?? 'Water & Sewerage Bill (水道料金)',
      issuerOrProvider: 'Tokyo Metropolitan Bureau of Waterworks (東京都水道局)',
      amountJpy: amount,
      dueOrExpiryDate: dueDate,
      isPayableAtKonbini: true,
      paymentStatus: 'pending',
      keyInstructionsJa: '水道料金は通常2ヶ月に1回請求されます。コンビニで支払可能です。',
      keyInstructionsEn: 'Billed bi-monthly in Tokyo. Present barcode slip at any konbini cashier to pay in cash.',
      rawExtractedText: text,
    );
  }

  StructuredDocument _parseTaxSlip(String text, int? vaultDocId, String? fallbackTitle) {
    final amount = _extractHighestYenAmount(text);
    final dueDate = _extractFirstJapaneseDate(text, [
      RegExp(r'(?:納期限|納入期限)[\s:：]*((?:令和|平成)?\d{1,4}年\s*\d{1,2}月\s*\d{1,2}日)'),
    ]);

    return StructuredDocument(
      vaultDocId: vaultDocId,
      docType: JapaneseDocumentType.taxSlip,
      title: fallbackTitle ?? 'Residence Tax Notice (住民税・納付書)',
      issuerOrProvider: 'Municipal Ward Office (区役所・税務課)',
      amountJpy: amount,
      dueOrExpiryDate: dueDate,
      isPayableAtKonbini: true,
      paymentStatus: 'pending',
      keyInstructionsJa: '納期限を過ぎると延滞金が発生する場合があります。コンビニ・銀行・郵便局で納付できます。',
      keyInstructionsEn: 'Pay promptly to avoid late penalties. Payable at konbini, post offices (Japan Post Bank), or municipal counters.',
      rawExtractedText: text,
    );
  }

  StructuredDocument _parseReceipt(String text, int? vaultDocId, String? fallbackTitle) {
    final amount = _extractHighestYenAmount(text);
    final date = _extractFirstJapaneseDate(text, [
      RegExp(r'\d{4}[/\-年]\s*\d{1,2}[/\-月]\s*\d{1,2}日?'),
    ]);

    return StructuredDocument(
      vaultDocId: vaultDocId,
      docType: JapaneseDocumentType.receipt,
      title: fallbackTitle ?? 'Store Receipt (レシート)',
      issuerOrProvider: 'Store / Merchant',
      amountJpy: amount,
      dueOrExpiryDate: date,
      paymentStatus: 'paid',
      keyInstructionsEn: 'Logged purchase. Can be filed for household expense tracking or annual tax return (確定申告).',
      rawExtractedText: text,
    );
  }

  StructuredDocument _parseGeneralNotice(String text, int? vaultDocId, String? fallbackTitle) {
    final amount = _extractHighestYenAmount(text);
    final date = _extractFirstJapaneseDate(text, [
      RegExp(r'(?:令和|平成)?\d{1,4}年\s*\d{1,2}月\s*\d{1,2}日'),
      RegExp(r'\d{4}[/\-]\d{2}[/\-]\d{2}'),
    ]);

    return StructuredDocument(
      vaultDocId: vaultDocId,
      docType: JapaneseDocumentType.generalNotice,
      title: fallbackTitle ?? 'Official Notice / Document',
      issuerOrProvider: 'Public Agency / Ward Office',
      amountJpy: amount,
      dueOrExpiryDate: date,
      rawExtractedText: text,
      keyInstructionsEn: 'Review extracted text. Save to vault for offline reference.',
    );
  }

  // ---------------------------------------------------------------------------
  // Date & Currency Extraction Helpers (100% Deterministic Regex)
  // ---------------------------------------------------------------------------

  double? _extractHighestYenAmount(String text) {
    final matches = <double>[];

    // Pattern 1: ¥ 4,500 / ￥4,500
    final yenRegex = RegExp(r'[¥￥]\s*([\d,]+)');
    for (final m in yenRegex.allMatches(text)) {
      final clean = m.group(1)!.replaceAll(',', '');
      final parsed = double.tryParse(clean);
      if (parsed != null && parsed > 50 && parsed < 2000000) {
        matches.add(parsed);
      }
    }

    // Pattern 2: 4,500円
    final enRegex = RegExp(r'([\d,]+)\s*円');
    for (final m in enRegex.allMatches(text)) {
      final clean = m.group(1)!.replaceAll(',', '');
      final parsed = double.tryParse(clean);
      if (parsed != null && parsed > 50 && parsed < 2000000) {
        matches.add(parsed);
      }
    }

    if (matches.isEmpty) return null;
    matches.sort();
    return matches.last; // Highest amount typically corresponds to total bill/tax
  }

  DateTime? _extractFirstJapaneseDate(String text, List<RegExp> patterns) {
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final rawDateStr = match.group(1) ?? match.group(0)!;
        final converted = _parseJapaneseDateString(rawDateStr);
        if (converted != null) return converted;
      }
    }
    return null;
  }

  DateTime? _parseJapaneseDateString(String str) {
    try {
      // Reiwa conversion: 令和6年 -> 2024 (2018 + 6)
      if (str.contains('令和')) {
        final reiwaMatch = RegExp(r'令和\s*(\d{1,2}|元)年\s*(\d{1,2})月\s*(\d{1,2})日').firstMatch(str);
        if (reiwaMatch != null) {
          final yearNum = reiwaMatch.group(1) == '元' ? 1 : int.parse(reiwaMatch.group(1)!);
          final year = 2018 + yearNum;
          final month = int.parse(reiwaMatch.group(2)!);
          final day = int.parse(reiwaMatch.group(3)!);
          return DateTime(year, month, day);
        }
      }

      // Western date with Kanji: 2026年11月25日
      final kanjiMatch = RegExp(r'(\d{4})年\s*(\d{1,2})月\s*(\d{1,2})日').firstMatch(str);
      if (kanjiMatch != null) {
        return DateTime(
          int.parse(kanjiMatch.group(1)!),
          int.parse(kanjiMatch.group(2)!),
          int.parse(kanjiMatch.group(3)!),
        );
      }

      // Slash/hyphen format: 2026/11/25 or 2026-11-25
      final westernMatch = RegExp(r'(\d{4})[/\-](\d{1,2})[/\-](\d{1,2})').firstMatch(str);
      if (westernMatch != null) {
        return DateTime(
          int.parse(westernMatch.group(1)!),
          int.parse(westernMatch.group(2)!),
          int.parse(westernMatch.group(3)!),
        );
      }
    } catch (_) {}
    return null;
  }
}
