String? validatePassword(
  String? value, {
  String? emptyPasswordErrorMessage,
  String? passwordTooShortErrorMessage,
  String? passwordRequiresLowercaseErrorMessage,
  String? passwordRequiresUppercaseErrorMessage,
  String? passwordRequiresNumberErrorMessage,
}) {
  if (value == null || value.isEmpty) {
    return emptyPasswordErrorMessage ?? 'Password is required';
  }

  if (value.length < 8) {
    return passwordTooShortErrorMessage ??
        'Password must be at least 8 characters';
  }

  if (!RegExp('[a-z]').hasMatch(value)) {
    return passwordRequiresLowercaseErrorMessage ??
        'Password must contain at least one lowercase letter';
  }

  if (!RegExp('[A-Z]').hasMatch(value)) {
    return passwordRequiresUppercaseErrorMessage ??
        'Password must contain at least one uppercase letter';
  }

  if (!RegExp('[0-9]').hasMatch(value)) {
    return passwordRequiresNumberErrorMessage ??
        'Password must contain at least one number';
  }

  return null;
}
