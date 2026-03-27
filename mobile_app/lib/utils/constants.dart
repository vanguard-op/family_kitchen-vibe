/// API Configuration
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String apiV1 = '$baseUrl/api/v1';
  static const Duration requestTimeout = Duration(seconds: 30);
}
