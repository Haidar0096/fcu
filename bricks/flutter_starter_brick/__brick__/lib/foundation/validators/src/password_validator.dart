/// Validates [value] against the password policy recorded by the backend.
///
/// [minimumLength] and every requirement flag come from that policy; the app
/// owns no password-policy values.
String? validatePassword({
  required String? value,
  required String emptyPasswordErrorMessage,
  required int minimumLength,
  required bool requiresLowercase,
  required bool requiresUppercase,
  required bool requiresNumber,
  required String passwordTooShortErrorMessage,
  required String passwordRequiresLowercaseErrorMessage,
  required String passwordRequiresUppercaseErrorMessage,
  required String passwordRequiresNumberErrorMessage,
}) {
  if (value == null || value.isEmpty) {
    return emptyPasswordErrorMessage;
  }

  if (value.length < minimumLength) {
    return passwordTooShortErrorMessage;
  }

  if (requiresLowercase && !RegExp('[a-z]').hasMatch(value)) {
    return passwordRequiresLowercaseErrorMessage;
  }

  if (requiresUppercase && !RegExp('[A-Z]').hasMatch(value)) {
    return passwordRequiresUppercaseErrorMessage;
  }

  if (requiresNumber && !RegExp('[0-9]').hasMatch(value)) {
    return passwordRequiresNumberErrorMessage;
  }

  return null;
}
