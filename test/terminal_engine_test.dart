import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cyberlab_agent/services/terminal_engine.dart';
import 'package:cyberlab_agent/services/virtual_fs.dart';

void main() {
  late TerminalEngine t;
  String run(String c) => t.run(c).output;
  int code(String c) => t.run(c).exitCode;

  setUp(() => t = TerminalEngine());

  group('Navigation et invite', () {
    test('pwd, cd, cd -, cd ~ et invite', () {
      expect(run('pwd'), '/home/learner');
      expect(t.prompt, r'learner@cyberlab:~$');
      run('cd logs');
      expect(run('pwd'), '/home/learner/logs');
      expect(t.prompt, r'learner@cyberlab:~/logs$');
      run('cd /etc');
      expect(t.prompt, r'learner@cyberlab:/etc$');
      expect(run('cd -'), '/home/learner/logs');
      run('cd ~');
      expect(run('pwd'), '/home/learner');
      run('cd ../..');
      expect(run('pwd'), '/');
    });

    test('erreurs de cd', () {
      expect(run('cd nulle_part'), contains('Aucun fichier ou dossier'));
      expect(run('cd notes.txt'), contains('N\'est pas un dossier'));
      expect(run('cd /root'), contains('Permission non accordée'));
    });

    test('ls : fichiers cachés, format long, fichiers multiples', () {
      expect(run('ls'), isNot(contains('.bashrc')));
      expect(run('ls -a'), contains('.bashrc'));
      final long = run('ls -l scripts');
      expect(long, contains('-rwxr-xr-x'));
      expect(long, contains('analyse_logs.sh'));
      expect(
        long,
        contains('-rw-r--r--'),
        reason: 'scan_local.sh non exécutable',
      );
      expect(run('ls *.txt'), 'notes.txt');
    });
  });

  group('Lecture et droits', () {
    test('cat, head, tail, wc sur de vrais fichiers', () {
      expect(run('cat notes.txt'), startsWith('Notes du lab'));
      expect(run('head -n 1 /etc/passwd'), 'root:x:0:0:root:/root:/bin/bash');
      expect(run('tail -1 /etc/passwd'), startsWith('backup:'));
      expect(run('wc -l /etc/passwd'), '6 /etc/passwd');
      expect(
        run('cat absent'),
        'cat: absent: Aucun fichier ou dossier de ce type',
      );
      expect(run('cat logs'), contains('Est un dossier'));
    });

    test('fichiers protégés : refusés à learner, lisibles avec sudo', () {
      expect(run('cat /etc/shadow'), contains('Permission non accordée'));
      expect(code('cat /etc/shadow'), 1);
      final r = run('sudo cat /etc/shadow');
      expect(r, contains('root:'));
      expect(t.user, 'learner', reason: 'sudo ne dure que la commande');
      expect(run('cat /var/log/auth.log'), contains('Permission non accordée'));
      expect(
        run('sudo tail -n 1 /var/log/auth.log'),
        contains('session opened'),
      );
    });

    test('sudo -i puis exit', () {
      run('sudo -i');
      expect(t.user, 'root');
      expect(t.prompt, 'root@cyberlab:~#');
      expect(run('cat flag.txt'), startsWith('FLAG{'));
      run('exit');
      expect(t.user, 'learner');
      expect(run('pwd'), '/home/learner');
    });

    test('chmod sur ses fichiers, chown réservé à root', () {
      run('chmod 600 notes.txt');
      expect(run('ls -l notes.txt'), startsWith('-rw-------'));
      run('chmod go+r notes.txt');
      expect(run('ls -l notes.txt'), startsWith('-rw-r--r--'));
      expect(run('chmod 777 /etc/passwd'), contains('Opération non permise'));
      expect(run('chown root notes.txt'), contains('Opération non permise'));
      run('sudo chown root notes.txt');
      expect(run('ls -l notes.txt'), contains('root'));
    });

    test('mode symbolique et octal', () {
      expect(TerminalEngine.applyMode(420, '+x'), 493);
      expect(TerminalEngine.applyMode(493, 'go-rx'), 448);
      expect(TerminalEngine.applyMode(0, 'u=rw'), 384);
      expect(TerminalEngine.applyMode(0, '640'), 416);
      expect(TerminalEngine.applyMode(0, 'z+q'), isNull);
    });
  });

  group('Tubes, filtres et redirections', () {
    test('analyse de logs : grep | grep -o | sort | uniq -c | sort -nr', () {
      expect(run('grep -c "Failed password" logs/auth.log'), '7');
      expect(
        run(
          'grep "Failed password" logs/auth.log | '
          'grep -oE "[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+" | sort | uniq -c | sort -nr',
        ),
        '      5 203.0.113.7\n      2 192.0.2.44',
      );
    });

    test('cut, awk, sed, sort, uniq, wc', () {
      expect(run('cut -d : -f 1 /etc/passwd | head -2'), 'root\ndaemon');
      expect(
        run("awk -F : '{print \$1, \$NF}' /etc/passwd | head -1"),
        'root /bin/bash',
      );
      expect(
        run("awk '/sqlmap/ {print \$9}' logs/access.log"),
        '403\n500\n400',
      );
      expect(
        run("sed 's/root/ROOT/' /etc/passwd | head -1"),
        'ROOT:x:0:0:root:/root:/bin/bash',
      );
      expect(
        run("sed 's/root/ROOT/g' /etc/passwd | head -1"),
        'ROOT:x:0:0:ROOT:/ROOT:/bin/bash',
      );
      expect(run('echo "b\na\nb" | sort -u'), 'a\nb');
      expect(run('cat logs/access.log | wc -l'), '7');
      expect(run('grep -v sshd logs/auth.log | wc -l'), '1');
      expect(run('grep -i FAILED logs/auth.log | head -1'), contains('Failed'));
      expect(run('grep -n Accepted logs/auth.log'), startsWith('1:'));
    });

    test('grep : code de sortie et recherche récursive', () {
      expect(code('grep introuvable notes.txt'), 1);
      expect(code('grep lab notes.txt'), 0);
      expect(run('grep -rl sqlmap .'), './logs/access.log');
    });

    test('> écrase, >> ajoute, < lit, 2>/dev/null masque les erreurs', () {
      run('echo bonjour > a.txt');
      run('echo suite >> a.txt');
      expect(run('cat a.txt'), 'bonjour\nsuite');
      run('echo neuf > a.txt');
      expect(run('cat a.txt'), 'neuf');
      expect(run('wc -l < a.txt'), '1');
      expect(run('cat absent 2>/dev/null'), '');
      expect(run('cat absent 2>&1 | wc -l'), '1');
      expect(
        run('echo x > /etc/interdit'),
        contains('Permission non accordée'),
      );
      expect(run('ls > /dev/null'), '');
    });

    test('variables, \$?, \$(…), && et ||', () {
      expect(run(r'X=42; echo "val=$X"'), 'val=42');
      expect(run(r'echo $HOME $USER'), '/home/learner learner');
      expect(run(r"echo '$HOME'"), r'$HOME');
      expect(run(r'echo "je suis $(whoami)"'), 'je suis learner');
      expect(run(r'false; echo $?'), '1');
      expect(run('false || echo secours'), 'secours');
      expect(run('false && echo jamais'), '');
      expect(run('true && echo ok'), 'ok');
    });

    test('jokers : correspondances triées, motif sans résultat conservé', () {
      expect(run('echo logs/*.log'), 'logs/access.log logs/auth.log');
      expect(run('echo *.xyz'), '*.xyz');
      expect(
        run('echo "*.txt"'),
        '*.txt',
        reason: 'entre guillemets : pas de joker',
      );
    });

    test('erreurs de syntaxe', () {
      expect(run('ls |'), contains('erreur de syntaxe'));
      expect(run('echo "ouvert'), contains('guillemet non fermé'));
      expect(run('&& ls'), contains('erreur de syntaxe'));
      expect(code('commande_inconnue'), 127);
    });

    test('base64 aller-retour', () {
      expect(run('echo CyberLab | base64'), 'Q3liZXJMYWIK');
      expect(run('echo Q3liZXJMYWIK | base64 -d'), 'CyberLab');
    });
  });

  group('Gestion de fichiers', () {
    test('mkdir -p, touch, cp, mv, rm, rmdir, tree', () {
      run('mkdir -p projet/src');
      run('touch projet/src/main.py');
      expect(run('ls projet/src'), 'main.py');
      run('cp notes.txt projet/');
      expect(run('cat projet/notes.txt'), startsWith('Notes du lab'));
      run('mv projet/notes.txt projet/copie.txt');
      expect(run('ls projet'), 'copie.txt  src/');
      expect(run('rm projet'), contains('Est un dossier'));
      expect(run('rmdir projet'), contains('pas vide'));
      expect(run('tree projet'), contains('main.py'));
      run('rm -r projet');
      expect(run('ls projet'), contains('Aucun fichier'));
      expect(run('cp -x'), contains('opérande'));
    });

    test('find : -name, -type, -user, -delete', () {
      expect(run('find . -name "*.log"'), './logs/access.log\n./logs/auth.log');
      expect(
        run('find scripts -type f'),
        'scripts/analyse_logs.sh\nscripts/scan_local.sh',
      );
      expect(run('find / -name passwd 2>/dev/null'), '/etc/passwd');
      expect(run('find /root'), contains('Permission non accordée'));
      run('mkdir tmp');
      run('touch tmp/a.tmp tmp/b.tmp tmp/garder.txt');
      run('find tmp -name "*.tmp" -delete');
      expect(run('ls tmp'), 'garder.txt');
    });

    test('labreset restaure les fichiers d\'origine', () {
      run('rm notes.txt');
      run('cd /etc');
      run('labreset');
      expect(run('pwd'), '/home/learner');
      expect(run('cat notes.txt'), startsWith('Notes du lab'));
    });
  });

  group('Scripts', () {
    test('./script exige le droit d\'exécution', () {
      final r = run('./scripts/scan_local.sh');
      expect(r, contains('Permission non accordée'));
      expect(r, contains('chmod +x'));
      run('chmod +x scripts/scan_local.sh');
      expect(run('./scripts/scan_local.sh'), contains('Nmap scan report'));
    });

    test('bash script.sh exécute chaque ligne', () {
      final r = run('bash scripts/analyse_logs.sh');
      expect(r, contains('Tentatives échouées :\n7'));
      expect(r, contains('5 203.0.113.7'));
    });

    test('le Command Guard s\'applique aussi aux lignes d\'un script', () {
      run('echo "rm -rf /" > danger.sh');
      final r = run('bash danger.sh');
      expect(r, contains('COMMAND GUARD'));
      expect(run('ls /'), contains('etc/'), reason: 'rien n\'a été supprimé');
    });
  });

  group('Sécurité de la simulation', () {
    test('rm -rf / est bloqué par le guard', () {
      final r = t.run('rm -rf /');
      expect(r.blocked, isTrue);
      expect(run('ls /'), contains('home/'));
    });

    test('guard désactivé : protections de rm et droits Linux simulés', () {
      t.guardEnabled = false;
      expect(run('rm -r /'), contains('dangereux d\'opérer récursivement'));
      expect(
        run('rm -r --no-preserve-root /'),
        contains('Permission non accordée'),
      );
      expect(run('rm -rf /etc'), contains('Permission non accordée'));
      expect(run('ls /etc'), contains('passwd'));
      // Avec root, seul le système de fichiers VIRTUEL est effacé.
      expect(run('sudo rm -r --no-preserve-root /'), contains('VIRTUEL'));
      expect(run('ls /'), '');
      run('labreset');
      expect(run('ls /'), contains('etc/'));
    });

    test('le moteur n\'importe aucun accès système (dart:io)', () {
      for (final f in [
        'lib/services/terminal_engine.dart',
        'lib/services/virtual_fs.dart',
      ]) {
        final src = File(f).readAsStringSync();
        expect(src.contains("import 'dart:io'"), isFalse, reason: f);
        expect(src.contains('Process.'), isFalse, reason: f);
      }
    });

    test('résolution de chemins', () {
      expect(
        VirtualFs.resolve('../etc/./hosts', '/home/learner', '/home/learner'),
        '/home/etc/hosts',
      );
      expect(
        VirtualFs.resolve('~/logs', '/', '/home/learner'),
        '/home/learner/logs',
      );
      expect(VirtualFs.resolve('/../../', '/tmp', '/home/learner'), '/');
    });
  });
}
