import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/src/theme_data/defaults.dart';

/// Ink splash theme configuration for Material ink effects.
///
/// These values configure the visual feedback for taps, long presses,
/// and other interactions throughout the app.
abstract final class InkSplashThemeData {
  /// Creates ink splash colors based on the color scheme.
  ///
  /// Opacity values follow Material Design guidelines:
  /// - Splash: 12% opacity for the ripple effect
  /// - Highlight: 8% opacity for pressed/held state
  /// - Hover: 4% opacity for mouse hover
  /// - Focus: 12% opacity for keyboard focus
  static InkSplashColors fromColorScheme(ColorScheme colorScheme) =>
      InkSplashColors(
        splashColor: colorScheme.primary.withValues(
          alpha: ThemeDefaults.overlayAlpha,
        ),
        highlightColor: colorScheme.primary.withValues(
          alpha: ThemeDefaults.overlayAlpha,
        ),
        hoverColor: colorScheme.primary.withValues(
          alpha: ThemeDefaults.overlayAlpha,
        ),
        focusColor: colorScheme.primary.withValues(
          alpha: ThemeDefaults.overlayAlpha,
        ),
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
