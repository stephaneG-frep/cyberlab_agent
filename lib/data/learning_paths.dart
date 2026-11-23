import 'package:flutter/material.dart';
import '../models/course.dart';
import 'course_library.dart';

/// Parcours d'apprentissage : un parcours correspond à une catégorie de
/// cours. Il oriente l'accueil (« Continuer ma formation ») et l'onglet
/// Apprendre ; tous les cours restent accessibles quel que soit le parcours.
class LearningPath {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  const LearningPath(this.id, this.label, this.description, this.icon);

  List<Course> get courses => CourseLibrary.byCategory(id);
}

class LearningPaths {
  LearningPaths._();

  static const defaultId = 'fundamentals';

  static const all = [
    LearningPath(
      'fundamentals',
      'Fondamentaux',
      'Point de départ conseillé : vocabulaire, menaces, bonnes pratiques.',
      Icons.auto_stories,
    ),
    LearningPath(
      'linux',
      'Linux',
      'Terminal, fichiers, droits, processus et journaux.',
      Icons.terminal,
    ),
    LearningPath(
      'networking',
      'Réseau',
      'Modèle OSI, TCP/IP, ports, protocoles et analyse de trafic.',
      Icons.hub,
    ),
    LearningPath(
      'bash',
      'Bash',
      'Scripts shell pour automatiser l\'analyse et l\'administration.',
      Icons.code,
    ),
    LearningPath(
      'python',
      'Python',
      'Programmation appliquée à la sécurité : parsing, réseau, outils.',
      Icons.smart_toy,
    ),
    LearningPath(
      'web_security',
      'Sécurité Web',
      'HTTP, OWASP Top 10, injections et défenses.',
      Icons.language,
    ),
  ];

  static bool isValid(String id) => all.any((p) => p.id == id);

  static LearningPath byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => all.first);
}
