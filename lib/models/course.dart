enum QuizType { qcm, trueFalse, free, practical }

class QuizQuestion {
  final String id;
  final QuizType type;
  final String question;
  final String? codeSnippet;
  final List<String>? options; // for qcm
  final String? correctAnswer; // index (qcm) or 'true'/'false' or free text
  final String explanation;
  final int xp;

  QuizQuestion({
    required this.id,
    required this.type,
    required this.question,
    this.codeSnippet,
    this.options,
    this.correctAnswer,
    required this.explanation,
    this.xp = 10,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> j) {
    return QuizQuestion(
      id: j['id'] ?? '',
      type: QuizType.values.firstWhere(
        (e) => e.name == j['type'],
        orElse: () => QuizType.qcm,
      ),
      question: j['question'] ?? '',
      codeSnippet: j['code'],
      options: (j['options'] as List?)?.cast<String>(),
      correctAnswer: j['correct'],
      explanation: j['explanation'] ?? '',
      xp: j['xp'] ?? 10,
    );
  }

  bool isCorrect(String answer) {
    if (correctAnswer == null) return false;
    switch (type) {
      case QuizType.qcm:
        return answer == correct.toString();
      case QuizType.trueFalse:
        return answer.toLowerCase() == correct.toString().toLowerCase();
      case QuizType.free:
        return answer.trim().toLowerCase() ==
            correct.toString().trim().toLowerCase();
      case QuizType.practical:
        return answer.trim().toLowerCase() ==
            correct.toString().trim().toLowerCase();
    }
  }

  String get correct => correctAnswer ?? '';
}

class QuizSection {
  final String title;
  final List<QuizQuestion> questions;

  QuizSection({required this.title, required this.questions});
}

class ExerciseStep {
  final String title;
  final String instruction;

  ExerciseStep({required this.title, required this.instruction});
}

class Course {
  final String id;
  final String title;
  final String
  category; // fundamentals | linux | networking | bash | python | web_security | ...
  final String level; // level name
  final int levelNumber;
  final List<String> objectives;
  final List<String> prerequisites;
  final List<ContentSection> sections;
  final List<String> commonMistakes;
  final String summary;
  final List<QuizQuestion> quiz;
  final List<ExerciseStep> exercises;
  final int xp;

  Course({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.levelNumber,
    required this.objectives,
    required this.prerequisites,
    required this.sections,
    required this.commonMistakes,
    required this.summary,
    required this.quiz,
    required this.exercises,
    this.xp = 100,
  });

  factory Course.fromJson(Map<String, dynamic> j) {
    return Course(
      id: j['id'] ?? '',
      title: j['title'] ?? '',
      category: j['category'] ?? 'fundamentals',
      level: j['level'] ?? '',
      levelNumber: j['levelNumber'] ?? 0,
      objectives: (j['objectives'] as List?)?.cast<String>() ?? [],
      prerequisites: (j['prerequisites'] as List?)?.cast<String>() ?? [],
      sections: (j['sections'] as List? ?? [])
          .map((s) => ContentSection.fromJson(s as Map<String, dynamic>))
          .toList(),
      commonMistakes: (j['commonMistakes'] as List?)?.cast<String>() ?? [],
      summary: j['summary'] ?? '',
      quiz: (j['quiz'] as List? ?? [])
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      exercises: (j['exercises'] as List? ?? [])
          .map(
            (e) => ExerciseStep(
              title: e['title'] ?? '',
              instruction: e['instruction'] ?? '',
            ),
          )
          .toList(),
      xp: j['xp'] ?? 100,
    );
  }
}

class ContentSection {
  final String title;
  final List<ContentBlock> blocks;

  ContentSection({required this.title, required this.blocks});

  factory ContentSection.fromJson(Map<String, dynamic> j) {
    return ContentSection(
      title: j['title'] ?? '',
      blocks: (j['blocks'] as List? ?? [])
          .map((b) => ContentBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }
}

enum BlockType { text, code, list, warning, tip, note }

class ContentBlock {
  final BlockType type;
  final String text;
  final String? label;

  ContentBlock({required this.type, required this.text, this.label});

  factory ContentBlock.fromJson(Map<String, dynamic> j) {
    return ContentBlock(
      type: BlockType.values.firstWhere(
        (e) => e.name == j['type'],
        orElse: () => BlockType.text,
      ),
      text: j['text'] ?? '',
      label: j['label'],
    );
  }
}
