/// Enum representing PNG image assets used in the application.
///
/// This enum provides a centralized way to manage and access PNG image assets,
/// preventing hardcoded paths and making refactoring easier.
///
/// Usage example:
/// ```dart
/// Image.asset(PngImages.placeholderImage.path)
/// ```
enum PngImages {
  /// Placeholder image used when the actual image is not available or loading.
  placeholderImage(path: 'assets/images/common/placeholder_image.png'),

  /// App icon (used for launcher icons generation)
  appIcon(path: 'assets/images/app_icon/app_icon.png');

  /// Constructor for the PngImages enum.
  ///
  /// [path] is the relative path to the PNG image asset.
  const PngImages({required this.path});

  /// The relative path to the PNG image asset, from the root of the assets
  /// directory.
  final String path;
}
