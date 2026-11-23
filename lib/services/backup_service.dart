import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../models/coach_message.dart';
import '../models/note.dart';
import '../models/user_state.dart';

/// Format d'export : un fichier JSON lisible, versionné.
///
/// Contenu : progression, notes, réglages NON secrets (thème, fournisseur IA,
/// modèle, adresse) et, sur demande, l'historique du coach.
/// Jamais exportés : clés API (stockage sécurisé), ancienne clé v1 en clair,
/// copies de secours `*_corrupt_*`.
class BackupFormat {
  BackupFormat._();
  static const kind = 'cyberlab-agent-backup';
  static const version = 1;

  /// Réglages autorisés dans un export (liste blanche).
  static const exportedSettings = {
    'darkMode',
    'aiProvider',
    'aiProfiles',
    'onboardingDone',
  };

  /// Taille maximale acceptée à l'import (protection mémoire).
  static const maxBytes = 5 * 1024 * 1024;

  static String encode({
    required UserState user,
    required List<Note> notes,
    required Map<String, dynamic> settings,
    List<CoachMessage>? coachHistory,
    String appVersion = '',
    DateTime? now,
  }) {
    final data = <String, dynamic>{
      'kind': kind,
      'version': version,
      'appVersion': appVersion,
      'exportedAt': (now ?? DateTime.now()).toIso8601String(),
      'userState': user.toJson(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'settings': {
        for (final e in settings.entries)
          if (exportedSettings.contains(e.key)) e.key: e.value,
      },
      if (coachHistory != null)
        'coachHistory': coachHistory.map((m) => m.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Analyse un export. Lève [BackupFormatException] avec un message
  /// compréhensible si le fichier n'est pas un export valide.
  static BackupPreview decode(String raw) {
    if (raw.length > maxBytes) {
      throw const BackupFormatException('Fichier trop volumineux.');
    }
    final Object? data;
    try {
      data = jsonDecode(raw);
    } on FormatException {
      throw const BackupFormatException(
        'Ce fichier n\'est pas un export CyberLab (JSON illisible).',
      );
    }
    if (data is! Map || data['kind'] != kind) {
      throw const BackupFormatException(
        'Ce fichier n\'est pas un export CyberLab Agent.',
      );
    }
    final v = data['version'];
    if (v is! int || v > version) {
      throw const BackupFormatException(
        'Export créé par une version plus récente de l\'application : '
        'mettez l\'application à jour avant de l\'importer.',
      );
    }
    final rawUser = data['userState'];
    if (rawUser is! Map) {
      throw const BackupFormatException(
        'Export incomplet : la progression est absente.',
      );
    }
    final user = UserState.fromJson(Map<String, dynamic>.from(rawUser));

    final notes = <Note>[];
    var skipped = 0;
    final rawNotes = data['notes'];
    if (rawNotes is List) {
      for (final n in rawNotes) {
        try {
          notes.add(Note.fromJson(Map<String, dynamic>.from(n as Map)));
        } catch (_) {
          skipped++;
        }
      }
    }

    List<CoachMessage>? coach;
    final rawCoach = data['coachHistory'];
    if (rawCoach is List) {
      coach = [];
      for (final m in rawCoach) {
        final msg = m is Map
            ? CoachMessage.fromJson(Map<String, dynamic>.from(m))
            : null;
        msg == null ? skipped++ : coach.add(msg);
      }
    }

    final rawSettings = data['settings'];
    final settings = <String, dynamic>{
      if (rawSettings is Map)
        for (final e in rawSettings.entries)
          if (exportedSettings.contains(e.key)) '${e.key}': e.value,
    };

    return BackupPreview(
      user: user,
      notes: notes,
      settings: settings,
      coachHistory: coach,
      exportedAt: DateTime.tryParse('${data['exportedAt']}'),
      skippedItems: skipped,
    );
  }

  /// Nom de fichier proposé : cyberlab-sauvegarde-AAAA-MM-JJ.json
  static String fileName(DateTime now) =>
      'cyberlab-sauvegarde-${localDayKey(now)}.json';
}

class BackupFormatException implements Exception {
  final String message;
  const BackupFormatException(this.message);
  @override
  String toString() => message;
}

/// Contenu d'un export, validé, prêt à être confirmé puis appliqué.
class BackupPreview {
  final UserState user;
  final List<Note> notes;
  final Map<String, dynamic> settings;
  final List<CoachMessage>? coachHistory;
  final DateTime? exportedAt;

  /// Éléments illisibles ignorés (notes, messages).
  final int skippedItems;

  const BackupPreview({
    required this.user,
    required this.notes,
    required this.settings,
    required this.coachHistory,
    required this.exportedAt,
    required this.skippedItems,
  });
}

/// Accès aux fichiers (injectable pour les tests).
abstract class BackupFiles {
  /// Enregistre [content] ; retourne false si l'utilisateur a annulé.
  Future<bool> save(String fileName, String content);

  /// Ouvre un fichier choisi par l'utilisateur ; null si annulé.
  Future<String?> open();
}

/// Implémentation Android : sélecteur de fichiers du système (Storage
/// Access Framework). L'utilisateur choisit l'emplacement (Téléchargements,
/// Drive…) ; aucune permission de stockage n'est nécessaire.
class SystemBackupFiles implements BackupFiles {
  const SystemBackupFiles();

  @override
  Future<bool> save(String fileName, String content) async {
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(content)),
      mimeType: 'application/json',
      dialogTitle: 'Enregistrer la sauvegarde CyberLab',
    );
    return uri != null;
  }

  @override
  Future<String?> open() async {
    final files = await FilePicker.pickFiles(
      dialogTitle: 'Choisir une sauvegarde CyberLab',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (files.isEmpty) return null;
    final file = files.first;
    final size = await file.length();
    if (size != null && size > BackupFormat.maxBytes) {
      throw const BackupFormatException('Fichier trop volumineux.');
    }
    return utf8.decode(await file.readAsBytes(), allowMalformed: true);
  }
}
