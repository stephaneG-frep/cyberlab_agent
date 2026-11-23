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
      // Contournements relevés à l'audit.
      r'\rm -rf /',
      r'r\m -rf /',
      'rm dossier -rf',
      'rm --rec --force /',
      'rm --recursive --f x',
      'rm -r --interactive=never x',
      'xargs rm -rf',
      'find . -name x | xargs rm -rf',
      'xargs -n 1 rm -rf',
      'timeout 5 rm -rf /',
      'timeout -s KILL 5 rm -rf /',
      'nice rm -rf /',
      'nice -n 10 rm -rf /',
      'doas rm -rf /',
      'env -i rm -rf /',
      'FOO=1 rm -rf /',
      'bash -c "rm -rf /"',
      "sh -c 'rm -rf ~'",
      'bash -lc "rm -rf /"',
      'sudo su -c "rm -rf /"',
      'eval "rm -rf /"',
      'echo \$(rm -rf /)',
      'echo "\$(rm -rf /)"',
      'echo `rm -rf /`',
      'watch "rm -rf /"',
      'find / -delete',
      'find ~ -name "*" -delete',
      r'find / -exec rm -rf {} \;',
      'find . -exec rm -rf {} +',
      'mkfs.ext4 /dev/sda1',
      'mkfs -t ext4 /dev/sdb',
      'wipefs -a /dev/sda',
      'shred -u secret.txt',
      'chmod -R 777 /',
      'sudo chmod -R 777 /*',
      'chown -R nobody /etc',
      'chmod --recursive 000 /',
      ':(){ :|:& };:',
      'cat /dev/zero > /dev/sda',
      'echo x >/dev/nvme0n1',
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
      'find . -name "*.tmp" -delete',
      'find /var/log -name "*.gz"',
      'chmod -R 755 scripts',
      'chmod 644 /etc/hosts',
      "echo '\$(rm -rf /)'",
      'echo "rm -rf /" > notes.txt',
      'bash script.sh',
      'bash -c "ls -la"',
      'xargs echo',
      'timeout 5 ping localhost',
      'man shred',
      'echo \$((1 + 2))',
      'ls > /dev/null',
      'ls 2>&1',
      'sudo apt install nmap',
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

    test('guard désactivé : seul le système de fichiers VIRTUEL change', () {
      final engine = TerminalEngine()..guardEnabled = false;
      final r = engine.run('rm -rf documents');
      expect(r.blocked, isFalse);
      expect(r.exitCode, 0);
      expect(engine.run('ls').output, isNot(contains('documents')));
      engine.run('labreset');
      expect(engine.run('ls').output, contains('documents'));
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
