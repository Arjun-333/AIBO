import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../features/chat/models/chat_message.dart';

enum LlmProvider { gemini, nvidia, auto }

class LlmService {
  static final LlmService instance = LlmService._init();
  LlmService._init();

  static const String _japanSystemPrompt = '''
You are AIBO (AI Buddy & Organiser), a friendly, helpful, and culturally knowledgeable personal companion for a foreigner living in Japan.
Your core rules:
1. Accurately explain Japanese cultural etiquette, administrative procedures (ward office/市役所, tax/住民税, health insurance/国民健康保険, residence card/在留カード), and municipal garbage sorting rules (burnable/燃えるごみ, non-burnable/燃えないごみ, recyclables/資源ごみ).
2. When answering Japanese language questions, provide the Kanji (漢字), Hiragana/Furigana reading, Romaji pronunciation, and clear English meaning. Explain politeness levels (Polite/丁寧語 vs Casual/タメ口 vs Humble/謙譲語).
3. NON-FABRICATION RULE: Never invent train schedules, prices, laws, or emergency guidelines. If you are uncertain or the rule varies by Tokyo ward/municipality, state clearly that it depends on the local ward office (区役所).
4. Keep answers concise, actionable, and formatted with clean bullet points.
''';

  /// Sends a conversation prompt to the configured LLM (NVIDIA Nemotron or Gemini)
  Future<String> sendMessage({
    required String prompt,
    List<ChatMessage> conversationHistory = const [],
    LlmProvider preferredProvider = LlmProvider.auto,
  }) async {
    final nvidiaKey = dotenv.env['NVIDIA_API_KEY']?.trim() ?? '';
    final geminiKey = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';

    // If auto or nvidia preferred and key exists, attempt NVIDIA Nemotron first
    if ((preferredProvider == LlmProvider.auto || preferredProvider == LlmProvider.nvidia) &&
        nvidiaKey.isNotEmpty) {
      try {
        final reply = await _callNvidiaNemotron(
          prompt: prompt,
          conversationHistory: conversationHistory,
          apiKey: nvidiaKey,
        );
        return reply;
      } catch (e) {
        debugPrint('NVIDIA Nemotron call failed ($e). Falling back to Gemini...');
        // Fallback to Gemini if key available
        if (geminiKey.isNotEmpty) {
          return await _callGemini(prompt: prompt, conversationHistory: conversationHistory, apiKey: geminiKey);
        } else {
          rethrow;
        }
      }
    }

    // Default: Google Gemini
    if (geminiKey.isNotEmpty) {
      return await _callGemini(prompt: prompt, conversationHistory: conversationHistory, apiKey: geminiKey);
    }

    throw Exception(
      'No API key found! Please paste your Gemini or NVIDIA API key into .env.',
    );
  }

  /// Calls NVIDIA NIM (Nemotron 70B Instruct) via OpenAI-compatible endpoint
  Future<String> _callNvidiaNemotron({
    required String prompt,
    required List<ChatMessage> conversationHistory,
    required String apiKey,
  }) async {
    final baseUrl = dotenv.env['NVIDIA_BASE_URL']?.trim() ?? 'https://integrate.api.nvidia.com/v1';
    final model = dotenv.env['NVIDIA_MODEL']?.trim() ?? 'nvidia/llama-3.1-nemotron-70b-instruct';

    final url = Uri.parse('$baseUrl/chat/completions');

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _japanSystemPrompt},
    ];

    // Append recent conversation context (last 8 messages for token efficiency)
    final recentHistory = conversationHistory.length > 8
        ? conversationHistory.sublist(conversationHistory.length - 8)
        : conversationHistory;

    for (final msg in recentHistory) {
      messages.add({
        'role': msg.role == 'assistant' ? 'assistant' : 'user',
        'content': msg.content,
      });
    }

    messages.add({'role': 'user', 'content': prompt});

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'messages': messages,
        'temperature': 0.6,
        'max_tokens': 1024,
      }),
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final content = data['choices'][0]['message']['content'] as String;
      return content.trim();
    } else if (response.statusCode == 402) {
      throw Exception('NVIDIA free trial credits have expired (HTTP 402).');
    } else {
      throw Exception('NVIDIA API error: HTTP ${response.statusCode} - ${response.body}');
    }
  }

  /// Calls Google Gemini 1.5 Flash via Google AI Studio API
  Future<String> _callGemini({
    required String prompt,
    required List<ChatMessage> conversationHistory,
    required String apiKey,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    final contents = <Map<String, dynamic>>[];

    // Add recent history
    final recentHistory = conversationHistory.length > 8
        ? conversationHistory.sublist(conversationHistory.length - 8)
        : conversationHistory;

    for (final msg in recentHistory) {
      contents.add({
        'role': msg.role == 'assistant' ? 'model' : 'user',
        'parts': [
          {'text': msg.content}
        ],
      });
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': '$_japanSystemPrompt\n\nUser Question: $prompt'}
      ],
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1000,
        },
      }),
    ).timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      return text.trim();
    } else if (response.statusCode == 429) {
      throw Exception('Daily Gemini free quota reached (HTTP 429). Resets at midnight.');
    } else {
      throw Exception('Gemini API error: HTTP ${response.statusCode} - ${response.body}');
    }
  }
}
