import 'package:{{proj_name}}/l10n/l10n.dart';
import 'package:flutter/widgets.dart';

/// Regular expression for comprehensive email validation.
/// The pattern checks for:
/// - One or more characters before the @ symbol (local part)
/// - The @ symbol
/// - One or more characters after the @ symbol (domain part)
/// - Optional additional domain parts separated by dots
final _emailRegex = RegExp(
  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
);

/// Validates an email address.
///
/// Parameters:
/// - [email]: The email address to validate.
/// - [nullableOrEmptyAllowed]: If true, allows null or empty email. Defaults
///   to false.
/// - [context]: Optional BuildContext for localization.
///
/// Returns:
/// - [String?]: Error message if the email is invalid, null otherwise.
String? validateEmail(
  String? email, {
  bool nullableOrEmptyAllowed = false,
  BuildContext? context,
}) {
  final errorMessage =
      context?.appLocalizations.invalidEmailAddress ?? 'Invalid email address';

  // Allow null or empty email if nullableOrEmptyAllowed is true
  if (nullableOrEmptyAllowed && (email == null || email.trim().isEmpty)) {
    return null;
  }

  // Reject null or empty email if nullableOrEmptyAllowed is false
  if (email == null || email.trim().isEmpty) return errorMessage;

  // Check if the email matches the regex pattern
  if (!_emailRegex.hasMatch(email)) return errorMessage;

  return null;
}
