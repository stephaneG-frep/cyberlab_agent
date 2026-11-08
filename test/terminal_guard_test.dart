import 'package:flutter_test/flutter_test.dart';
import 'package:cyberlab_agent/data/ctf_library.dart';
import 'package:cyberlab_agent/services/terminal_engine.dart';

void main() {
  group('Command Guard (règle pédagogique du simulateur)', () {
    const blocked = [
      'rm -rf /',
      'rm -fr /tmp/x',
      'rm -r -f dossier',
      'rm -f -r dossier',
      'rm -Rf dossier',
      'rm --recursive --force dossier',
      'rm --force --recursive dossier',
      'rm -r --force dossier',
      'rm    -rf     dossier',
      'rm "-rf" dossier',
      'sudo rm -rf /',
      'sudo -u root rm -rf /',
      '/bin/rm -rf /',
      'ls && rm -rf /',
      'echo ok; rm -fr ~',
      'cat x | rm -rf y',
      'dd if=/dev/zero of=/dev/sda',
      'sudo dd if=image.iso of=/dev/sdb bs=4M',
    ];
    const allowed = [
      'rm fichier.txt',
      'rm -r dossier',
      'rm -f fichier',
      'rm -- -rf',
      'echo "rm -rf /"',
      "echo 'dd of=/dev/sda'",
      'man rm',
      'grep "rm -rf" notes.txt',
      'dd if=/dev/zero bs=1M count=1',
      'ls -rf',
    ];

    for (final c in blocked) {
      test('bloque : $c', () => expect(CommandGuard.check(c).blocked, isTrue));
    }
    for (final c in allowed) {
      test(
        'autorise : $c',
        () => expect(CommandGuard.check(c).blocked, isFalse),
      );
    }

    test(
      'le moteur applique le guard et le présente comme règle pédagogique',
      () {
        final engine = TerminalEngine();
        final r = engine.run('rm -r -f /');
        expect(r.blocked, isTrue);
        expect(r.exitCode, 1);
        expect(r.output, contains('règle pédagogique'));
      },
    );

    test('guard désactivé : simulation sans aucun effet réel', () {
      final engine = TerminalEngine()..guardEnabled = false;
      final r = engine.run('rm -rf dossier');
      expect(r.blocked, isFalse);
      expect(r.output, contains('simulation'));
    });
  });

  group('Réponses CTF', () {
    final byId = {for (final c in ctfChallenges()) c.id: c};

    test('variantes explicites acceptées', () {
      expect(byId['ctf-linux-1']!.isCorrect('ls -la'), isTrue);
      expect(byId['ctf-net-1']!.isCorrect('transport layer security'), isTrue);
      expect(byId['ctf-web-2']!.isCorrect('HSTS'), isTrue);
      expect(
        byId['ctf-scripting-1']!.isCorrect(
          "grep   'Failed password' auth.log  |  wc -l",
        ),
        isTrue,
      );
    });

    test('commandes sensibles à la casse, pas d\'équivalence implicite', () {
      expect(byId['ctf-linux-1']!.isCorrect('LS -A'), isFalse);
      expect(byId['ctf-linux-1']!.isCorrect('ls -l'), isFalse);
    });

    test('les indices ne contiennent plus la réponse', () {
      for (final c in byId.values) {
        for (final h in c.hints) {
          expect(h.toLowerCase().contains('réponse'), isFalse, reason: c.id);
          expect(c.isCorrect(h), isFalse, reason: '${c.id} : $h');
          if (c.answer.length > 3) {
            expect(
              h.toLowerCase().contains(c.answer.toLowerCase()),
              isFalse,
              reason: '${c.id} : $h',
            );
          }
        }
      }
    });
  });
}
