String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your password';
  }

  // Check for minimum and maximum length
  if (value.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  if (value.length > 8) {
    return 'Password must not exceed 8 characters';
  }

  // Check for at least one special character
  final specialCharacterPattern = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  if (!specialCharacterPattern.hasMatch(value)) {
    return 'Password must contain at least one special character';
  }

  // Check for at least one letter
  final letterPattern = RegExp(r'[a-zA-Z]');
  if (!letterPattern.hasMatch(value)) {
    return 'Password must contain at least one letter';
  }

  // Check for at least one digit
  final digitPattern = RegExp(r'[0-9]');
  if (!digitPattern.hasMatch(value)) {
    return 'Password must contain at least one digit';
  }

  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }

  // Simple email validation
  final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!emailPattern.hasMatch(value)) {
    return 'Please enter a valid email';
  }

  // Specific domain validation
  if (!value.endsWith('@gmail.com')) {
    return 'Email must end with @gmail.com';
  }

  return null;
}

String? validateTextField(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter text here';
  }
  return null;
}
