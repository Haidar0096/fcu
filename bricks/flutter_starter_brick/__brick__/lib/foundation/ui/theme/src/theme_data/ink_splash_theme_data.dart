import 'package:flutter/material.dart';

/// Ink splash theme configuration for Material ink effects.
///
/// These values configure the visual feedback for taps, long presses,
/// and other interactions throughout the app.
class InkSplashThemeData {
  /// Creates ink splash colors based on the color scheme.
  ///
  /// Opacity values follow Material Design guidelines:
  /// - Splash: 12% opacity for the ripple effect
  /// - Highlight: 8% opacity for pressed/held state
  /// - Hover: 4% opacity for mouse hover
  /// - Focus: 12% opacity for keyboard focus
  static InkSplashColors fromColorScheme(ColorScheme colorScheme) =>
      InkSplashColors(
        splashColor: colorScheme.primary.withValues(alpha: 0.12),
        highlightColor: colorScheme.primary.withValues(alpha: 0.08),
        hoverColor: colorScheme.primary.withValues(alpha: 0.04),
        focusColor: colorScheme.primary.withValues(alpha: 0.12),
      );
}

/// Container for ink splash color values.
class InkSplashColors {
  const InkSplashColors({
    required this.splashColor,
    required this.highlightColor,
    required this.hoverColor,
    required this.focusColor,
  });

  final Color splashColor;
  final Color highlightColor;
  final Color hoverColor;
  final Color focusColor;
}
