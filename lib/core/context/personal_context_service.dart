import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import 'personal_context_model.dart';

/// PersonalContextService — Central orchestrator of user life context in Japan.
///
/// Converts AIBO from a generic conversational chatbot into a personal,
/// context-aware operating system that understands the user's residence ward,
/// daily commute, visa timeline, and Japanese language proficiency.
class PersonalContextService {
  static final PersonalContextService instance = PersonalContextService._init();
  PersonalContextService._init();

  PersonalContext? _cachedContext;

  /// Returns the loaded or default personal context
  Future<PersonalContext> getContext() async {
    if (_cachedContext != null) return _cachedContext!;
    _cachedContext = await DatabaseHelper.instance.getPersonalContext();
    return _cachedContext!;
  }

  /// Updates personal context in SQLite and refreshes memory cache
  Future<void> updateContext(PersonalContext context) async {
    await DatabaseHelper.instance.savePersonalContext(context);
    _cachedContext = context;
    debugPrint('[PersonalContextService] Updated user context: ward=${context.homeWard}, station=${context.nearestStation}');
  }

  /// Injects structured context into prompt queries when relevant
  Future<String> injectContextIntoPrompt(String userPrompt) async {
    final context = await getContext();
    final lower = userPrompt.toLowerCase();

    final buffer = StringBuffer();
    buffer.writeln(userPrompt);

    // Identify relevant contextual intents
    final mentionsWardOffice = lower.contains('city office') ||
        lower.contains('ward office') ||
        lower.contains('区役所') ||
        lower.contains('市役所') ||
        lower.contains('juminhyo') ||
        lower.contains('resident certificate') ||
        lower.contains('address');

    final mentionsTransit = lower.contains('train') ||
        lower.contains('station') ||
        lower.contains('subway') ||
        lower.contains('commute') ||
        lower.contains('yamanote') ||
        lower.contains('metro') ||
        lower.contains('transit');

    final mentionsGarbage = lower.contains('garbage') ||
        lower.contains('trash') ||
        lower.contains('recycle') ||
        lower.contains('burnable') ||
        lower.contains('plastics') ||
        lower.contains('ごみ');

    final mentionsVisa = lower.contains('visa') ||
        lower.contains('immigration') ||
        lower.contains('zairyu') ||
        lower.contains('residence card') ||
        lower.contains('renewal') ||
        lower.contains('入管');

    buffer.writeln('\n--- [STRUCTURED USER CONTEXT FROM PERSONAL ENGINE] ---');
    buffer.writeln('• Resident Municipality: ${context.homeWard}');
    buffer.writeln('• Nearest Station: ${context.nearestStation}');
    buffer.writeln('• Target Japanese Level: ${context.jlptLevel}');

    if (mentionsWardOffice) {
      final officeGuide = getWardOfficeDetails(context.homeWard);
      buffer.writeln('• Relevant Ward Office: $officeGuide');
    }

    if (mentionsTransit && context.commuteRoute.isNotEmpty) {
      buffer.writeln('• Primary Commute Line: ${context.commuteRoute}');
    }

    if (mentionsGarbage) {
      buffer.writeln('• Local Ward Garbage Schedule: Burnable on ${context.burnableGarbageDays}, Recyclables on ${context.recyclablePlasticsDays}');
    }

    if (mentionsVisa) {
      buffer.writeln('• Current Visa Category: ${context.residenceStatus}');
      if (context.residenceExpiryDate != null) {
        final days = context.daysUntilVisaExpiry;
        buffer.writeln('• Expiry: ${context.residenceExpiryDate!.toString().substring(0, 10)} ($days days remaining. Renewal window opens 90 days before expiry).');
      }
    }

    buffer.writeln('Please tailor your answer specifically to this resident context. No generic disclaimers.');

    return buffer.toString();
  }

  /// Directory of official ward offices in Tokyo for expat procedures
  static String getWardOfficeDetails(String wardName) {
    if (wardName.contains('Shinjuku') || wardName.contains('新宿')) {
      return 'Shinjuku Ward Office (新宿区役所本庁舎): 1-4-1 Kabukicho, Shinjuku-ku. 5 min walk from JR Shinjuku Station East Exit (東口). Open Mon-Fri 8:30-17:00 (Tuesdays open until 19:00).';
    } else if (wardName.contains('Shibuya') || wardName.contains('渋谷')) {
      return 'Shibuya City Office (渋谷区役所本庁舎): 1-1 Udagawacho, Shibuya-ku. 10 min walk from Shibuya Station Hachiko Exit (ハチ公口). Open Mon-Fri 8:30-17:00.';
    } else if (wardName.contains('Minato') || wardName.contains('港区')) {
      return 'Minato City Office (港区役所): 1-5-25 Shibakoen, Minato-ku. 3 min walk from Onarimon Station (Toei Mita Line) or 10 min from Daimon/Hamamatsucho.';
    } else if (wardName.contains('Toshima') || wardName.contains('豊島') || wardName.contains('Ikebukuro')) {
      return 'Toshima City Office (豊島区役所): 2-45-1 Minami-Ikebukuro, Toshima-ku. Directly connected underground to Higashi-Ikebukuro Station (Yurakucho Line).';
    } else if (wardName.contains('Suginami') || wardName.contains('杉並')) {
      return 'Suginami City Office (杉並区役所): 1-15-1 Asagaya-minami, Suginami-ku. 1 min walk from Minami-Asagaya Station (Marunouchi Line).';
    }
    return '$wardName City Office. Check official opening hours (typically Mon-Fri 8:30-17:00).';
  }
}
