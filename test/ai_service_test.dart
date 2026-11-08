import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberlab_agent/models/coach_message.dart';
import 'package:cyberlab_agent/services/ai_service.dart';
import 'package:cyberlab_agent/services/app_state.dart';
import 'package:cyberlab_agent/services/secret_store.dart';

const _sys = 'system';
const _q = [ChatTurn(ChatRole.user, 'Bonjour')];

/// Client simulé qui enregistre la dernière requête.
class _Recorder {
  http.Request? last;
  int calls = 0;
  MockClient client(String body, {int status = 200}) => MockClient((req) async {
    last = req;
    calls++;
    return http.Response.bytes(utf8.encode(body), status);
  });
}

String _openAiBody(String text) => jsonEncode({
  'choices': [
    {
      'message': {'content': text},
    },
  ],
});

void main() {
  group('Routage des fournisseurs et clés', () {
    test('OpenAI : adresse par défaut, Bearer, modèle explicite', () async {
      final r = _Recorder();
      final s = AiService(
        const AiSettings(provider: 'openai', model: 'm-x', apiKey: 'sk-open'),
        client: r.client(_openAiBody('ok')),
      );
      final res = await s.chat(_sys, _q);
      expect(res.text, 'ok');
      expect(
        r.last!.url.toString(),
        'https://api.openai.com/v1/chat/completions',
      );
      expect(r.last!.headers['Authorization'], 'Bearer sk-open');
      expect(jsonDecode(r.last!.body)['model'], 'm-x');
    });

    test('Mistral : adresse Mistral par défaut (plus jamais OpenAI)', () async {
      final r = _Recorder();
      await AiService(
        const AiSettings(provider: 'mistral', model: 'm', apiKey: 'mk'),
        client: r.client(_openAiBody('ok')),
      ).chat(_sys, _q);
      expect(r.last!.url.host, 'api.mistral.ai');
      expect(r.last!.url.path, '/v1/chat/completions');
    });

    test('Anthropic : en-têtes x-api-key et version', () async {
      final r = _Recorder();
      final res = await AiService(
        const AiSettings(provider: 'anthropic', model: 'm', apiKey: 'ak'),
        client: r.client(
          jsonEncode({
            'content': [
              {'type': 'text', 'text': 'salut'},
            ],
          }),
        ),
      ).chat(_sys, _q);
      expect(res.text, 'salut');
      expect(r.last!.url.toString(), 'https://api.anthropic.com/v1/messages');
      expect(r.last!.headers['x-api-key'], 'ak');
      expect(r.last!.headers['anthropic-version'], isNotNull);
      expect(r.last!.headers.containsKey('Authorization'), isFalse);
    });

    test('Gemini : clé dans x-goog-api-key, jamais dans l\'URL', () async {
      final r = _Recorder();
      final res = await AiService(
        const AiSettings(provider: 'gemini', model: 'models/g-1', apiKey: 'gk'),
        client: r.client(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'hey'},
                  ],
                },
              },
            ],
          }),
        ),
      ).chat(_sys, _q);
      expect(res.text, 'hey');
      expect(r.last!.headers['x-goog-api-key'], 'gk');
      expect(r.last!.url.query, isEmpty);
      expect(r.last!.url.toString().contains('gk'), isFalse);
      expect(r.last!.url.path, '/v1beta/models/g-1:generateContent');
    });

    test('Ollama : HTTP local accepté, aucune clé envoyée', () async {
      final r = _Recorder();
      final res = await AiService(
        const AiSettings(
          provider: 'ollama',
          model: 'llm',
          baseUrl: 'http://192.168.1.20:11434/api/chat/',
          apiKey: 'ne-doit-pas-partir',
        ),
        client: r.client(
          jsonEncode({
            'message': {'content': 'local'},
          }),
        ),
      ).chat(_sys, _q);
      expect(res.text, 'local');
      expect(r.last!.url.toString(), 'http://192.168.1.20:11434/api/chat');
      expect(r.last!.headers.containsKey('Authorization'), isFalse);
      expect(r.last!.body.contains('ne-doit-pas-partir'), isFalse);
    });

    test('normalisation des slashs, pas de chemin dupliqué', () {
      expect(
        joinEndpoint('https://api.openai.com/v1///', '/chat/completions'),
        'https://api.openai.com/v1/chat/completions',
      );
      expect(
        joinEndpoint('https://h/v1/chat/completions', '/chat/completions'),
        'https://h/v1/chat/completions',
      );
    });

    test('HTTPS obligatoire pour les distants et hôtes publics', () async {
      final r = _Recorder();
      final remote = await AiService(
        const AiSettings(
          provider: 'openai',
          model: 'm',
          apiKey: 'k',
          baseUrl: 'http://api.openai.com/v1',
        ),
        client: r.client('{}'),
      ).chat(_sys, _q);
      expect(remote.error, AiErrorKind.insecureUrl);
      final public = await AiService(
        const AiSettings(
          provider: 'ollama',
          model: 'm',
          baseUrl: 'http://8.8.8.8:11434',
        ),
        client: r.client('{}'),
      ).chat(_sys, _q);
      expect(public.error, AiErrorKind.insecureUrl);
      expect(r.calls, 0, reason: 'aucune requête envoyée');
    });

    test('hôtes locaux reconnus', () {
      for (final h in [
        'localhost',
        '127.0.0.1',
        '10.0.0.5',
        '172.16.0.1',
        '172.31.255.1',
        '192.168.1.20',
        '169.254.1.1',
        'pc.local',
        '::1',
        'fd00::1',
      ]) {
        expect(isLocalHost(h), isTrue, reason: h);
      }
      for (final h in ['8.8.8.8', '172.32.0.1', '192.169.0.1', 'example.com']) {
        expect(isLocalHost(h), isFalse, reason: h);
      }
    });

    test('modèle obligatoire : pas de modèle supposé', () {
      expect(
        const AiSettings(provider: 'openai', apiKey: 'k').isConfigured,
        isFalse,
      );
      expect(
        const AiSettings(
          provider: 'ollama',
          baseUrl: 'http://localhost:1',
        ).isConfigured,
        isFalse,
      );
    });
  });

  group('Historique envoyé', () {
    test('les échanges précédents sont transmis, dans l\'ordre', () async {
      final r = _Recorder();
      await AiService(
        const AiSettings(provider: 'openai', model: 'm', apiKey: 'k'),
        client: r.client(_openAiBody('ok')),
      ).chat(_sys, const [
        ChatTurn(ChatRole.user, 'Q1'),
        ChatTurn(ChatRole.assistant, 'R1'),
        ChatTurn(ChatRole.user, 'Q2'),
      ]);
      final msgs = (jsonDecode(r.last!.body)['messages'] as List)
          .map((m) => '${m['role']}:${m['content']}')
          .toList();
      expect(msgs, ['system:system', 'user:Q1', 'assistant:R1', 'user:Q2']);
    });

    test('taille limitée, commence par l\'utilisateur, rôles fusionnés', () {
      final long = [
        for (var i = 0; i < 40; i++)
          ChatTurn(i.isEven ? ChatRole.user : ChatRole.assistant, 'm$i'),
        const ChatTurn(ChatRole.user, 'suite'),
      ];
      final t = trimHistory(long, maxTurns: 12);
      expect(t.length, lessThanOrEqualTo(12));
      expect(t.first.role, ChatRole.user);
      expect(t.last.text.endsWith('suite'), isTrue);
      for (var i = 1; i < t.length; i++) {
        expect(t[i].role, isNot(t[i - 1].role));
      }
      final big = trimHistory([
        ChatTurn(ChatRole.user, 'x' * 5000),
        const ChatTurn(ChatRole.assistant, 'r'),
        ChatTurn(ChatRole.user, 'y' * 3000),
      ], maxChars: 6000);
      expect(big.single.text, 'y' * 3000);
    });
  });

  group('Erreurs HTTP compréhensibles, sans corps ni secret', () {
    Future<AiResult> withStatus(int status) => AiService(
      const AiSettings(provider: 'openai', model: 'm', apiKey: 'sk-secret'),
      client: MockClient(
        (_) async =>
            http.Response('{"error":"détail sk-secret interne"}', status),
      ),
    ).chat(_sys, _q);

    test('codes de statut', () async {
      expect((await withStatus(401)).error, AiErrorKind.auth);
      expect((await withStatus(403)).error, AiErrorKind.auth);
      expect((await withStatus(429)).error, AiErrorKind.quota);
      expect((await withStatus(404)).error, AiErrorKind.model);
      expect((await withStatus(400)).error, AiErrorKind.badRequest);
      expect((await withStatus(503)).error, AiErrorKind.server);
      final msg = (await withStatus(401)).message;
      expect(msg.contains('sk-secret'), isFalse);
      expect(msg.contains('interne'), isFalse);
      expect(msg, contains('401'));
    });

    test('serveur inaccessible et délai dépassé', () async {
      final down = await AiService(
        const AiSettings(provider: 'openai', model: 'm', apiKey: 'k'),
        client: MockClient((_) async => throw const SocketException('down')),
      ).chat(_sys, _q);
      expect(down.error, AiErrorKind.unreachable);
      final slow = await AiService(
        const AiSettings(provider: 'openai', model: 'm', apiKey: 'k'),
        timeout: const Duration(milliseconds: 20),
        client: MockClient((_) => Completer<http.Response>().future),
      ).chat(_sys, _q);
      expect(slow.error, AiErrorKind.timeout);
    });
  });

  group('Clés : stockage sécurisé, migration, isolation', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Map<String, Object> legacy(String provider) => {
      'settings': jsonEncode({
        'darkMode': true,
        'aiProvider': provider,
        'aiModel': 'mon-modele',
        'aiBaseUrl': '',
        'aiApiKey': 'sk-legacy',
      }),
    };

    test(
      'migration réussie : clé déplacée puis supprimée des préférences',
      () async {
        SharedPreferences.setMockInitialValues(legacy('openai'));
        final secrets = MemorySecretStore();
        final app = AppState(secrets: secrets);
        await app.ready;
        await app.storage.flush();
        expect(secrets.values[apiKeySlot('openai')], 'sk-legacy');
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('settings')!.contains('sk-legacy'), isFalse);
        expect(app.aiProfile('openai').model, 'mon-modele');
        expect((await app.currentAiSettings()).apiKey, 'sk-legacy');
      },
    );

    test(
      'migration en échec : ancienne clé conservée, avertissement',
      () async {
        SharedPreferences.setMockInitialValues(legacy('openai'));
        final app = AppState(secrets: MemorySecretStore(failWrites: true));
        await app.ready;
        await app.storage.flush();
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('settings')!.contains('sk-legacy'), isTrue);
        expect(app.warnings, isNotEmpty);
        expect((await app.currentAiSettings()).apiKey, 'sk-legacy');
      },
    );

    test(
      'relecture différente = échec, l\'ancienne clé n\'est pas supprimée',
      () async {
        SharedPreferences.setMockInitialValues(legacy('openai'));
        final app = AppState(secrets: MemorySecretStore(corruptWrites: true));
        await app.ready;
        await app.storage.flush();
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('settings')!.contains('sk-legacy'), isTrue);
      },
    );

    test(
      'changer de fournisseur ne transmet pas la clé du précédent',
      () async {
        final r = _Recorder();
        final secrets = MemorySecretStore();
        final app = AppState(
          secrets: secrets,
          httpClient: r.client(_openAiBody('ok')),
        );
        await app.ready;
        await app.saveAiConfig(
          provider: 'openai',
          model: 'm',
          baseUrl: '',
          apiKey: 'sk-openai',
        );
        await app.saveAiConfig(provider: 'mistral', model: 'm', baseUrl: '');
        final mistral = await app.currentAiSettings();
        expect(mistral.provider, 'mistral');
        expect(mistral.apiKey, isEmpty);
        expect(mistral.isConfigured, isFalse);
        expect(app.aiProfile('mistral').baseUrl, isEmpty);
        await app.sendCoachMessage('test');
        expect(r.calls, 0, reason: 'non configuré : aucun envoi');
        // Clé jamais écrite en clair dans les préférences.
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('settings')!.contains('sk-openai'), isFalse);
      },
    );

    test('URL non sécurisée refusée à l\'enregistrement', () async {
      final app = AppState(secrets: MemorySecretStore());
      await app.ready;
      final err = await app.saveAiConfig(
        provider: 'openai',
        model: 'm',
        baseUrl: 'http://example.com/v1',
      );
      expect(err, isNotNull);
      expect(app.aiProvider, 'ollama', reason: 'rien n\'est enregistré');
    });
  });

  group('Coach : mémoire et hors ligne', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('hors ligne : notice explicite, rien de présenté comme IA', () async {
      final app = AppState(secrets: MemorySecretStore());
      await app.ready;
      await app.sendCoachMessage('Que fait nmap ?');
      expect(app.coachMessages.last.role, CoachRole.notice);
      expect(
        app.coachMessages.where((m) => m.role == CoachRole.assistant),
        isEmpty,
      );
      expect(app.coachBusy, isFalse);
    });

    test('historique transmis puis conservé entre deux ouvertures', () async {
      final r = _Recorder();
      var app = AppState(
        secrets: MemorySecretStore(),
        httpClient: r.client(
          jsonEncode({
            'message': {'content': 'indice'},
          }),
        ),
      );
      await app.ready;
      await app.saveAiConfig(
        provider: 'ollama',
        model: 'llm',
        baseUrl: 'http://localhost:11434',
      );
      await app.sendCoachMessage('Q1');
      await app.sendCoachMessage('Q2');
      final sent = (jsonDecode(r.last!.body)['messages'] as List)
          .map((m) => '${m['role']}:${m['content']}')
          .toList();
      expect(sent.first, startsWith('system:'));
      expect(sent.sublist(1), ['user:Q1', 'assistant:indice', 'user:Q2']);
      await app.storage.flush();

      app = AppState(secrets: MemorySecretStore());
      await app.ready;
      expect(app.coachMessages.map((m) => m.text), [
        'Q1',
        'indice',
        'Q2',
        'indice',
      ]);
      await app.clearCoachConversation();
      expect(app.coachMessages, isEmpty);
    });

    test('erreur réseau : bouton libéré, message compréhensible', () async {
      final app = AppState(
        secrets: MemorySecretStore(),
        httpClient: MockClient((_) async => throw const SocketException('x')),
      );
      await app.ready;
      await app.saveAiConfig(
        provider: 'ollama',
        model: 'llm',
        baseUrl: 'http://localhost:11434',
      );
      await app.sendCoachMessage('Q');
      expect(app.coachBusy, isFalse);
      expect(app.coachMessages.last.role, CoachRole.notice);
      expect(app.coachMessages.last.text, contains('inaccessible'));
    });
  });
}
