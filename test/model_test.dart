import 'package:flutter_test/flutter_test.dart';
import 'package:cyberlab_agent/models/user_state.dart';
import 'package:cyberlab_agent/models/course.dart';
import 'package:cyberlab_agent/models/note.dart';

void main() {
  group('Niveaux (seuils cumulés 0 / 500 / 1500 / 3000 / 5000)', () {
    test('seuils de début de niveau', () {
      expect(LevelMath.startXp(1), 0);
      expect(LevelMath.startXp(2), 500);
      expect(LevelMath.startXp(3), 1500);
      expect(LevelMath.startXp(4), 3000);
      expect(LevelMath.startXp(5), 5000);
    });

    test('juste avant, sur et après chaque seuil', () {
      for (var lvl = 2; lvl <= 8; lvl++) {
        final t = LevelMath.startXp(lvl);
        expect(LevelMath.levelFor(t - 1), lvl - 1, reason: 'avant $t');
        expect(LevelMath.levelFor(t), lvl, reason: 'sur $t');
        expect(LevelMath.levelFor(t + 1), lvl, reason: 'après $t');
      }
    });

    test('progression entre début du niveau actuel et suivant', () {
      expect(UserState(xp: 0).progressToNext, 0);
      expect(UserState(xp: 250).progressToNext, 50);
      expect(UserState(xp: 499).progressToNext, 99);
      final at500 = UserState(xp: 500);
      expect(at500.level, 2);
      expect(at500.progressToNext, 0);
      expect(at500.xpForNextLevel, 1500);
      // Ancien bug : la barre restait bloquée à 100 % entre 1000 et 1500.
      expect(UserState(xp: 1000).progressToNext, 50);
      expect(UserState(xp: 1499).progressToNext, 99);
      final at1500 = UserState(xp: 1500);
      expect(at1500.level, 3);
      expect(at1500.progressToNext, 0);
      expect(UserState(xp: 2250).progressToNext, 50);
    });

    test('le niveau stocké est recalculé depuis les XP', () {
      final u = UserState(xp: 1600, level: 99);
      expect(u.level, 3);
    });

    test('sérialisation aller-retour', () {
      final u = UserState(name: 'Test', xp: 1200, streak: 3);
      u.completedCourses.add('c1');
      u.rewardedKeys.add(RewardKeys.course('c1'));
      u.skills['linux'] = SkillProgress(name: 'linux', xp: 100);
      u.lastActiveDay = '2026-11-08';
      u.learningSeconds = 125;
      final back = UserState.fromJson(u.toJson());
      expect(back.name, 'Test');
      expect(back.xp, 1200);
      expect(back.level, 2);
      expect(back.streak, 3);
      expect(back.completedCourses, contains('c1'));
      expect(back.rewardedKeys, contains('course:c1'));
      expect(back.skills['linux']!.xp, 100);
      expect(back.lastActiveDay, '2026-11-08');
      expect(back.learningSeconds, 125);
      expect(back.learningMinutes, 2);
    });
  });

  group('QuizQuestion', () {
    QuizQuestion free(
      String correct, {
      List<String> accept = const [],
      bool cs = false,
      QuizType type = QuizType.free,
    }) => QuizQuestion(
      id: 'f',
      type: type,
      question: 'Q',
      correctAnswer: correct,
      explanation: 'e',
      acceptedAnswers: accept,
      caseSensitive: cs,
    );

    test('isCorrect qcm', () {
      final q = QuizQuestion(
        id: 'q1',
        type: QuizType.qcm,
        question: 'Question',
        options: ['a', 'b', 'c'],
        correctAnswer: '1',
        explanation: 'e',
      );
      expect(q.isCorrect('1'), isTrue);
      expect(q.isCorrect('0'), isFalse);
      expect(q.displayCorrect, 'b', reason: 'réponse lisible, pas l\'index');
    });

    test('isCorrect trueFalse (insensible à la casse)', () {
      final q = QuizQuestion(
        id: 'q2',
        type: QuizType.trueFalse,
        question: 'Question',
        correctAnswer: 'Vrai',
        explanation: 'e',
      );
      expect(q.isCorrect('vrai'), isTrue);
      expect(q.isCorrect('Faux'), isFalse);
    });

    test('isCorrect sans réponse ou réponse vide', () {
      final q = QuizQuestion(
        id: 'q3',
        type: QuizType.free,
        question: 'Question',
        explanation: 'e',
      );
      expect(q.isCorrect(''), isFalse);
      expect(free('tls').isCorrect('   '), isFalse);
    });

    test('variantes explicites et normalisation prudente des espaces', () {
      final q = free('brute-force', accept: ['force brute']);
      expect(q.isCorrect('  Brute-Force '), isTrue);
      expect(q.isCorrect('force   brute'), isTrue);
      expect(q.isCorrect('bruteforce'), isFalse, reason: 'non listée');
    });

    test('casse respectée quand le contenu l\'exige', () {
      final q = free('ls -a', cs: true, type: QuizType.practical);
      expect(q.isCorrect('ls   -a'), isTrue);
      expect(q.isCorrect('LS -A'), isFalse);
      expect(q.isCorrect('ls -la'), isFalse, reason: 'pas d\'équivalence auto');
    });

    test('l\'indice générique ne révèle pas la réponse', () {
      final qcm = QuizQuestion(
        id: 'q',
        type: QuizType.qcm,
        question: 'Q',
        options: ['Confidentialité', 'Vitesse'],
        correctAnswer: '0',
        explanation: 'e',
      );
      expect(qcm.hintText.contains('Confidentialité'), isFalse);
      final f = free('chiffrement');
      expect(f.hintText.toLowerCase().contains('chiffrement'), isFalse);
      final custom = QuizQuestion(
        id: 'q',
        type: QuizType.free,
        question: 'Q',
        correctAnswer: 'x',
        explanation: 'e',
        hint: 'Indice spécifique',
      );
      expect(custom.hintText, 'Indice spécifique');
    });
  });

  group('Note', () {
    test('sérialisation', () {
      final n = Note(id: '1', title: 't', content: 'c', category: 'Linux');
      final back = Note.fromJson(n.toJson());
      expect(back.id, '1');
      expect(back.title, 't');
      expect(back.content, 'c');
      expect(back.category, 'Linux');
    });
  });
}
