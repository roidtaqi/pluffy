import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/data/api_config.dart';

class PasswordResetResponse {
  final bool success;
  final String message;

  const PasswordResetResponse({required this.success, required this.message});
}

class PasswordResetService {
  const PasswordResetService();

  Future<PasswordResetResponse> requestCode(String email) {
    return _post('forgot-password', {'email': email});
  }

  Future<PasswordResetResponse> resetPassword({
    required String email,
    required String code,
    required String password,
  }) {
    return _post('reset-password', {
      'email': email,
      'code': code,
      'password': password,
      'password_confirmation': password,
    });
  }

  Future<PasswordResetResponse> _post(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http.post(
        ApiConfig.uri(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      final body = jsonDecode(response.body);

      return PasswordResetResponse(
        success:
            response.statusCode >= 200 &&
            response.statusCode < 300 &&
            body is Map<String, dynamic> &&
            body['success'] == true,
        message: _messageFromBody(body),
      );
    } catch (_) {
      return const PasswordResetResponse(
        success: false,
        message: 'Tidak bisa terhubung ke server Pluffy.',
      );
    }
  }

  String _messageFromBody(dynamic body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
    }

    return 'Permintaan belum dapat diproses. Coba lagi.';
  }
}
