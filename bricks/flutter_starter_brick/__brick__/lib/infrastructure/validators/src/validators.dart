class TextValidatorDefaults {
  static const int defaultTextMinLength = 1;
  static const int defaultTextMaxLength = 200;
}

/// Returns an error message if the text is null or has a length less than
/// [minLength] or greater than [maxLength], otherwise returns null.
String? validateTextLength(
  String? text, {
  String Function(int min, int max)? valueMustBeBetweenErrorMessageBuilder,
  int minLength = TextValidatorDefaults.defaultTextMinLength,
  int maxLength = TextValidatorDefaults.defaultTextMaxLength,
}) {
  final errorMessage =
      valueMustBeBetweenErrorMessageBuilder?.call(minLength, maxLength) ??
      'Value must be between $minLength and $maxLength characters';

  if (text == null) return errorMessage;

  if (text.length < minLength) return errorMessage;

  if (text.length > maxLength) return errorMessage;

  return null;
}

/// Returns an error message if the text is null or empty, otherwise returns
/// null.
String? validateNonEmptyText(String? text, {String? emptyValueErrorMessage}) {
  final errorMessage = emptyValueErrorMessage ?? 'Value cannot be empty';

  if (text == null) return errorMessage;

  if (text.isEmpty) return errorMessage;

  return null;
}

String? validateNonEmptySingleDigit(
  String? text, {
  String? emptyValueErrorMessage,
  String? valueMustBeSingleDigitErrorMessage,
}) {
  final errorMessage = emptyValueErrorMessage ?? 'Value cannot be empty';

  // Check for null or empty input
  if (text == null || text.isEmpty) return errorMessage;

  // Parse the integer
  final parsedInt = int.tryParse(text);

  // Check if the parsed value is a single digit
  if (parsedInt == null || parsedInt < 0 || parsedInt > 9) {
    return valueMustBeSingleDigitErrorMessage ?? 'Value must be a single digit';
  }

  // Input is valid
  return null;
}

String? validateNonEmptySelection<T>(
  T? selection, {
  String? emptyValueErrorMessage,
}) {
  if (selection != null) return null;

  return emptyValueErrorMessage ?? 'Please select a value';
}
