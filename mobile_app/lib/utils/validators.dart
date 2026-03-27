/// Form validation utilities for the Family Kitchen mobile app.
class FormValidators {
  /// Validates email format using a simple regex pattern.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates password strength.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validates that passwords match.
  static String? validatePasswordMatch(String? password, String? confirm) {
    if (password != confirm) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates required fields.
  static String? validateRequired(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  /// Calculates password strength.
  static Map<String, dynamic> getPasswordStrength(String password) {
    int strength = 0;
    String message = 'Weak';

    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (password.contains(RegExp(r'[A-Z]')) && password.contains(RegExp(r'[a-z]'))) {
      strength++;
    }
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    strength = (strength / 5 * 4).ceil().clamp(0, 4);

    switch (strength) {
      case 0:
        message = 'Weak';
        break;
      case 1:
      case 2:
        message = 'Fair';
        break;
      case 3:
        message = 'Good';
        break;
      case 4:
        message = 'Strong';
        break;
      default:
        message = 'Unknown';
    }

    return {'strength': strength, 'message': message};
  }
}
