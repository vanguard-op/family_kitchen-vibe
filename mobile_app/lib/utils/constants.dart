/// Application constants and configuration values.

/// API Configuration
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String apiV1 = '$baseUrl/api/v1';
  static const Duration requestTimeout = Duration(seconds: 30);
}

/// Route names for navigation
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String inventory = '/inventory';
  static const String inventoryAdd = '/inventory/add';
  static const String members = '/members';
  static const String profile = '/profile';
  static const String chefMode = '/chef-mode';
}

/// Theme and UI Constants
class UIConstants {
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 40.0;
  static const double minTouchTarget = 48.0;
}

/// HTTP Status Codes
class HttpStatus {
  static const int ok = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int serverError = 500;
}

/// Error Messages
class ErrorMessages {
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String emailAlreadyExists = 'Email already registered.';
  static const String unknownError = 'An unknown error occurred.';
  static const String sessionExpired = 'Your session has expired. Please login again.';
}
