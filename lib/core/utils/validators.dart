abstract final class Validators {
  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailPattern.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Password is required';
    if (text.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? phone(String? value) {
    final text = value?.replaceAll(RegExp(r'\s+'), '') ?? '';
    final phonePattern = RegExp(r'^\+?[1-9]\d{7,14}$');
    if (!phonePattern.hasMatch(text)) {
      return 'Enter a valid number with country code';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Amount']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return 'Enter a valid $field';
    return null;
  }
}
