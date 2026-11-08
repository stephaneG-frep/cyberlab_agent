import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Erreur d'écriture remontée à l'appelant (jamais silencieuse).
class StorageException implements Exception {
  final String message;
  StorageException(this.message);
  @override
  String toString() => message;
}

/// Résultat de lecture : la valeur, et une éventuelle anomalie.
class LoadResult<T> {
  final T value;

  /// Non nul si des données illisibles ont été trouvées (elles sont alors
  /// copiées sous [backupKey] au lieu d'être écrasées).
  final String? backupKey;
  const LoadResult(this.value, {this.backupKey});
}

/// Stockage local (SharedPreferences) — progression, notes, réglages,
/// historique du coach. Les secrets n'y sont PAS stockés (voir SecretStore).
class StorageService {
  static const kUserState = 'user_state';
  static const kNotes = 'notes';
  static const kSettings = 'settings';
  static const kCoachHistory = 'coach_history';

  StorageService({Future<SharedPreferences> Function()? prefsFactory})
    : _prefsFactory = prefsFactory ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _prefsFactory;
  Future<SharedPreferences>? _prefs;

  /// Instance réutilisée (une seule ouverture).
  Future<SharedPreferences> get prefs => _prefs ??= _prefsFactory();

  /// File d'écriture : les écritures sont appliquées dans l'ordre d'appel,
  /// ce qui évite qu'une sauvegarde ancienne n'écrase une plus récente.
  Future<void> _queue = Future.value();

  Future<void> _write(String key, Object value) {
    // Sérialisation immédiate : l'état sauvegardé est celui de l'appel.
    final encoded = jsonEncode(value);
    final op = _queue.then((_) async {
      final p = await prefs;
      final ok = await p.setString(key, encoded);
      if (!ok) throw StorageException('Écriture refusée pour « $key ».');
    });
    _queue = op.catchError((_) {});
    return op;
  }

  /// Attend la fin de toutes les écritures en cours.
  Future<void> flush() => _queue;

  Future<LoadResult<T>> _read<T>(
    String key,
    T Function(Object? decoded) convert,
    T empty,
  ) async {
    final p = await prefs;
    final raw = p.getString(key);
    if (raw == null) return LoadResult(empty);
    try {
      return LoadResult(convert(jsonDecode(raw)));
    } catch (_) {
      // Ne jamais perdre silencieusement des données : copie de secours.
      final backup = '${key}_corrupt_${DateTime.now().millisecondsSinceEpoch}';
      await p.setString(backup, raw);
      return LoadResult(empty, backupKey: backup);
    }
  }

  Future<LoadResult<Map<String, dynamic>?>> loadUserState() =>
      _read(kUserState, (d) => Map<String, dynamic>.from(d as Map), null);

  Future<void> saveUserState(Map<String, dynamic> state) =>
      _write(kUserState, state);

  Future<LoadResult<List<Map<String, dynamic>>>> loadNotes() => _read(
    kNotes,
    (d) => (d as List).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    <Map<String, dynamic>>[],
  );

  Future<void> saveNotes(List<Map<String, dynamic>> notes) =>
      _write(kNotes, notes);

  Future<LoadResult<Map<String, dynamic>>> loadSettings() => _read(
    kSettings,
    (d) => Map<String, dynamic>.from(d as Map),
    <String, dynamic>{},
  );

  Future<void> saveSettings(Map<String, dynamic> settings) =>
      _write(kSettings, settings);

  Future<LoadResult<List<Map<String, dynamic>>>> loadCoachHistory() => _read(
    kCoachHistory,
    (d) => (d as List).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
    <Map<String, dynamic>>[],
  );

  Future<void> saveCoachHistory(List<Map<String, dynamic>> messages) =>
      _write(kCoachHistory, messages);
}
