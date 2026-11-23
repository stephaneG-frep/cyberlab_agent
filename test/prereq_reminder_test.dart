import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberlab_agent/data/course_library.dart';
import 'package:cyberlab_agent/data/course_prerequisites.dart';
import 'package:cyberlab_agent/services/app_state.dart';
import 'package:cyberlab_agent/services/reminder_service.dart';
import 'package:cyberlab_agent/services/secret_store.dart';

Future<AppState> _app({
  MemoryReminderScheduler? reminders,
  DateTime Function()? clock,
}) async {
  final app = AppState(
    secrets: MemorySecretStore(),
    reminders: reminders ?? MemoryReminderScheduler(),
    clock: clock,
  );
  await app.ready;
  return app;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Prérequis structurés', () {
    final ids = CourseLibrary.all.map((c) => c.id).toSet();

    test('chaque identifiant existe', () {
      for (final e in coursePrerequisites.entries) {
        expect(ids, contains(e.key));
        for (final p in e.value) {
          expect(ids, contains(p), reason: '${e.key} → $p');
          expect(p, isNot(e.key));
        }
      }
    });

    test('aucun cycle', () {
      final state = <String, int>{}; // 1 = en cours, 2 = terminé
      void visit(String id, List<String> path) {
        if (state[id] == 2) return;
        if (state[id] == 1) fail('Cycle : ${[...path, id].join(' → ')}');
        state[id] = 1;
        for (final p in coursePrerequisites[id] ?? const <String>[]) {
          visit(p, [...path, id]);
        }
        state[id] = 2;
      }

      for (final id in coursePrerequisites.keys) {
        visit(id, []);
      }
    });

    test('les cours avec un prérequis rédigé en ont une version liée', () {
      for (final c in CourseLibrary.all) {
        final text = c.prerequisites.join(' ').toLowerCase();
        final none = text.isEmpty || text.startsWith('aucun');
        if (!none) {
          expect(coursePrerequisites[c.id], isNotEmpty, reason: c.id);
        }
      }
    });

    test('prérequis manquants, puis faits', () async {
      SharedPreferences.setMockInitialValues({
        'user_state': jsonEncode({
          'schemaVersion': 2,
          'completedCourses': ['lin-users'],
        }),
      });
      final app = await _app();
      expect(app.prerequisitesOf('lin-permissions').map((c) => c.id), [
        'lin-users',
        'lin-groups',
      ]);
      expect(app.missingPrerequisites('lin-permissions').map((c) => c.id), [
        'lin-groups',
      ]);
      expect(app.missingPrerequisites('fund-intro'), isEmpty);
    });

    test(
      'le cours suivant saute un cours dont les prérequis manquent',
      () async {
        SharedPreferences.setMockInitialValues({
          'user_state': jsonEncode({
            'schemaVersion': 2,
            'selectedPath': 'python',
            'completedCourses': [
              'py-syntax',
              'py-variables',
              'py-conditions',
              'py-loops',
              'py-functions',
              'py-files',
              'py-json',
              'py-regex',
            ],
          }),
        });
        final app = await _app();
        // py-sockets exige net-ports et net-tcp, py-http exige net-http.
        expect(app.missingPrerequisites('py-sockets'), isNotEmpty);
        expect(app.nextCourse!.id, 'py-hash');
      },
    );

    test('sans cours prêt, le premier cours non terminé est proposé', () async {
      SharedPreferences.setMockInitialValues({
        'user_state': jsonEncode({'schemaVersion': 2, 'selectedPath': 'bash'}),
      });
      final app = await _app();
      expect(app.nextCourse!.id, 'bash-intro');
    });
  });

  group('Rappel quotidien : planification', () {
    const s = ReminderSettings(enabled: true, hour: 19, minute: 30);

    test('aujourd\'hui si l\'heure n\'est pas passée et aucune activité', () {
      expect(
        nextReminder(s, now: DateTime(2026, 11, 23, 10), activeToday: false),
        DateTime(2026, 11, 23, 19, 30),
      );
    });

    test('demain si l\'on a déjà pratiqué aujourd\'hui', () {
      expect(
        nextReminder(s, now: DateTime(2026, 11, 23, 10), activeToday: true),
        DateTime(2026, 11, 24, 19, 30),
      );
    });

    test('demain si l\'heure est passée, y compris en fin de mois', () {
      expect(
        nextReminder(s, now: DateTime(2026, 11, 30, 20), activeToday: false),
        DateTime(2026, 12, 1, 19, 30),
      );
    });

    test('lecture tolérante du réglage', () {
      expect(ReminderSettings.fromJson(null).enabled, isFalse);
      final r = ReminderSettings.fromJson({
        'enabled': true,
        'hour': 99,
        'minute': 'x',
      });
      expect((r.enabled, r.hour, r.minute), (true, 19, 0));
      expect(const ReminderSettings(hour: 7, minute: 5).label, '07:05');
    });
  });

  group('Rappel quotidien : AppState', () {
    var now = DateTime(2026, 11, 23, 10);
    DateTime clock() => now;
    setUp(() => now = DateTime(2026, 11, 23, 10));

    test('désactivé par défaut : rien n\'est programmé', () async {
      final r = MemoryReminderScheduler();
      final app = await _app(reminders: r, clock: clock);
      expect(app.reminder.enabled, isFalse);
      expect(r.scheduled, isNull);
      await app.solveChallenge('ctf-1', 10);
      expect(r.scheduled, isNull);
    });

    test('permission refusée : rappel non activé, message clair', () async {
      final r = MemoryReminderScheduler(grantPermission: false);
      final app = await _app(reminders: r, clock: clock);
      final error = await app.setReminder(enabled: true);
      expect(error, contains('Notifications refusées'));
      expect(app.reminder.enabled, isFalse);
      expect(r.scheduled, isNull);
    });

    test(
      'activation, activité du jour, nouvelle heure, désactivation',
      () async {
        final r = MemoryReminderScheduler();
        final app = await _app(reminders: r, clock: clock);
        expect(
          await app.setReminder(enabled: true, hour: 19, minute: 0),
          isNull,
        );
        expect(r.scheduled, DateTime(2026, 11, 23, 19));

        // Activité aujourd'hui : le rappel du jour est sauté.
        await app.solveChallenge('ctf-1', 10);
        expect(r.scheduled, DateTime(2026, 11, 24, 19));
        expect(r.body, contains('série'));

        await app.setReminder(enabled: true, hour: 8, minute: 15);
        expect(r.scheduled, DateTime(2026, 11, 24, 8, 15));

        await app.setReminder(enabled: false);
        expect(r.scheduled, isNull);
        expect(r.cancels, 1);
      },
    );

    test('le réglage est conservé et replanifié au redémarrage', () async {
      var r = MemoryReminderScheduler();
      var app = await _app(reminders: r, clock: clock);
      await app.setReminder(enabled: true, hour: 21, minute: 0);
      await app.storage.flush();

      now = DateTime(2026, 11, 25, 9);
      r = MemoryReminderScheduler();
      app = await _app(reminders: r, clock: clock);
      expect(app.reminder.enabled, isTrue);
      expect(r.scheduled, DateTime(2026, 11, 25, 21));
      expect(r.body, isNot(contains('série')), reason: 'série interrompue');
    });

    test('le réglage du rappel n\'est pas exporté', () async {
      final app = await _app(clock: clock);
      await app.setReminder(enabled: true);
      expect(await app.exportData(), isNot(contains('reminder')));
    });
  });
}
