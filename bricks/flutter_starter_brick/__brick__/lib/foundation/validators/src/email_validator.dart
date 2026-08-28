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

  if (value.contains('@') && value.split('@').length == 2) {
    final domainPart = value.split('@')[1];
    if (domainPart.isEmpty ||
        domainPart.endsWith('.') ||
        !domainPart.contains('.')) {
      return invalidEmailErrorMessage;
    }

    final domainParts = domainPart.split('.');
    for (final part in domainParts) {
      if (part.isEmpty ||
          part.startsWith('-') ||
          part.endsWith('-') ||
          part.startsWith('_') ||
          part.endsWith('_') ||
          RegExp(r'^_+$').hasMatch(part)) {
        return invalidEmailErrorMessage;
      }
    }

    final tld = domainParts.last;
    if (tld.length < 2 || tld == 'example') {
      return invalidEmailErrorMessage;
    }
  }

  if (value.contains('@')) {
    final localPart = value.split('@')[0];
    if (localPart.endsWith('.')) {
      return invalidEmailErrorMessage;
    }
  }

  final emailRegex = RegExp(r'^[\w\-.]+@[\w\-]+(\.[\w\-]+)+$');
  if (!emailRegex.hasMatch(value)) {
    return invalidEmailErrorMessage;
  }

  return null;
}
