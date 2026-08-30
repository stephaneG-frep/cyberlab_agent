import 'package:flutter_test/flutter_test.dart';
import 'package:cyberlab_agent/models/user_state.dart';
import 'package:cyberlab_agent/models/course.dart';
import 'package:cyberlab_agent/models/note.dart';

void main() {
  group('UserState', () {
    test('XP et niveau', () {
      final u = UserState();
      expect(u.level, 1);
      u.addXp(500);
      expect(u.level, 2);
      u.addXp(500);
      expect(u.level, 2); // 1000 total -> level 3 car 500+1000 atteint
      expect(u.xp, 1000);
    });

    test('sérialisation aller-retour', () {
      final u = UserState(name: 'Test', xp: 1200, streak: 3);
      u.completedCourses.add('c1');
      u.skills['linux'] = SkillProgress(name: 'linux', xp: 100);
      final back = UserState.fromJson(u.toJson());
      expect(back.name, 'Test');
      expect(back.xp, 1200);
      expect(back.streak, 3);
      expect(back.completedCourses, contains('c1'));
      expect(back.skills['linux']!.xp, 100);
    });

    test('niveau calculé depuis le progrès', () {
      final u = UserState(xp: 0);
      expect(u.progressToNext, 0);
      u.addXp(250);
      expect(u.progressToNext, 50);
    });
  });

  group('QuizQuestion', () {
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
    });

    test('isCorrect sans réponse', () {
      final q = QuizQuestion(
        id: 'q3',
        type: QuizType.free,
        question: 'Question',
        explanation: 'e',
      );
      expect(q.isCorrect(''), isFalse);
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
