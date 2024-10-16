import 'package:{{proj_name}}/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

const int defaultTextMinLength = 1;
const int defaultTextMaxLength = 200;

/// Returns an error message if the text is null or has a length less than
/// [minLength] or greater than [maxLength], otherwise returns null.
String? validateTextLength(
  String? text, {
  BuildContext? context,
  int minLength = defaultTextMinLength,
  int maxLength = defaultTextMaxLength,
}) {
  final errorMessage =
      context?.appLocalizations.valueMustBeBetween(minLength, maxLength) ??
          'Value must be between $minLength and $maxLength characters';

  if (text == null) return errorMessage;

  if (text.length < minLength) return errorMessage;

  if (text.length > maxLength) return errorMessage;

  return null;
}

/// Returns an error message if the text is null or empty, otherwise returns
/// null.
String? validateNonEmptyText(
  String? text, {
  BuildContext? context,
}) {
  final errorMessage =
      context?.appLocalizations.valueCannotBeEmpty ?? 'Value cannot be empty';

  if (text == null) return errorMessage;

  if (text.isEmpty) return errorMessage;

  return null;
}
