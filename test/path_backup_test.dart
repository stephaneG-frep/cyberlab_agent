import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberlab_agent/data/course_library.dart';
import 'package:cyberlab_agent/data/learning_paths.dart';
import 'package:cyberlab_agent/models/coach_message.dart';
import 'package:cyberlab_agent/models/note.dart';
import 'package:cyberlab_agent/models/user_state.dart';
import 'package:cyberlab_agent/services/app_state.dart';
import 'package:cyberlab_agent/services/backup_service.dart';
import 'package:cyberlab_agent/services/secret_store.dart';

Future<AppState> _app({SecretStore? secrets}) async {
  final app = AppState(secrets: secrets ?? MemorySecretStore());
  await app.ready;
  return app;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Parcours', () {
    test('chaque parcours correspond à une catégorie de cours', () {
      final cats = CourseLibrary.all.map((c) => c.category).toSet();
      for (final p in LearningPaths.all) {
        expect(cats, contains(p.id));
        expect(p.courses, isNotEmpty, reason: p.id);
      }
      expect(LearningPaths.all.length, cats.length);
    });

    test('choix validé et conservé après redémarrage', () async {
      var app = await _app();
      expect(app.currentPath.id, 'fundamentals');
      await app.setPath('inconnu');
      expect(app.user.selectedPath, 'fundamentals');
      await app.setPath('linux');
      await app.storage.flush();
      app = await _app();
      expect(app.currentPath.id, 'linux');
    });

    test('cours suivant et progression suivent le parcours', () async {
      final app = await _app();
      await app.setPath('networking');
      final net = CourseLibrary.byCategory('networking');
      expect(app.nextCourse!.id, net.first.id);
      expect(app.pathProgress, (done: 0, total: net.length));

      final first = net.first;
      for (final q in first.quiz) {
        await app.answerQuiz(first.id, q, q.correct);
      }
      await app.completeCourse(first.id, first.xp);
      expect(app.nextCourse!.id, net[1].id);
      expect(app.pathProgress.done, 1);
    });

    test(
      'parcours terminé : on propose un cours d\'un autre parcours',
      () async {
        SharedPreferences.setMockInitialValues({
          'user_state': jsonEncode({
            'schemaVersion': 2,
            'selectedPath': 'bash',
            'completedCourses': CourseLibrary.byCategory(
              'bash',
            ).map((c) => c.id).toList(),
          }),
        });
        final app = await _app();
        expect(app.nextCourse, isNotNull);
        expect(app.nextCourse!.category, isNot('bash'));
      },
    );
  });

  group('Premier lancement', () {
    test('affiché une seule fois, valeurs enregistrées', () async {
      var app = await _app();
      expect(app.needsOnboarding, isTrue);
      await app.completeOnboarding(name: '  Ada ', path: 'web_security');
      expect(app.needsOnboarding, isFalse);
      expect(app.user.name, 'Ada');
      expect(app.currentPath.id, 'web_security');
      await app.storage.flush();
      app = await _app();
      expect(app.needsOnboarding, isFalse);
      expect(app.user.name, 'Ada');
    });

    test('jamais montré à un utilisateur qui a déjà des données', () async {
      SharedPreferences.setMockInitialValues({
        'user_state': jsonEncode({'xp': 120}),
      });
      expect((await _app()).needsOnboarding, isFalse);
      SharedPreferences.setMockInitialValues({
        'notes': jsonEncode([
          {'id': 'n1', 'title': 't', 'content': ''},
        ]),
      });
      expect((await _app()).needsOnboarding, isFalse);
    });
  });

  group('Export / import', () {
    Future<AppState> filled() async {
      SharedPreferences.setMockInitialValues({
        'settings': jsonEncode({
          'darkMode': false,
          'aiProvider': 'openai',
          'aiProfiles': {
            'openai': {'model': 'm-1', 'baseUrl': ''},
          },
          // Ancienne clé v1 non migrée : ne doit JAMAIS sortir.
          'aiApiKey': 'sk-secret-legacy',
          'aiLegacyKeyProvider': 'openai',
        }),
      });
      final secrets = MemorySecretStore(failWrites: true);
      final app = await _app(secrets: secrets);
      await app.completeOnboarding(name: 'Ada', path: 'linux');
      await app.solveChallenge('ctf-linux-1', 50);
      await app.addNote(Note(id: 'n1', title: 'Ma note', content: 'grep -c'));
      app.coachMessages.add(CoachMessage(CoachRole.user, 'Question privée'));
      return app;
    }

    test(
      'l\'export ne contient aucune clé ni donnée hors liste blanche',
      () async {
        final app = await filled();
        final json = await app.exportData();
        expect(json, isNot(contains('sk-secret-legacy')));
        expect(json, isNot(contains('aiApiKey')));
        expect(
          json,
          isNot(contains('Question privée')),
          reason: 'coach exclu par défaut',
        );
        final data = jsonDecode(json) as Map;
        expect(data['kind'], BackupFormat.kind);
        expect((data['settings'] as Map).keys.toSet(), {
          'darkMode',
          'aiProvider',
          'aiProfiles',
          'onboardingDone',
        });
        expect(
          await app.exportData(includeCoach: true),
          contains('Question privée'),
        );
      },
    );

    test('aller-retour complet vers un nouvel appareil', () async {
      final source = await filled();
      final json = await source.exportData(includeCoach: true);

      SharedPreferences.setMockInitialValues({});
      final target = await _app();
      final preview = BackupFormat.decode(json);
      expect(preview.user.name, 'Ada');
      expect(preview.notes.single.title, 'Ma note');
      expect(await target.importBackup(preview), isNull);

      expect(target.user.name, 'Ada');
      expect(target.user.xp, 50);
      expect(target.currentPath.id, 'linux');
      expect(target.notes.single.content, 'grep -c');
      expect(target.coachMessages.single.text, 'Question privée');
      expect(target.darkMode, isFalse);
      expect(target.aiProfile('openai').model, 'm-1');
      expect(target.needsOnboarding, isFalse);
      // Les récompenses déjà obtenues ne sont pas redonnées.
      expect(await target.solveChallenge('ctf-linux-1', 50), 0);
      expect(target.user.xp, 50);

      // Persisté : un redémarrage relit les données importées.
      await target.storage.flush();
      final restarted = await _app();
      expect(restarted.user.name, 'Ada');
      expect(restarted.notes, hasLength(1));
    });

    test(
      'l\'import conserve une copie de l\'état remplacé et les clés',
      () async {
        final secrets = MemorySecretStore(
          initial: {apiKeySlot('openai'): 'sk-local'},
        );
        final app = await _app(secrets: secrets);
        await app.addNote(Note(id: 'old', title: 'Ancienne', content: ''));
        await app.storage.flush();
        final backup = BackupFormat.encode(
          user: UserState(name: 'Importé', xp: 10),
          notes: const [],
          settings: const {},
        );
        expect(await app.importBackup(BackupFormat.decode(backup)), isNull);
        expect(app.notes, isEmpty);
        expect(await app.readApiKey('openai'), 'sk-local');
        final prefs = await SharedPreferences.getInstance();
        final copy = prefs.getKeys().firstWhere(
          (k) => k.startsWith('notes_corrupt_'),
        );
        expect(prefs.getString(copy), contains('Ancienne'));
      },
    );

    test('fichiers refusés avec un message clair', () {
      void refused(String raw, String fragment) => expect(
        () => BackupFormat.decode(raw),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.message,
            'message',
            contains(fragment),
          ),
        ),
      );
      refused('pas du json', 'JSON illisible');
      refused('{"kind":"autre"}', 'n\'est pas un export');
      refused(
        '{"kind":"cyberlab-agent-backup","version":99,"userState":{}}',
        'plus récente',
      );
      refused(
        '{"kind":"cyberlab-agent-backup","version":1}',
        'progression est absente',
      );
    });

    test('éléments invalides ignorés et comptés', () {
      final raw = jsonEncode({
        'kind': BackupFormat.kind,
        'version': 1,
        'userState': {'xp': 5},
        'notes': [
          {'id': 'n1', 'title': 'ok'},
          42,
        ],
        'coachHistory': [
          {'role': 'user', 'text': 'Q'},
          {'role': '???'},
        ],
        'settings': {'darkMode': true, 'aiApiKey': 'fuite'},
      });
      final p = BackupFormat.decode(raw);
      expect(p.notes, hasLength(1));
      expect(p.coachHistory, hasLength(1));
      expect(p.skippedItems, 2);
      expect(p.settings.containsKey('aiApiKey'), isFalse);
    });

    test('nom de fichier daté', () {
      expect(
        BackupFormat.fileName(DateTime(2026, 11, 23)),
        'cyberlab-sauvegarde-2026-11-23.json',
      );
    });
  });
}
