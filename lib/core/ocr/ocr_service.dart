import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class OcrResult {
  final String rawText;
  final List<String> detectedDates;
  final List<String> detectedAmounts;
  final List<String> detectedKeywords;
  final bool isAvailable;
  final String? notice;

  const OcrResult({
    required this.rawText,
    this.detectedDates = const [],
    this.detectedAmounts = const [],
    this.detectedKeywords = const [],
    this.isAvailable = true,
    this.notice,
  });
}

class OcrService {
  static final OcrService instance = OcrService._init();
  OcrService._init();

  // ML Kit recognizer supporting Japanese (Kanji, Hiragana, Katakana) + Latin
  final _recognizer = TextRecognizer(script: TextRecognitionScript.japanese);

  /// Processes image bytes through ML Kit on-device Japanese OCR.
  ///
  /// All processing happens 100% locally — images are never sent to any server.
  /// A temporary file is written to the app cache dir, used for OCR, then deleted.
  Future<OcrResult> processImageBytes(Uint8List imageBytes) async {
    File? tempFile;
    try {
      // Write bytes to a temp file (ML Kit requires a file path)
      final cacheDir = await getTemporaryDirectory();
      tempFile = File(p.join(cacheDir.path, 'aibo_ocr_tmp_${DateTime.now().millisecondsSinceEpoch}.jpg'));
      await tempFile.writeAsBytes(imageBytes);

      final inputImage = InputImage.fromFile(tempFile);
      final recognized = await _recognizer.processImage(inputImage);

      final rawText = recognized.text.trim();
      if (rawText.isEmpty) {
        return const OcrResult(
          rawText: '',
          isAvailable: true,
          notice: 'No text detected in the image. Try a clearer or higher-contrast photo.',
        );
      }

      // --- Post-processing: extract structured fields from raw text ---
      final dates = _extractDates(rawText);
      final amounts = _extractAmounts(rawText);
      final keywords = _extractKeywords(rawText);

      return OcrResult(
        rawText: rawText,
        detectedDates: dates,
        detectedAmounts: amounts,
        detectedKeywords: keywords,
        isAvailable: true,
      );
    } catch (e) {
      debugPrint('[OcrService] ML Kit error: $e');
      return OcrResult(
        rawText: '',
        isAvailable: false,
        notice: 'OCR processing failed: ${e.toString()}',
      );
    } finally {
      // Always clean up temp file — never leave document bytes in cache
      try { await tempFile?.delete(); } catch (_) {}
    }
  }

  /// Dispose ML Kit resources when the service is no longer needed.
  Future<void> dispose() async {
    await _recognizer.close();
  }

  // ---------------------------------------------------------------------------
  // Private helpers — structured field extraction
  // ---------------------------------------------------------------------------

  static final _datePatterns = [
    // Japanese date: 2024年03月15日 / 令和6年3月15日
    RegExp(r'(?:令和|平成|昭和)?\d{1,4}年\s*\d{1,2}月\s*\d{1,2}日'),
    // Western slash date: 2024/03/15 or 2024-03-15
    RegExp(r'\d{4}[/\-]\d{2}[/\-]\d{2}'),
    // Expiry label: 有効期限 / 期限 / 満了日
    RegExp(r'(?:有効期限|満了日|期限)[：:\s]*[\d年月日/\-]+'),
  ];

  static final _amountPatterns = [
    // ¥ amounts: ¥1,234 or ￥1,234 or 1,234円
    RegExp(r'[¥￥]\s*[\d,]+'),
    RegExp(r'[\d,]+\s*円'),
    // Tax: 消費税 or 税込
    RegExp(r'(?:消費税|税込|合計)[：:\s]*[¥￥]?[\d,]+'),
  ];

  static final _keywordPatterns = [
    // Important document types
    RegExp(r'在留カード|在留資格|特別永住者'),
    RegExp(r'健康保険|国民健康保険|保険証'),
    RegExp(r'マイナンバー|個人番号'),
    RegExp(r'住民票|住民基本台帳'),
    RegExp(r'パスポート|旅券'),
    RegExp(r'運転免許|免許証'),
    RegExp(r'納税|確定申告|源泉徴収'),
    RegExp(r'賃貸|家賃|敷金|礼金'),
    // Bill-related
    RegExp(r'請求書|領収書|明細書'),
    RegExp(r'電気|ガス|水道|通信費'),
  ];

  List<String> _extractDates(String text) {
    final results = <String>{};
    for (final pattern in _datePatterns) {
      for (final match in pattern.allMatches(text)) {
        results.add(match.group(0)!.trim());
      }
    }
    return results.toList();
  }

  List<String> _extractAmounts(String text) {
    final results = <String>{};
    for (final pattern in _amountPatterns) {
      for (final match in pattern.allMatches(text)) {
        results.add(match.group(0)!.trim());
      }
    }
    return results.toList();
  }

  List<String> _extractKeywords(String text) {
    final results = <String>{};
    for (final pattern in _keywordPatterns) {
      for (final match in pattern.allMatches(text)) {
        results.add(match.group(0)!.trim());
      }
    }
    return results.toList();
  }
}
