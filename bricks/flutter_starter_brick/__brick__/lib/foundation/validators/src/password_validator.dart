String? validatePassword(
  String? value, {
  required String emptyPasswordErrorMessage,
  required String passwordTooShortErrorMessage,
  required String passwordRequiresLowercaseErrorMessage,
  required String passwordRequiresUppercaseErrorMessage,
  required String passwordRequiresNumberErrorMessage,
}) {
  if (value == null || value.isEmpty) {
    return emptyPasswordErrorMessage;
  }

  if (value.length < 8) {
    return passwordTooShortErrorMessage;
  }

  if (!RegExp('[a-z]').hasMatch(value)) {
    return passwordRequiresLowercaseErrorMessage;
  }

  if (!RegExp('[A-Z]').hasMatch(value)) {
    return passwordRequiresUppercaseErrorMessage;
  }

  if (!RegExp('[0-9]').hasMatch(value)) {
    return passwordRequiresNumberErrorMessage;
  }

  return null;
}
