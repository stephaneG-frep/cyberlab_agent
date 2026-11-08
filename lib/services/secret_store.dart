import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage des secrets (clés API). Les valeurs ne sont jamais journalisées.
abstract class SecretStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Implémentation Android : flutter_secure_storage (chiffrement adossé à
/// l'Android Keystore). Les fichiers correspondants sont exclus des
/// sauvegardes Android (voir android/app/src/main/res/xml/).
class SecureSecretStore implements SecretStore {
  SecureSecretStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Implémentation en mémoire (tests).
class MemorySecretStore implements SecretStore {
  MemorySecretStore({
    Map<String, String>? initial,
    this.failWrites = false,
    this.corruptWrites = false,
  }) : values = {...?initial};

  final Map<String, String> values;

  /// Simule une écriture qui lève une exception.
  bool failWrites;

  /// Simule une écriture « réussie » mais dont la relecture diffère.
  bool corruptWrites;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    if (failWrites) throw Exception('écriture sécurisée indisponible');
    values[key] = corruptWrites ? '' : value;
  }

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// Nom de la clé de stockage sécurisé pour un fournisseur.
String apiKeySlot(String provider) => 'ai_api_key_$provider';
