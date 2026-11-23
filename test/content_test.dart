import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyberlab_agent/data/ctf_library.dart';
import 'package:cyberlab_agent/data/packet_capture.dart';
import 'package:cyberlab_agent/data/soc_alerts.dart';
import 'package:cyberlab_agent/services/app_state.dart';
import 'package:cyberlab_agent/services/display_filter.dart';
import 'package:cyberlab_agent/services/secret_store.dart';
import 'package:cyberlab_agent/services/terminal_engine.dart';

Set<int> _nos(String filter) => DisplayFilter.parse(
  filter,
).apply(LabCapture.packets).map((p) => p.no).toSet();

void main() {
  group('Simulateur SOC : catalogue', () {
    const alerts = SocCatalog.alerts;

    test('au moins 20 alertes, identifiants uniques, anciens conservés', () {
      expect(alerts.length, greaterThanOrEqualTo(20));
      final ids = alerts.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final old in ['s1', 's2', 's3', 's4', 's5', 's6']) {
        expect(ids, contains(old), reason: 'récompenses déjà obtenues');
      }
    });

    test('chaque alerte est complète et utilise les valeurs prévues', () {
      for (final a in alerts) {
        expect(SocCatalog.severities, contains(a.severity), reason: a.id);
        expect(SocCatalog.decisions, contains(a.decision), reason: a.id);
        for (final text in [
          a.title,
          a.details,
          a.source,
          a.explanation,
          a.action,
        ]) {
          expect(text.trim(), isNotEmpty, reason: a.id);
        }
        if (a.decision == 'Contenir' || a.decision == 'Investiguer') {
          expect(a.mitre, isNotNull, reason: '${a.id} : technique attendue');
          expect(
            a.mitre,
            matches(RegExp(r'^T\d{4}(\.\d{3})? — ')),
            reason: a.id,
          );
        }
      }
    });

    test('toutes les décisions et gravités sont représentées', () {
      expect(
        alerts.map((a) => a.decision).toSet(),
        SocCatalog.decisions.toSet(),
      );
      expect(
        alerts.map((a) => a.severity).toSet(),
        SocCatalog.severities.toSet(),
      );
    });
  });

  group('CTF : catalogue', () {
    final all = ctfChallenges();

    test('au moins 25 challenges, identifiants uniques', () {
      expect(all.length, greaterThanOrEqualTo(25));
      expect(all.map((c) => c.id).toSet().length, all.length);
    });

    test(
      'chaque commande de résolution fonctionne dans le terminal du Lab',
      () {
        // Réponses qui sont elles-mêmes des commandes : on vérifie seulement
        // que la commande réussit.
        const commandAnswers = {'ctf-scripting-2', 'ctf-forensic-3'};
        final withCommand = all
            .where((c) => c.terminalCommand != null)
            .toList();
        expect(withCommand.length, greaterThanOrEqualTo(10));
        for (final c in withCommand) {
          final t = TerminalEngine();
          final r = t.run(c.terminalCommand!);
          expect(r.blocked, isFalse, reason: c.id);
          expect(r.exitCode, 0, reason: '${c.id} : ${r.output}');
          if (commandAnswers.contains(c.id)) continue;
          final out = r.output.toLowerCase();
          expect(
            [
              c.answer,
              ...c.acceptedAnswers,
            ].any((a) => out.contains(a.toLowerCase())),
            isTrue,
            reason: '${c.id} : « ${c.answer} » absent de :\n${r.output}',
          );
        }
      },
    );

    test('les réponses-commandes sont acceptées par le terminal', () {
      final t = TerminalEngine();
      expect(t.run('chmod +x scripts/scan_local.sh').exitCode, 0);
      expect(
        t.run('./scripts/scan_local.sh').output,
        contains('Nmap scan report'),
      );
      expect(
        t.run('file documents/notes.pdf').output,
        contains('PDF document'),
      );
    });
  });

  group('Filtres d\'affichage', () {
    test('filtre vide : tous les paquets', () {
      expect(_nos('').length, LabCapture.packets.length);
    });

    test('résultats attendus des exercices', () {
      final ex = {
        for (final e in FilterExercises.all)
          e.id: e.expected(LabCapture.packets),
      };
      expect(ex['ws1'], {12, 13, 14, 15, 16, 17, 18});
      expect(ex['ws2'], {3, 4, 10, 11, 21, 22, 23, 24});
      expect(ex['ws3'], {15, 17});
      expect(ex['ws4'], {17});
      expect(ex['ws5'], {25, 27, 28, 30});
      expect(ex['ws6'], {5, 12, 25, 28, 30});
      expect(ex['ws7'], {21, 22, 23, 24});
      expect(ex['ws8']!.length, LabCapture.packets.length - 3 - 8);
      expect(ex['ws9'], {29, 31});
      for (final e in ex.entries) {
        expect(e.value, isNotEmpty, reason: e.key);
        expect(
          e.value.length,
          lessThan(LabCapture.packets.length),
          reason: e.key,
        );
      }
    });

    test('écritures équivalentes acceptées', () {
      expect(_nos('not arp and not dns'), _nos('!(arp || dns)'));
      expect(
        _nos('ip.src == 192.168.56.10 or ip.dst == 192.168.56.10'),
        _nos('ip.addr == 192.168.56.10'),
      );
      expect(_nos('tcp.flags.syn eq 1 and tcp.flags.ack eq 0'), {
        5,
        12,
        25,
        28,
        30,
      });
      expect(_nos('http.request.method == POST'), {17});
      expect(_nos('tcp.dstport == 443'), {5, 7, 8});
      expect(_nos('tcp.port == 443'), {5, 6, 7, 8, 9});
      expect(_nos('frame.number <= 2'), {1, 2});
      expect(_nos('DNS'), _nos('dns'), reason: 'insensible à la casse');
    });

    test('!= exclut la valeur en source ET en destination', () {
      final shown = _nos('ip.addr != 192.168.1.42');
      for (final p in LabCapture.packets.where((p) => shown.contains(p.no))) {
        expect(p.fields['ip.src'], isNot('192.168.1.42'));
        expect(p.fields['ip.dst'], isNot('192.168.1.42'));
      }
      expect(shown, containsAll([21, 22, 23, 24]));
    });

    test('contains est sensible à la casse', () {
      expect(_nos('dns.qry.name contains "exfil"'), hasLength(4));
      expect(_nos('dns.qry.name contains "EXFIL"'), isEmpty);
    });

    test('erreurs explicites (barre rouge)', () {
      void refused(String f, String fragment) => expect(
        () => DisplayFilter.parse(f),
        throwsA(
          isA<FilterError>().having(
            (e) => e.message,
            'message',
            contains(fragment),
          ),
        ),
      );
      refused('ip.addr = 1.2.3.4', '==');
      refused('ip.adr == 1.2.3.4', 'ni un champ ni un protocole');
      refused('(dns', 'Parenthèse');
      refused('ip.src ==', 'Valeur manquante');
      refused('dns.qry.name contains "abc', 'Guillemet');
      refused('dns arp', 'inattendu');
      refused('dns &', '&&');
    });

    test('les sous-domaines du tunnel DNS se décodent dans le terminal', () {
      final t = TerminalEngine();
      expect(
        t.run('echo cGFzc3dvcmRzLnR4dA | base64 -d').output,
        'passwords.txt',
      );
      expect(t.run('echo aGVsbG8gZnJvbQ | base64 -d').output, 'hello from');
    });

    test('tr : translittération, ROT13 et suppression', () {
      final t = TerminalEngine();
      expect(t.run('echo hello | tr a-z A-Z').output, 'HELLO');
      expect(
        t.run("echo PLOREFRPHEVGR | tr 'A-Z' 'N-ZA-M'").output,
        'CYBERSECURITE',
      );
      expect(t.run('echo a-b-c | tr -d -').output, 'abc');
      expect(t.run('echo x | tr a').output, contains('opérande manquant'));
    });
  });

  group('Récompenses et badges', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<AppState> app() async {
      final a = AppState(secrets: MemorySecretStore());
      await a.ready;
      return a;
    }

    test('exercice Wireshark récompensé une seule fois', () async {
      final a = await app();
      expect(await a.solveFilterExercise('ws1', 20), 20);
      expect(await a.solveFilterExercise('ws1', 20), 0);
      expect(a.user.skills['Réseau']!.xp, 20);
    });

    test('badge Analyste SOC après 10 alertes réussies', () async {
      final a = await app();
      for (final alert in SocCatalog.alerts.take(9)) {
        await a.resolveSocAlert(alert.id, true, 25);
      }
      expect(a.earnedBadges.map((b) => b.badge.id), isNot(contains('b-soc')));
      await a.resolveSocAlert(SocCatalog.alerts[9].id, true, 25);
      expect(a.earnedBadges.map((b) => b.badge.id), contains('b-soc'));
    });

    test('badge Analyste réseau après 5 exercices', () async {
      final a = await app();
      for (final e in FilterExercises.all.take(5)) {
        await a.solveFilterExercise(e.id, e.xp);
      }
      expect(a.earnedBadges.map((b) => b.badge.id), contains('b-wireshark'));
    });
  });
}
