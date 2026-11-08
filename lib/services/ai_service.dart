import 'dart:async';
import 'dart:convert';
import 'dart:io'
    show
        HandshakeException,
        InternetAddress,
        InternetAddressType,
        SocketException;
import 'package:http/http.dart' as http;

/// Fournisseurs pris en charge.
class AiProviders {
  AiProviders._();
  static const openai = 'openai';
  static const anthropic = 'anthropic';
  static const gemini = 'gemini';
  static const mistral = 'mistral';
  static const ollama = 'ollama';
  static const compatible = 'compatible';

  static const all = [ollama, openai, anthropic, gemini, mistral, compatible];

  static String label(String p) => switch (p) {
    openai => 'OpenAI',
    anthropic => 'Anthropic',
    gemini => 'Gemini',
    mistral => 'Mistral',
    ollama => 'Ollama (local)',
    compatible => 'API compatible OpenAI',
    _ => p,
  };

  /// Adresse par défaut (null = adresse obligatoire).
  static String? defaultBaseUrl(String p) => switch (p) {
    openai => 'https://api.openai.com/v1',
    mistral => 'https://api.mistral.ai/v1',
    anthropic => 'https://api.anthropic.com/v1',
    gemini => 'https://generativelanguage.googleapis.com/v1beta',
    _ => null,
  };

  /// Fournisseurs distants : HTTPS obligatoire, clé obligatoire.
  static bool isRemote(String p) =>
      p == openai || p == mistral || p == anthropic || p == gemini;

  /// Ollama n'utilise jamais de clé.
  static bool usesKey(String p) => p != ollama;
}

class AiSettings {
  final String provider;
  final String model;
  final String baseUrl;
  final String apiKey;

  const AiSettings({
    this.provider = AiProviders.ollama,
    this.model = '',
    this.baseUrl = '',
    this.apiKey = '',
  });

  /// Le modèle est toujours explicite : aucun modèle n'est supposé disponible.
  bool get isConfigured {
    if (!AiProviders.all.contains(provider)) return false;
    if (model.trim().isEmpty) return false;
    if (AiProviders.defaultBaseUrl(provider) == null &&
        baseUrl.trim().isEmpty) {
      return false;
    }
    if (AiProviders.isRemote(provider) && apiKey.trim().isEmpty) return false;
    return true;
  }
}

enum ChatRole { user, assistant }

class ChatTurn {
  final ChatRole role;
  final String text;
  const ChatTurn(this.role, this.text);
}

enum AiErrorKind {
  notConfigured,
  invalidUrl,
  insecureUrl,
  auth,
  quota,
  model,
  badRequest,
  server,
  unreachable,
  tls,
  timeout,
  emptyResponse,
  unknown,
}

class AiResult {
  final String? text;
  final AiErrorKind? error;
  final int? statusCode;

  const AiResult.ok(String this.text) : error = null, statusCode = null;
  const AiResult.fail(AiErrorKind this.error, {this.statusCode}) : text = null;

  bool get isOk => text != null;

  /// Message compréhensible, sans corps de réponse ni secret.
  String get message {
    if (text != null) return text!;
    final code = statusCode == null ? '' : ' (HTTP $statusCode)';
    return switch (error!) {
      AiErrorKind.notConfigured =>
        'Le coach IA n\'est pas configuré : choisissez un fournisseur, un modèle '
            'et, si nécessaire, une clé dans Paramètres.',
      AiErrorKind.invalidUrl =>
        'Adresse du serveur invalide. Vérifiez l\'URL dans Paramètres.',
      AiErrorKind.insecureUrl =>
        'Adresse refusée : HTTPS est obligatoire, sauf pour un serveur local '
            '(localhost, réseau privé 10.x, 172.16–31.x, 192.168.x, *.local).',
      AiErrorKind.auth =>
        'Authentification refusée$code : vérifiez la clé API du fournisseur sélectionné.',
      AiErrorKind.quota =>
        'Quota ou limite de requêtes atteint$code. Réessayez plus tard ou vérifiez votre forfait.',
      AiErrorKind.model =>
        'Modèle ou ressource introuvable$code : vérifiez le nom exact du modèle '
            'dans la documentation du fournisseur.',
      AiErrorKind.badRequest =>
        'Requête refusée par le fournisseur$code. Le modèle indiqué est peut-être '
            'incorrect ou indisponible pour votre compte.',
      AiErrorKind.server =>
        'Le service du fournisseur rencontre un problème$code. Réessayez plus tard.',
      AiErrorKind.unreachable =>
        'Serveur inaccessible. Vérifiez la connexion réseau et l\'adresse '
            '(pour Ollama : même réseau Wi-Fi, serveur démarré et à l\'écoute).',
      AiErrorKind.tls =>
        'Connexion sécurisée impossible : le certificat du serveur n\'a pas pu être validé.',
      AiErrorKind.timeout =>
        'Délai dépassé : le serveur n\'a pas répondu à temps.',
      AiErrorKind.emptyResponse => 'Le fournisseur a renvoyé une réponse vide.',
      AiErrorKind.unknown =>
        'Erreur inattendue lors de l\'appel au coach IA$code.',
    };
  }
}

/// Vrai pour les hôtes locaux autorisés en HTTP clair :
/// boucle locale, réseaux privés IPv4 (RFC 1918), lien-local, IPv6 ULA/lien
/// local, `localhost` et noms mDNS `*.local`.
bool isLocalHost(String host) {
  final h = host.toLowerCase();
  if (h == 'localhost' || h.endsWith('.local')) return true;
  final addr = InternetAddress.tryParse(h);
  if (addr == null) return false;
  if (addr.isLoopback || addr.isLinkLocal) return true;
  final b = addr.rawAddress;
  if (addr.type == InternetAddressType.IPv4) {
    return b[0] == 10 ||
        (b[0] == 172 && b[1] >= 16 && b[1] <= 31) ||
        (b[0] == 192 && b[1] == 168);
  }
  if (addr.type == InternetAddressType.IPv6) {
    return (b[0] & 0xFE) == 0xFC; // fc00::/7
  }
  return false;
}

/// Ajoute [suffix] à [base] sans doubler les slashs ni le chemin.
String joinEndpoint(String base, String suffix) {
  var b = base.trim();
  while (b.endsWith('/')) {
    b = b.substring(0, b.length - 1);
  }
  final s = suffix.startsWith('/') ? suffix : '/$suffix';
  if (b.endsWith(s)) return b;
  return '$b$s';
}

/// Résultat de validation d'une adresse.
class EndpointCheck {
  final Uri? uri;
  final AiErrorKind? error;
  const EndpointCheck.ok(Uri this.uri) : error = null;
  const EndpointCheck.fail(AiErrorKind this.error) : uri = null;
}

/// Construit et valide l'URL finale pour le fournisseur.
EndpointCheck buildEndpoint(AiSettings s) {
  final base = s.baseUrl.trim().isNotEmpty
      ? s.baseUrl.trim()
      : AiProviders.defaultBaseUrl(s.provider);
  if (base == null) return const EndpointCheck.fail(AiErrorKind.invalidUrl);

  final model = s.model.trim().replaceFirst(RegExp(r'^models/'), '');
  final suffix = switch (s.provider) {
    AiProviders.anthropic => '/messages',
    AiProviders.gemini => '/models/$model:generateContent',
    AiProviders.ollama => '/api/chat',
    _ => '/chat/completions',
  };

  final Uri uri;
  try {
    uri = Uri.parse(joinEndpoint(base, suffix));
  } on FormatException {
    return const EndpointCheck.fail(AiErrorKind.invalidUrl);
  }
  if (uri.host.isEmpty || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return const EndpointCheck.fail(AiErrorKind.invalidUrl);
  }
  if (uri.userInfo.isNotEmpty) {
    // Pas d'identifiants dans l'URL (risque de fuite dans les journaux).
    return const EndpointCheck.fail(AiErrorKind.invalidUrl);
  }
  if (uri.scheme == 'http') {
    final localAllowed =
        s.provider == AiProviders.ollama ||
        s.provider == AiProviders.compatible;
    if (!localAllowed || !isLocalHost(uri.host)) {
      return const EndpointCheck.fail(AiErrorKind.insecureUrl);
    }
  }
  return EndpointCheck.ok(uri);
}

/// Prépare l'historique envoyé : derniers échanges seulement, dans la limite
/// de [maxTurns] messages et [maxChars] caractères ; commence par un message
/// utilisateur ; fusionne les messages consécutifs de même rôle (exigé par
/// certains fournisseurs).
List<ChatTurn> trimHistory(
  List<ChatTurn> all, {
  int maxTurns = 12,
  int maxChars = 6000,
}) {
  final picked = <ChatTurn>[];
  var chars = 0;
  for (var i = all.length - 1; i >= 0; i--) {
    final t = all[i];
    if (t.text.trim().isEmpty) continue;
    if (picked.length >= maxTurns) break;
    if (picked.isNotEmpty && chars + t.text.length > maxChars) break;
    picked.insert(0, t);
    chars += t.text.length;
  }
  while (picked.isNotEmpty && picked.first.role != ChatRole.user) {
    picked.removeAt(0);
  }
  final merged = <ChatTurn>[];
  for (final t in picked) {
    if (merged.isNotEmpty && merged.last.role == t.role) {
      merged[merged.length - 1] = ChatTurn(
        t.role,
        '${merged.last.text}\n\n${t.text}',
      );
    } else {
      merged.add(t);
    }
  }
  return merged;
}

class AiService {
  AiService(
    this.settings, {
    http.Client? client,
    this.timeout = const Duration(seconds: 90),
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final AiSettings settings;
  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  bool get isLive => settings.isConfigured;

  void close() {
    if (_ownsClient) _client.close();
  }

  /// Envoie la conversation [history] (dont le dernier message est la
  /// question de l'utilisateur) au fournisseur sélectionné.
  Future<AiResult> chat(String systemPrompt, List<ChatTurn> history) async {
    if (!settings.isConfigured) {
      return const AiResult.fail(AiErrorKind.notConfigured);
    }
    final endpoint = buildEndpoint(settings);
    if (endpoint.error != null) return AiResult.fail(endpoint.error!);
    final turns = trimHistory(history);
    if (turns.isEmpty) return const AiResult.fail(AiErrorKind.badRequest);

    final request = _buildRequest(systemPrompt, turns);
    try {
      final resp = await _client
          .post(endpoint.uri!, headers: request.headers, body: request.body)
          .timeout(timeout);
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        return AiResult.fail(
          _kindForStatus(resp.statusCode),
          statusCode: resp.statusCode,
        );
      }
      final text = _parse(utf8.decode(resp.bodyBytes));
      if (text == null || text.trim().isEmpty) {
        return const AiResult.fail(AiErrorKind.emptyResponse);
      }
      return AiResult.ok(text.trim());
    } on TimeoutException {
      return const AiResult.fail(AiErrorKind.timeout);
    } on HandshakeException {
      return const AiResult.fail(AiErrorKind.tls);
    } on SocketException {
      return const AiResult.fail(AiErrorKind.unreachable);
    } on http.ClientException {
      return const AiResult.fail(AiErrorKind.unreachable);
    } on FormatException {
      return const AiResult.fail(AiErrorKind.emptyResponse);
    } catch (_) {
      return const AiResult.fail(AiErrorKind.unknown);
    }
  }

  static AiErrorKind _kindForStatus(int code) {
    if (code == 401 || code == 403) return AiErrorKind.auth;
    if (code == 402 || code == 429) return AiErrorKind.quota;
    if (code == 404) return AiErrorKind.model;
    if (code == 408) return AiErrorKind.timeout;
    if (code >= 500) return AiErrorKind.server;
    if (code >= 400) return AiErrorKind.badRequest;
    return AiErrorKind.unknown;
  }

  ({Map<String, String> headers, String body}) _buildRequest(
    String sys,
    List<ChatTurn> turns,
  ) {
    final model = settings.model.trim();
    final key = settings.apiKey.trim();
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
    };
    String role(ChatTurn t) => t.role == ChatRole.user ? 'user' : 'assistant';

    switch (settings.provider) {
      case AiProviders.anthropic:
        headers['x-api-key'] = key;
        headers['anthropic-version'] = '2023-06-01';
        return (
          headers: headers,
          body: jsonEncode({
            'model': model,
            'max_tokens': 1024,
            'system': sys,
            'messages': [
              for (final t in turns) {'role': role(t), 'content': t.text},
            ],
          }),
        );
      case AiProviders.gemini:
        // Clé transmise dans l'en-tête, jamais dans l'URL.
        headers['x-goog-api-key'] = key;
        return (
          headers: headers,
          body: jsonEncode({
            'systemInstruction': {
              'parts': [
                {'text': sys},
              ],
            },
            'contents': [
              for (final t in turns)
                {
                  'role': t.role == ChatRole.user ? 'user' : 'model',
                  'parts': [
                    {'text': t.text},
                  ],
                },
            ],
          }),
        );
      case AiProviders.ollama:
        // Aucune clé n'est jamais envoyée à Ollama.
        return (
          headers: headers,
          body: jsonEncode({
            'model': model,
            'stream': false,
            'messages': [
              {'role': 'system', 'content': sys},
              for (final t in turns) {'role': role(t), 'content': t.text},
            ],
          }),
        );
      default: // openai, mistral, compatible
        if (key.isNotEmpty) headers['Authorization'] = 'Bearer $key';
        return (
          headers: headers,
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': sys},
              for (final t in turns) {'role': role(t), 'content': t.text},
            ],
          }),
        );
    }
  }

  String? _parse(String body) {
    final data = jsonDecode(body);
    if (data is! Map) return null;
    switch (settings.provider) {
      case AiProviders.anthropic:
        final content = data['content'];
        if (content is! List) return null;
        return content
            .whereType<Map>()
            .where((c) => c['type'] == null || c['type'] == 'text')
            .map((c) => c['text'] is String ? c['text'] as String : '')
            .join();
      case AiProviders.gemini:
        final candidates = data['candidates'];
        if (candidates is! List || candidates.isEmpty) return null;
        final first = candidates.first;
        if (first is! Map) return null;
        final content = first['content'];
        final parts = content is Map ? content['parts'] : null;
        if (parts is! List) return null;
        return parts
            .whereType<Map>()
            .map((p) => p['text'] is String ? p['text'] as String : '')
            .join();
      case AiProviders.ollama:
        final message = data['message'];
        return message is Map && message['content'] is String
            ? message['content'] as String
            : null;
      default:
        final choices = data['choices'];
        if (choices is! List || choices.isEmpty) return null;
        final first = choices.first;
        final message = first is Map ? first['message'] : null;
        return message is Map && message['content'] is String
            ? message['content'] as String
            : null;
    }
  }
}
