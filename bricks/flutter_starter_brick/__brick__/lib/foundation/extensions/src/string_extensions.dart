import 'package:path/path.dart' as path;

/// Extensions for String and String? types
extension NullableStringExtension on String? {
  /// Returns true if string is not null and not empty (after trimming),
  /// false otherwise
  bool get isNotNullOrEmpty => this != null && this!.trim().isNotEmpty;

  /// Returns true if string is null or empty (after trimming), false otherwise
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
}

/// Extensions for file path operations on String
extension FilePathExtension on String {
  /// Returns the file extension in lowercase without the dot
  /// (e.g., "pdf", "png")
  String get fileExtension =>
      path.extension(this).toLowerCase().replaceFirst('.', '');

  /// Returns the file extension in uppercase (e.g., "PDF", "PNG")
  String get fileExtensionUppercase => fileExtension.toUpperCase();

  /// Returns the file name without extension
  String get fileNameWithoutExtension => path.basenameWithoutExtension(this);

  /// Gets the part of path after the last separator.
  ///
  ///     path.basename('path/to/foo.dart'); // -> 'foo.dart'
  ///     path.basename('path/to');          // -> 'to'
  ///
  /// Trailing separators are ignored.
  ///
  ///     path.basename('path/to/'); // -> 'to'
  String get baseName => path.basename(this);
}
