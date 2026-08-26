/// Design values owned by the splash screen.
abstract final class SplashScreenDefaults {
  /// Spaces out the app name so it reads as a wordmark.
  static const double titleLetterSpacing = 8;

  /// A lighter echo of the title's spacing for the tagline.
  static const double taglineLetterSpacing = 2;

  /// Softens the tagline against the app name.
  static const double taglineAlpha = 0.7;

  /// A loader smaller than the shared default, so it sits under the wordmark.
  static const double loaderSize = 40;
}
