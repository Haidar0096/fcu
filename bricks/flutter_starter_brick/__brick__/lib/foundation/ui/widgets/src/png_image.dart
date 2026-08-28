import 'package:flutter/material.dart';
import 'package:{{proj_name}}/resources/resources.dart';

/// Extension on [PngImages] enum to provide convenient widget conversion.
extension PngImagesExtension on PngImages {
  /// Converts the PNG enum to an [Image] widget.
  ///
  /// Optional parameters can be provided to customize the appearance.
  Image toWidget({
    Key? key,
    double? width,
    double? height,
    Color? color,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    String? semanticLabel,
  }) => Image.asset(
    path,
    key: key,
    width: width,
    height: height,
    color: color,
    fit: fit ?? BoxFit.contain,
    alignment: alignment ?? Alignment.center,
    semanticLabel: semanticLabel,
  );
}
