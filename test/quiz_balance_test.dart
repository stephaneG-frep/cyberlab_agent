import 'package:flutter_test/flutter_test.dart';
import 'package:cyberlab_agent/data/course_library.dart';
import 'package:cyberlab_agent/models/course.dart';

/// Les QCM ne doivent pas se deviner à la longueur des options.
void main() {
  final qcm = [
    for (final c in CourseLibrary.all)
      for (final q in c.quiz)
        if (q.type == QuizType.qcm) (c.id, q),
  ];

  /// Réussite de « toujours choisir l'option de longueur extrême »
  /// (égalités départagées au hasard).
  double strategy(bool longest) {
    var sum = 0.0;
    for (final (_, q) in qcm) {
      final l = q.options!.map((o) => o.length).toList();
      final target = l.reduce((a, b) => longest == (a > b) ? a : b);
      if (l[int.parse(q.correct)] == target) {
        sum += 1 / l.where((x) => x == target).length;
      }
    }
    return sum / qcm.length;
  }

  test('choisir toujours la plus longue, ou la plus courte, ne paie pas', () {
    final longest = strategy(true), shortest = strategy(false);
    // ignore: avoid_print
    print(
      'la plus longue : ${(longest * 100).round()} %, '
      'la plus courte : ${(shortest * 100).round()} %',
    );
    expect(longest, lessThan(0.40));
    expect(shortest, lessThan(0.40));
  });

  test('la bonne réponse n\'est jamais nettement la plus longue', () {
    for (final (id, q) in qcm) {
      final i = int.parse(q.correct);
      final len = q.options![i].length;
      var max = 0;
      for (var k = 0; k < q.options!.length; k++) {
        if (k != i && q.options![k].length > max) max = q.options![k].length;
      }
      expect(
        len > max * 1.25 && len - max >= 4,
        isFalse,
        reason: '$id/${q.id} : ${q.options}',
      );
    }
  });

  test('options toutes différentes et non vides', () {
    for (final (id, q) in qcm) {
      final o = q.options!.map((s) => s.trim().toLowerCase()).toList();
      expect(o.toSet().length, o.length, reason: '$id/${q.id}');
      expect(o.every((s) => s.isNotEmpty), isTrue, reason: '$id/${q.id}');
    }
  });
}
