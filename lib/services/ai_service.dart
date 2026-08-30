import 'dart:convert';
import 'package:http/http.dart' as http;

class AiSettings {
  String
  provider; // openai | anthropic | gemini | mistral | ollama | compatible
  String model;
  String baseUrl;
  String apiKey;

  AiSettings({
    this.provider = 'ollama',
    this.model = '',
    this.baseUrl = '',
    this.apiKey = '',
  });

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'model': model,
    'baseUrl': baseUrl,
    'apiKey': apiKey,
  };

  factory AiSettings.fromJson(Map<String, dynamic> j) => AiSettings(
    provider: j['provider'] ?? 'ollama',
    model: j['model'] ?? '',
    baseUrl: j['baseUrl'] ?? '',
    apiKey: j['apiKey'] ?? '',
  );

  bool get isConfigured =>
      (provider == 'ollama' && baseUrl.isNotEmpty) ||
      (provider != 'ollama' && model.isNotEmpty && apiKey.isNotEmpty);
}

class AiService {
  AiSettings settings;

  AiService(this.settings);

  Future<String?> chat(String systemPrompt, String userMessage) async {
    if (!settings.isConfigured) return null;

    try {
      switch (settings.provider) {
        case 'openai':
        case 'compatible':
        case 'mistral':
          return await _chatOpenAiCompatible(systemPrompt, userMessage);
        case 'anthropic':
          return await _chatAnthropic(systemPrompt, userMessage);
        case 'gemini':
          return await _chatGemini(systemPrompt, userMessage);
        case 'ollama':
          return await _chatOllama(systemPrompt, userMessage);
        default:
          return null;
      }
    } catch (e) {
      return 'Erreur IA : $e';
    }
  }

  Future<String?> _chatOpenAiCompatible(String sys, String user) async {
    final base = settings.baseUrl.isNotEmpty
        ? settings.baseUrl
        : 'https://api.openai.com/v1';
    final uri = Uri.parse(
      base.endsWith('/chat/completions')
          ? base
          : base.isEmpty || base.endsWith('/')
          ? '${base}chat/completions'
          : '$base/chat/completions',
    );
    final model = settings.model.isNotEmpty ? settings.model : 'gpt-4o-mini';
    final resp = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${settings.apiKey}',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': sys},
              {'role': 'user', 'content': user},
            ],
          }),
        )
        .timeout(const Duration(seconds: 90));
    if (resp.statusCode != 200) {
      return 'Erreur ${resp.statusCode} : ${resp.body}';
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) return null;
    return (choices[0]['message']?['content'] as String?)?.trim();
  }

  Future<String?> _chatAnthropic(String sys, String user) async {
    final base = settings.baseUrl.isNotEmpty
        ? settings.baseUrl
        : 'https://api.anthropic.com/v1/messages';
    final model = settings.model.isNotEmpty
        ? settings.model
        : 'claude-3-5-haiku-latest';
    final resp = await http
        .post(
          Uri.parse(base),
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': settings.apiKey,
            'anthropic-version': '2023-06-01',
          },
          body: jsonEncode({
            'model': model,
            'max_tokens': 1024,
            'system': sys,
            'messages': [
              {'role': 'user', 'content': user},
            ],
          }),
        )
        .timeout(const Duration(seconds: 90));
    if (resp.statusCode != 200) {
      return 'Erreur ${resp.statusCode} : ${resp.body}';
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final content = data['content'] as List?;
    if (content == null || content.isEmpty) return null;
    final parts = content.map((c) => c['text'] ?? '').join().trim();
    return parts.isEmpty ? null : parts;
  }

  Future<String?> _chatGemini(String sys, String user) async {
    final model = settings.model.isNotEmpty
        ? settings.model
        : 'gemini-1.5-flash';
    final key = settings.apiKey;
    final base = settings.baseUrl.isNotEmpty
        ? settings.baseUrl
        : 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
    final resp = await http
        .post(
          Uri.parse(base).replace(queryParameters: {'key': key}),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'systemInstruction': {
              'parts': [
                {'text': sys},
              ],
            },
            'contents': [
              {
                'role': 'user',
                'parts': [
                  {'text': user},
                ],
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 90));
    if (resp.statusCode != 200) {
      return 'Erreur ${resp.statusCode} : ${resp.body}';
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;
    final parts =
        (candidates[0]['content']?['parts'] as List?)
            ?.map((p) => p['text'] ?? '')
            .join()
            .trim() ??
        '';
    return parts.isEmpty ? null : parts;
  }

  Future<String?> _chatOllama(String sys, String user) async {
    var base = settings.baseUrl.isNotEmpty
        ? settings.baseUrl
        : 'http://localhost:11434';
    if (base.endsWith('/api/chat')) base = base.replaceAll('/api/chat', '');
    final model = settings.model.isNotEmpty ? settings.model : 'llama3';
    final resp = await http
        .post(
          Uri.parse('$base/api/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': model,
            'stream': false,
            'messages': [
              {'role': 'system', 'content': sys},
              {'role': 'user', 'content': user},
            ],
          }),
        )
        .timeout(const Duration(seconds: 120));
    if (resp.statusCode != 200) {
      return 'Erreur ${resp.statusCode} : ${resp.body}';
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final content = data['message']?['content'] as String?;
    return content?.trim();
  }

  bool get isLive => settings.isConfigured;
}
