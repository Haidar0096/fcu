/// Enum representing image assets used in the application.
///
/// This enum provides a centralized way to manage and access image data.
/// Each enum value corresponds to a specific image asset.
enum Images {
  /// Placeholder image used when the actual image is not available or loading.
  placeholderImagePng(
    path: 'assets/images/common/placeholder_image.png',
  );

  /// Constructor for the Images enum.
  ///
  /// [path] is the relative path to the image asset.
  const Images({required this.path});

  /// The relative path to the image asset, from the root of the assets
  /// directory.
  final String path;
}
