/// Custom exception class for handling application-specific errors.
class AppException implements Exception {
  final int code;
  final String message;
  final String? details;

  AppException(this.message, {int? code, this.details}) : code = code ?? 0;

  String get title {
    switch (code) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Forbidden. You do not have permission to perform this action.';
      case 404:
        return 'Not found. The requested resource does not exist.';
      case 500:
        return 'Internal server error. Please try again later.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  String toString() {
    return 'AppException(code: $code, message: $message, details: $details)';
  }
}
