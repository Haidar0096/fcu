String? validateEmail(
  String? value, {
  required String emptyEmailErrorMessage,
  required String invalidEmailErrorMessage,
}) {
  if (value == null || value.isEmpty) {
    return emptyEmailErrorMessage;
  }

  // More precise email validation:
  // - No leading/trailing dots or spaces
  // - No consecutive dots
  // - Domain parts cannot start/end with hyphen
  // - Proper TLD required

  // First, check for obvious issues
  if (value.startsWith('.') ||
      value.endsWith('.') ||
      value.contains('..') ||
      value.contains(' ') ||
      value.endsWith('@') ||
      value.startsWith('@')) {
    return invalidEmailErrorMessage;
  }

  // Check if email ends with just a dot after domain
  if (value.contains('@') && value.split('@').length == 2) {
    final domainPart = value.split('@')[1];
    if (domainPart.isEmpty ||
        domainPart.endsWith('.') ||
        !domainPart.contains('.')) {
      return invalidEmailErrorMessage;
    }

    // Check for domain starting or ending with hyphen or underscore
    final domainParts = domainPart.split('.');
    for (final part in domainParts) {
      if (part.isEmpty ||
          part.startsWith('-') ||
          part.endsWith('-') ||
          part.startsWith('_') ||
          part.endsWith('_') ||
          RegExp(r'^_+$').hasMatch(part)) {
        // All underscores
        return invalidEmailErrorMessage;
      }
    }

    // Check TLD has at least 2 characters and is not 'example' (test domain)
    final tld = domainParts.last;
    if (tld.length < 2 || tld == 'example') {
      return invalidEmailErrorMessage;
    }
  }

  // Check local part doesn't end with dot
  if (value.contains('@')) {
    final localPart = value.split('@')[0];
    if (localPart.endsWith('.')) {
      return invalidEmailErrorMessage;
    }
  }

  // Basic regex for overall structure
  final emailRegex = RegExp(r'^[\w\-.]+@[\w\-]+(\.[\w\-]+)+$');
  if (!emailRegex.hasMatch(value)) {
    return invalidEmailErrorMessage;
  }

  return null;
}
