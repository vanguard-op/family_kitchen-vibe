/// API Configuration
class ApiConfig {
  static const String baseUrl = 'http://10.43.246.218:8000';
  static const String apiV1 = baseUrl;
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static bool Function(int?)? validateStatus = (status) => true;
}
