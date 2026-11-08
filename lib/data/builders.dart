import '../models/course.dart';

/// Small fluent builders to keep course definition concise and readable.
ContentBlock text(String t) => ContentBlock(type: BlockType.text, text: t);
ContentBlock code(String t, {String? label}) =>
    ContentBlock(type: BlockType.code, text: t, label: label);
ContentBlock list(String t) => ContentBlock(type: BlockType.list, text: t);
ContentBlock warn(String t) => ContentBlock(type: BlockType.warning, text: t);
ContentBlock tip(String t) => ContentBlock(type: BlockType.tip, text: t);
ContentBlock note(String t) => ContentBlock(type: BlockType.note, text: t);

ContentSection sec(String title, List<ContentBlock> blocks) =>
    ContentSection(title: title, blocks: blocks);

QuizQuestion q(
  List<Object?> parts, {
  String? hint,
  List<String> accept = const [],
  bool caseSensitive = false,
}) {
  // parts: id, question, type, options|correct, [correct index], explanation
  // hint : indice pédagogique facultatif (sans la réponse)
  // accept : variantes explicitement acceptées pour les réponses libres
  final type = _typeFor(parts[2] as String);
  final isQcm = type == QuizType.qcm;
  return QuizQuestion(
    id: parts[0] as String,
    question: parts[1] as String,
    type: type,
    options: isQcm ? (parts[3] as String).split('|') : null,
    correctAnswer: isQcm ? parts[4] as String : (parts[3] as String),
    explanation: parts.length > 5 && parts[5] != null ? parts[5] as String : '',
    hint: hint,
    acceptedAnswers: accept,
    caseSensitive: caseSensitive,
  );
}

QuizType _typeFor(String t) {
  switch (t) {
    case 'tf':
      return QuizType.trueFalse;
    case 'free':
      return QuizType.free;
    case 'prac':
      return QuizType.practical;
    default:
      return QuizType.qcm;
  }
}

ExerciseStep ex(String title, String instruction) =>
    ExerciseStep(title: title, instruction: instruction);
