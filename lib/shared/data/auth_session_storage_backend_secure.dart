import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthSessionStorageBackend {
  Future<String?> read({required String key});

  Future<void> write({required String key, required String value});

  Future<void> delete({required String key});
}

AuthSessionStorageBackend createAuthSessionStorageBackend() {
  return _SecureAuthSessionStorageBackend();
}

class _SecureAuthSessionStorageBackend implements AuthSessionStorageBackend {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(migrateWithBackup: true),
  );

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);
}
