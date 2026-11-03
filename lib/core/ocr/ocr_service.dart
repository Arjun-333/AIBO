import 'dart:typed_data';

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

  /// Runs OCR when a real platform OCR adapter is available.
  ///
  /// This checkout does not bundle a camera or ML Kit adapter. Returning an
  /// unavailable result is intentional: sample text must never be presented as
  /// text extracted from the user's document.
  Future<OcrResult> processImageBytes(Uint8List imageBytes) async {
    return const OcrResult(
      rawText: '',
      isAvailable: false,
      notice: 'On-device OCR is unavailable until the camera and ML Kit adapter are installed.',
    );
  }
}
