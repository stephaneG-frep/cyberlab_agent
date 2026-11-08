import 'package:flutter_test/flutter_test.dart';
import 'package:cyberlab_agent/data/course_content.dart';
import 'package:cyberlab_agent/data/course_linux.dart';
import 'package:cyberlab_agent/data/course_networking.dart';
import 'package:cyberlab_agent/data/course_bash.dart';
import 'package:cyberlab_agent/data/course_python.dart';
import 'package:cyberlab_agent/data/course_web.dart';
import 'package:cyberlab_agent/data/course_library.dart';
import 'package:cyberlab_agent/data/ctf_library.dart';
import 'package:cyberlab_agent/data/cheat_sheets.dart';
import 'package:cyberlab_agent/data/badges.dart';

void main() {
  group('Cours', () {
    test('toutes les catégories sont présentes et non vides', () {
      expect(fundamentalsCourses().length, greaterThanOrEqualTo(10));
      expect(linuxCourses().length, greaterThanOrEqualTo(15));
      expect(networkingCourses().length, greaterThanOrEqualTo(15));
      expect(bashCourses().length, greaterThanOrEqualTo(10));
      expect(pythonCourses().length, greaterThanOrEqualTo(10));
      expect(webSecurityCourses().length, greaterThanOrEqualTo(10));
    });

    test('la bibliothèque regroupe tous les cours sans doublon d\'id', () {
      final all = CourseLibrary.all;
      final ids = all.map((c) => c.id).toSet();
      expect(
        ids.length,
        all.length,
        reason: 'ids de cours doivent être uniques',
      );
      expect(all.length, greaterThanOrEqualTo(60));
    });

    test('chaque cours est complet (summary, quiz, exercises, mistakes)', () {
      for (final c in CourseLibrary.all) {
        expect(c.title, isNotEmpty, reason: '${c.id} titre');
        expect(c.summary, isNotEmpty, reason: '${c.id} summary');
        expect(c.sections, isNotEmpty, reason: '${c.id} sections');
        expect(c.commonMistakes, isNotEmpty, reason: '${c.id} commonMistakes');
        expect(c.quiz, isNotEmpty, reason: '${c.id} quiz');
        expect(c.exercises, isNotEmpty, reason: '${c.id} exercises');
        expect(c.objectives, isNotEmpty, reason: '${c.id} objectives');

        for (final q in c.quiz) {
          expect(q.id, isNotEmpty, reason: '${c.id} quiz id');
          expect(q.question, isNotEmpty, reason: '${c.id} quiz question');
          expect(q.correctAnswer, isNotEmpty, reason: '${c.id} answer');
          expect(q.explanation, isNotEmpty, reason: '${c.id} explanation');
        }
      }
    });

    test('tous les éléments objectives/prérequis sont des chaînes', () {
      for (final c in CourseLibrary.all) {
        for (final o in c.objectives) {
          expect(o, isA<String>(), reason: '${c.id} objectives');
        }
      }
    });
  });

  group('CTF', () {
    test('au moins 10 challenges avec tous les champs', () {
      final all = ctfChallenges();
      expect(all.length, greaterThanOrEqualTo(10));
      final ids = all.map((c) => c.id).toSet();
      expect(ids.length, all.length);
      for (final c in all) {
        expect(c.title, isNotEmpty);
        expect(c.answer, isNotEmpty);
        expect(c.explanation, isNotEmpty);
        expect(c.hints, isNotEmpty);
        expect(c.difficultyRank, inInclusiveRange(1, 5));
      }
    });
  });

  group('Cheat Sheets', () {
    test('au moins 9 fiches non vides', () {
      final all = cheatSheets();
      expect(all.length, greaterThanOrEqualTo(9));
      for (final s in all) {
        expect(s.title, isNotEmpty);
        expect(s.entries, isNotEmpty);
      }
    });
  });

  group('Badges', () {
    test('les badges sont valides', () {
      final all = badgeDefs();
      expect(all.length, greaterThanOrEqualTo(5));
      for (final d in all) {
        expect(d.badge.id, isNotEmpty);
        expect(d.badge.name, isNotEmpty);
      }
    });
  });
}
