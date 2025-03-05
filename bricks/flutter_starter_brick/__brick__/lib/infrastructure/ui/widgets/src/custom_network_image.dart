import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';
import 'package:{{proj_name}}/resources/resources.dart';

/// A widget that displays a network image with caching, placeholder,
/// and error handling.
///
/// Provides a loading placeholder and an error widget if the image fails to
/// load.
class CustomNetworkImage extends StatelessWidget {
  /// Creates a [CustomNetworkImage].
  CustomNetworkImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit,
    this.placeholderFit,
    this.errorWidgetFit,
    this.errorListener,
    BorderRadiusGeometry? placeholderBorderRadius,
    BorderRadiusGeometry? errorWidgetBorderRadius,
  }) : placeholderBorderRadius =
           placeholderBorderRadius ??
           CustomNetworkImageDefaults.placeholderBorderRadius,
       errorWidgetBorderRadius =
           errorWidgetBorderRadius ??
           CustomNetworkImageDefaults.errorWidgetBorderRadius;

  /// {@template custom_network_image.imageUrl}
  /// The URL of the image to display.
  /// {@endtemplate}
  final String imageUrl;

  /// {@template custom_network_image.width}
  /// The width of the image.
  /// {@endtemplate}
  final double? width;

  /// {@template custom_network_image.height}
  /// The height of the image.
  /// {@endtemplate}
  final double? height;

  /// {@template custom_network_image.fit}
  /// How the image should be inscribed into the space allocated during layout.
  /// {@endtemplate}
  final BoxFit? fit;

  /// {@template custom_network_image.placeholderFit}
  /// How the placeholder should be inscribed into the space allocated during
  /// layout.
  /// {@endtemplate}
  final BoxFit? placeholderFit;

  /// {@template custom_network_image.errorWidgetFit}
  /// How the error widget should be inscribed into the space allocated during
  /// layout.
  /// {@endtemplate}
  final BoxFit? errorWidgetFit;

  /// {@template custom_network_image.placeholderBorderRadius}
  /// The border radius of the placeholder
  /// {@endtemplate}
  final BorderRadiusGeometry placeholderBorderRadius;

  /// {@template custom_network_image.errorWidgetBorderRadius}
  /// The border radius of the error widget.
  /// {@endtemplate}
  final BorderRadiusGeometry errorWidgetBorderRadius;

  /// {@template custom_network_image.errorListener}
  /// A callback that is called when an error occurs while loading the image.
  /// {@endtemplate}
  final void Function(Object)? errorListener;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    imageUrl: imageUrl,
    height: height,
    width: width,
    fit: fit,
    placeholder:
        (_, __) => ClipRRect(
          borderRadius: placeholderBorderRadius,
          child: const Center(child: LoaderWidget()),
        ),
    errorWidget:
        (_, __, ___) => ClipRRect(
          borderRadius: errorWidgetBorderRadius,
          child: Image.asset(
            Images.placeholderImagePng.path,
            fit: errorWidgetFit,
          ),
        ),
    errorListener: errorListener,
  );
}

class CustomNetworkImageDefaults {
  static BorderRadiusGeometry placeholderBorderRadius = BorderRadius.circular(
    6,
  );

  static BorderRadiusGeometry errorWidgetBorderRadius = BorderRadius.circular(
    6,
  );
}
