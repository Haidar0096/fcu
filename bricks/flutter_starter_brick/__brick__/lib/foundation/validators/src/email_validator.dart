String? validateEmail(
  String? value, {
  String? emptyEmailErrorMessage,
  String? invalidEmailErrorMessage,
}) {
  if (value == null || value.isEmpty) {
    return emptyEmailErrorMessage ?? 'Email is required';
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
    return invalidEmailErrorMessage ?? 'Enter a valid email';
  }

  // Check if email ends with just a dot after domain
  if (value.contains('@') && value.split('@').length == 2) {
    final domainPart = value.split('@')[1];
    if (domainPart.isEmpty ||
        domainPart.endsWith('.') ||
        !domainPart.contains('.')) {
      return invalidEmailErrorMessage ?? 'Enter a valid email';
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
        return invalidEmailErrorMessage ?? 'Enter a valid email';
      }
    }

    // Check TLD has at least 2 characters and is not 'example' (test domain)
    final tld = domainParts.last;
    if (tld.length < 2 || tld == 'example') {
      return invalidEmailErrorMessage ?? 'Enter a valid email';
    }
  }

  // Check local part doesn't end with dot
  if (value.contains('@')) {
    final localPart = value.split('@')[0];
    if (localPart.endsWith('.')) {
      return invalidEmailErrorMessage ?? 'Enter a valid email';
    }
  }

  // Basic regex for overall structure
  final emailRegex = RegExp(r'^[\w\-.]+@[\w\-]+(\.[\w\-]+)+$');
  if (!emailRegex.hasMatch(value)) {
    return invalidEmailErrorMessage ?? 'Enter a valid email';
  }

  return null;
}
