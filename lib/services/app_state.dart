import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../models/user_state.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService storage = StorageService();
  UserState user;
  List<Note> notes = [];
  Map<String, dynamic> settings = {};
  bool loaded = false;

  AppState() : user = UserState() {
    _init();
  }

  Future<void> _init() async {
    final u = await storage.loadUserState();
    if (u != null) user = UserState.fromJson(u);
    final n = await storage.loadNotes();
    notes = n.map((e) => Note.fromJson(e)).toList();
    settings = await storage.loadSettings();
    loaded = true;
    notifyListeners();
  }

  UserState get userState => user;

  Future<void> _persist() async {
    await storage.saveUserState(user.toJson());
    notifyListeners();
  }

  void addXp(int amount, {String? skill}) {
    user.addXp(amount);
    if (skill != null) {
      if (!user.skills.containsKey(skill)) {
        user.skills[skill] = SkillProgress(name: skill);
      }
      user.skills[skill]!.addXp(amount);
    }
    _persist();
  }

  void completeCourse(String courseId, String skillName, int xp) {
    if (!user.completedCourses.contains(courseId)) {
      user.completedCourses.add(courseId);
      addXp(xp, skill: skillName);
    }
  }

  void recordQuizResult(String questionId, bool correct) {
    user.quizResults[questionId] = correct ? 1 : 0;
    _persist();
  }

  void recordAttempt(String courseId) {
    user.courseAttempts[courseId] = (user.courseAttempts[courseId] ?? 0) + 1;
    _persist();
  }

  void solveChallenge(String challengeId, int xp) {
    if (!user.solvedChallenges.contains(challengeId)) {
      user.solvedChallenges.add(challengeId);
      addXp(xp, skill: 'CTF');
    }
  }

  void addStreak() {
    user.streak += 1;
    _persist();
  }

  void setName(String name) {
    user.name = name;
    _persist();
  }

  void setPath(String path) {
    user.selectedPath = path;
    _persist();
  }

  Future<void> resetProgress() async {
    user = UserState(name: user.name);
    notes = [];
    await storage.saveUserState(user.toJson());
    await storage.saveNotes([]);
    notifyListeners();
  }

  Future<void> addNote(Note n) async {
    notes.insert(0, n);
    await storage.saveNotes(notes.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  Future<void> updateNote(Note n) async {
    final i = notes.indexWhere((e) => e.id == n.id);
    if (i >= 0) {
      n.updatedAt = DateTime.now();
      notes[i] = n;
      await storage.saveNotes(notes.map((e) => e.toJson()).toList());
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    notes.removeWhere((e) => e.id == id);
    await storage.saveNotes(notes.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  Future<void> toggleNoteFavorite(String id) async {
    final i = notes.indexWhere((e) => e.id == id);
    if (i >= 0) {
      notes[i].favorite = !notes[i].favorite;
      await storage.saveNotes(notes.map((e) => e.toJson()).toList());
      notifyListeners();
    }
  }

  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    settings = newSettings;
    await storage.saveSettings(settings);
    notifyListeners();
  }
}
