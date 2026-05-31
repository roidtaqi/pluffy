import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthSessionStorageBackend {
  Future<String?> read({required String key});

  Future<void> write({required String key, required String value});

  Future<void> delete({required String key});
}

AuthSessionStorageBackend createAuthSessionStorageBackend() {
  if (Platform.isLinux) {
    return _LinuxFileAuthSessionStorageBackend();
  }

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

class _LinuxFileAuthSessionStorageBackend implements AuthSessionStorageBackend {
  late final File _file = File(
    '${Platform.environment['HOME'] ?? Directory.systemTemp.path}'
    '/.config/pluffy/auth_session.json',
  );

  @override
  Future<String?> read({required String key}) async {
    final values = await _readValues();
    return values[key];
  }

  @override
  Future<void> write({required String key, required String value}) async {
    final values = await _readValues();
    values[key] = value;
    await _writeValues(values);
  }

  @override
  Future<void> delete({required String key}) async {
    final values = await _readValues();
    values.remove(key);

    if (values.isEmpty) {
      if (await _file.exists()) {
        await _file.delete();
      }
      return;
    }

    await _writeValues(values);
  }

  Future<Map<String, String>> _readValues() async {
    if (!await _file.exists()) {
      return {};
    }

    try {
      final decoded = jsonDecode(await _file.readAsString());
      if (decoded is! Map<String, dynamic>) {
        return {};
      }

      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeValues(Map<String, String> values) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(jsonEncode(values), flush: true);
    await Process.run('chmod', ['600', _file.path]);
  }
}
