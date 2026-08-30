/// Enum representing PNG image assets used in the application.
///
/// This enum provides a centralized way to manage and access PNG image assets,
/// preventing hardcoded paths and making refactoring easier.
///
/// Usage example:
/// ```dart
/// PngImages.placeholderImage.toWidget(width: 100, height: 100)
/// ```
enum PngImages {
  /// Placeholder image used when the actual image is not available or loading.
  placeholderImage(path: 'assets/images/common/placeholder_image.png');

  /// Constructor for the PngImages enum.
  ///
  /// [path] is the relative path to the PNG image asset.
  const PngImages({required this.path});

  /// The project-root-relative Flutter asset key for the PNG image.
  final String path;
}
