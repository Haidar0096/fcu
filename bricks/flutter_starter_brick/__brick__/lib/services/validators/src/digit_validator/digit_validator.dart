import 'package:{{proj_name}}/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

final RegExp _digitRegex = RegExp(r'^[0-9]+$');

/// Returns true only if the input is a string of digits with a length less than
/// or equal to [maxLength].
String? validateMaxLengthDigitsString({
  required String? input,
  required int maxLength,
  BuildContext? context,
}) {
  assert(
    maxLength >= 0,
    'maxLength must be greater than or equal to 0',
  );

  if (input == null ||
      input.isEmpty ||
      !_digitRegex.hasMatch(input) ||
      input.length > maxLength) {
    return context?.appLocalizations.valueMustBeNumericLessThan(maxLength) ??
        'Value must be numeric and less than $maxLength characters';
  }

  return null;
}

/// Returns true only if the input is a string of digits with a length between
/// [minLength] and [maxLength], inclusive.
String? validateBoundedLengthDigitsString({
  required String? input,
  required int minLength,
  required int maxLength,
  BuildContext? context,
}) {
  assert(
    minLength <= maxLength,
    'minLength must be less than or equal to maxLength',
  );
  assert(
    minLength >= 0,
    'minLength must be greater than or equal to 0',
  );

  if (input == null ||
      !_digitRegex.hasMatch(input) ||
      input.length < minLength ||
      input.length > maxLength) {
    return context?.appLocalizations.valueMustBeNumericBetween(
          minLength,
          maxLength,
        ) ??
        'Value must be numeric and between $minLength and '
            '$maxLength characters';
  }

  return null;
}

String? validateNonEmptyDigitsString({
  required String? input,
  BuildContext? context,
}) {
  if (input == null || input.isEmpty) {
    return context?.appLocalizations.valueCannotBeEmpty ??
        'Value cannot be empty';
  }
  if (!_digitRegex.hasMatch(input)) {
    return context?.appLocalizations.valueMustBeNumeric ??
        'Value must be numeric';
  }
  return null;
}

/// Returns true only if the input is a string of digits with a length equal to
/// [length].
String? validateExactLengthDigitsString({
  required String? input,
  required int length,
  BuildContext? context,
}) {
  assert(
    length >= 0,
    'length must be greater than or equal to 0',
  );

  if (input == null || input.length != length || !_digitRegex.hasMatch(input)) {
    return context?.appLocalizations.valueMustBeNumericWithLength(length) ??
        'Value must be numeric and have $length characters';
  }

  return null;
}
