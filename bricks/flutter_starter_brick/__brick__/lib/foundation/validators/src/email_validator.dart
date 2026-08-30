String? validateEmail({
  required String? value,
  required String emptyEmailErrorMessage,
  required String invalidEmailErrorMessage,
}) {
  if (value == null || value.isEmpty) {
    return emptyEmailErrorMessage;
  }

  if (value.startsWith('.') ||
      value.endsWith('.') ||
      value.contains('..') ||
      value.contains(' ') ||
      value.endsWith('@') ||
      value.startsWith('@')) {
    return invalidEmailErrorMessage;
  }

  final emailParts = value.split('@');
  if (emailParts.length != 2) {
    return invalidEmailErrorMessage;
  }

  final localPart = emailParts.first;
  final localPartRegex = RegExp(
    r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+"
    r"(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*$",
  );
  if (localPart.length > 64 || !localPartRegex.hasMatch(localPart)) {
    return invalidEmailErrorMessage;
  }

  final domainPart = emailParts.last;
  if (domainPart.isEmpty ||
      domainPart.length > 253 ||
      domainPart.endsWith('.') ||
      !domainPart.contains('.')) {
    return invalidEmailErrorMessage;
  }

  final domainLabelRegex = RegExp(
    r'^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$',
  );
  final domainParts = domainPart.split('.');
  for (final part in domainParts) {
    if (part.length > 63 || !domainLabelRegex.hasMatch(part)) {
      return invalidEmailErrorMessage;
    }
  }

  final tld = domainParts.last;
  if (tld.length < 2 || tld.toLowerCase() == 'example') {
    return invalidEmailErrorMessage;
  }

  return null;
}
