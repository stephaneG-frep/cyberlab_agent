import 'package:flutter_test/flutter_test.dart';
import 'package:cyberlab_agent/data/course_library.dart';
import 'package:cyberlab_agent/data/terminal_exercises.dart';
import 'package:cyberlab_agent/services/terminal_engine.dart';

/// Exécute [commands] dans un terminal neuf et retourne l'état des critères.
List<bool> _play(TerminalExercise ex, List<String> commands) {
  final engine = TerminalEngine();
  final done = List.filled(ex.checks.length, false);
  for (final c in commands) {
    final r = engine.run(c);
    for (var i = 0; i < ex.checks.length; i++) {
      final check = ex.checks[i];
      final ok = check.test(engine, c, r.output);
      done[i] = check.latched ? (done[i] || ok) : ok;
    }
  }
  return done;
}

void main() {
  final ids = CourseLibrary.all.map((c) => c.id).toSet();

  test('au moins 30 exercices, chacun rattaché à un cours existant', () {
    expect(terminalExercises.length, greaterThanOrEqualTo(30));
    for (final e in terminalExercises.values) {
      expect(ids, contains(e.courseId));
      expect(e.checks, isNotEmpty, reason: e.courseId);
      expect(e.instruction.trim(), isNotEmpty);
      expect(e.hint.trim(), isNotEmpty);
    }
    final linux = CourseLibrary.byCategory('linux');
    final bash = CourseLibrary.byCategory('bash');
    expect(
      linux.where((c) => terminalExercises.containsKey(c.id)).length,
      greaterThanOrEqualTo(15),
    );
    expect(
      bash.where((c) => terminalExercises.containsKey(c.id)).length,
      bash.length,
      reason: 'chaque cours Bash a un exercice vérifié',
    );
  });

  for (final ex in terminalExercises.values) {
    test('${ex.courseId} : la solution de référence valide tout', () {
      final done = _play(ex, ex.solution.split('\n'));
      for (var i = 0; i < done.length; i++) {
        expect(
          done[i],
          isTrue,
          reason: '${ex.courseId} : « ${ex.checks[i].label} »',
        );
      }
    });

    test('${ex.courseId} : rien n\'est validé sans travail', () {
      final done = _play(ex, ['ls', 'pwd', 'help']);
      expect(done.every((d) => d), isFalse, reason: ex.courseId);
    });
  }

  test('un critère d\'état se décoche si l\'état change', () {
    final ex = terminalExercises['lin-chmod']!;
    expect(_play(ex, ['chmod 600 notes.txt']), [true]);
    expect(_play(ex, ['chmod 600 notes.txt', 'chmod 644 notes.txt']), [false]);
  });

  test('les variantes raisonnables sont acceptées', () {
    expect(
      _play(terminalExercises['lin-navigation']!, [
        'mkdir rapports/2026',
        'cp ~/notes.txt ~/rapports/2026/notes.txt',
      ]),
      [true, true],
    );
    expect(
      _play(terminalExercises['bash-parsing']!, [
        "cut -d ' ' -f 9 logs/access.log",
      ]),
      [true, true],
    );
    expect(
      _play(terminalExercises['bash-loops']!, [
        r'for n in $(seq 1 3); do touch ~/rapports/fichier$n.txt; done',
      ]),
      [true, true, true, true],
    );
  });

  group('Shell : structures de contrôle', () {
    late TerminalEngine t;
    String run(String c) => t.run(c).output;
    setUp(() => t = TerminalEngine());

    test('for, if/elif/else, while, until', () {
      expect(run(r'for i in 1 2 3; do echo n$i; done'), 'n1\nn2\nn3');
      expect(
        run(r'for f in logs/*.log; do echo $f; done'),
        'logs/access.log\nlogs/auth.log',
      );
      expect(
        run('if [ -f notes.txt ]; then echo oui; else echo non; fi'),
        'oui',
      );
      expect(
        run(
          'if [ -d x ]; then echo a; elif [ -d logs ]; then echo b; else echo c; fi',
        ),
        'b',
      );
      expect(
        run(r'i=0; while [ $i -lt 3 ]; do echo $i; i=$((i+1)); done'),
        '0\n1\n2',
      );
      expect(
        run(r'i=0; until [ $i -ge 2 ]; do echo $i; i=$((i+1)); done'),
        '0\n1',
      );
    });

    test('break, continue, fonctions et return', () {
      expect(
        run(
          r'for x in a b c; do if [ $x = b ]; then continue; fi; echo $x; done',
        ),
        'a\nc',
      );
      expect(
        run(r'for x in a b c; do if [ $x = b ]; then break; fi; echo $x; done'),
        'a',
      );
      run(r'salut() { echo Salut $1; }');
      expect(run('salut monde'), 'Salut monde');
      run(
        r'pair() { if [ $(( $1 % 2 )) -eq 0 ]; then return 0; fi; return 1; }',
      );
      expect(run('pair 4 && echo pair'), 'pair');
      expect(run('pair 3 || echo impair'), 'impair');
    });

    test('script multi-lignes avec arguments, commentaires et "\$@"', () {
      run(r'''echo '#!/bin/bash' > s.sh''');
      run(r'''echo '# commentaire' >> s.sh''');
      run(r'''echo 'echo "$# arguments"' >> s.sh''');
      run(r'''echo 'for a in "$@"; do' >> s.sh''');
      run(r'''echo '  echo "- $a"' >> s.sh''');
      run(r'''echo 'done' >> s.sh''');
      expect(run('bash s.sh un deux'), '2 arguments\n- un\n- deux');
      expect(
        run(r'echo $1'),
        '',
        reason: 'arguments restaurés après le script',
      );
    });

    test('arithmétique, test et seq', () {
      expect(
        run(r'echo $((7 * 6)) $((10 / 3)) $((10 % 3)) $((2 + 3 * 4))'),
        '42 3 1 14',
      );
      expect(run(r'x=5; echo $((x * 2))'), '10');
      expect(run('echo \$((1 / 0))'), contains('division par zéro'));
      expect(run('[ abc = abc ] && echo égal'), 'égal');
      expect(run('[ 3 -gt 5 ] || echo non'), 'non');
      expect(run('test -x scripts/analyse_logs.sh && echo x'), 'x');
      expect(run('[ -z "" ] && echo vide'), 'vide');
      expect(run('[ 3 -gt'), contains('« ] » manquant'));
      expect(run('seq 3'), '1\n2\n3');
      expect(run('seq 2 2 6'), '2\n4\n6');
    });

    test('découpage en mots des développements non protégés', () {
      expect(run(r'for i in $(seq 1 3); do echo [$i]; done'), '[1]\n[2]\n[3]');
      expect(run(r'X="a   b"; echo "$X"'), 'a   b');
      expect(run(r'E=""; echo [$E]'), '[]');
    });

    test('boucle infinie interrompue, erreurs de syntaxe claires', () {
      expect(run('while true; do true; done'), contains('interrompue'));
      expect(run('if [ 1 ]; then echo a'), contains('attendu'));
      expect(run('done'), contains('inattendu'));
      expect(
        run('for i in 1; do echo x; done | sort'),
        contains('pas pris en charge'),
      );
    });

    test('le Command Guard voit dans les boucles et les fonctions', () {
      expect(t.run(r'for f in *; do rm -rf $f; done').blocked, isTrue);
      expect(t.run('boom() { rm -rf /; }').blocked, isTrue);
      expect(t.run('if true; then rm -rf /; fi').blocked, isTrue);
      expect(
        t.run('while true; do dd if=/dev/zero of=/dev/sda; done').blocked,
        isTrue,
      );
      expect(run('ls /'), contains('etc/'));
    });

    test('sha256sum respecte echo -n', () {
      expect(
        run('echo -n bonjour | sha256sum'),
        '2cb4b1431b84ec15d35ed83bb927e27e8967d75f4bcd9cc4b25c8d879ae23e18  -',
      );
      expect(
        run('echo bonjour | sha256sum'),
        isNot(startsWith('2cb4b1431b84ec15')),
        reason: 'avec saut de ligne, empreinte différente',
      );
      expect(
        run('echo -n abc | md5sum'),
        '900150983cd24fb0d6963f7d28e17f72  -',
      );
      expect(run('echo -n abc | base64'), 'YWJj');
    });
  });
}
