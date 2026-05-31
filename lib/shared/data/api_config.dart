class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'PLUFFY_API_BASE_URL',
    defaultValue: 'http://192.168.1.11:8000/api',
  );

  static Uri uri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$normalizedBase$normalizedPath');
  }
}
