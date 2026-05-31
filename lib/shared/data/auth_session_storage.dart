import 'dart:convert';

import 'auth_session_storage_backend.dart';

class StoredAuthSession {
  final String token;
  final Map<String, dynamic> userJson;

  const StoredAuthSession({required this.token, required this.userJson});
}

class AuthSessionStorage {
  static const _tokenKey = 'pluffy_auth_token';
  static const _userKey = 'pluffy_auth_user';

  final AuthSessionStorageBackend _storage;

  AuthSessionStorage({AuthSessionStorageBackend? storage})
    : _storage = storage ?? createAuthSessionStorageBackend();

  Future<StoredAuthSession?> read() async {
    final token = await _storage.read(key: _tokenKey);
    final encodedUser = await _storage.read(key: _userKey);

    if (token == null || token.isEmpty || encodedUser == null) {
      return null;
    }

    try {
      final decodedUser = jsonDecode(encodedUser);
      if (decodedUser is! Map<String, dynamic>) {
        return null;
      }

      return StoredAuthSession(token: token, userJson: decodedUser);
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> save({
    required String token,
    required Map<String, dynamic> userJson,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(userJson));
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
