import 'package:flutter/material.dart';

/// Extension on ColorScheme to provide semantic colors
extension ColorSchemeExtensions on ColorScheme {
  /// Color for success states
  Color get success => brightness == Brightness.light
      ? const Color(0xFF4CAF50) // Material green 500
      : const Color(0xFF81C784); // Material green 300

  /// Color for success container/background
  Color get successContainer => brightness == Brightness.light
      ? const Color(0xFFE8F5E9) // Material green 50
      : const Color(0xFF2E7D32); // Material green 800

  /// Color for content on success color
  Color get onSuccess => brightness == Brightness.light
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF000000);

  /// Color for warning states
  Color get warning => brightness == Brightness.light
      ? const Color(0xFFFF9800) // Material orange 500
      : const Color(0xFFFFB74D); // Material orange 300

  /// Color for warning container/background
  Color get warningContainer => brightness == Brightness.light
      ? const Color(0xFFFFF3E0) // Material orange 50
      : const Color(0xFFE65100); // Material orange 900

  /// Color for content on warning color
  Color get onWarning => brightness == Brightness.light
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF000000);
}