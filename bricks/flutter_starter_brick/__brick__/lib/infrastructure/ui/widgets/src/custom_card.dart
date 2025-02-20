import 'package:flutter/material.dart';
import 'package:{{proj_name}}/infrastructure/ui/animations/animations.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';

/// A customizable card widget with default styling options.
class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    this.cardPadding = CustomCardDefaults.cardPadding,
    this.cardColor,
    this.contentsPadding = CustomCardDefaults.contentsPadding,
    this.boxShadow,
    this.border,
    this.gradient,
    this.cardWidth,
    this.cardHeight,
    this.borderRadius,
    this.cardConstraints,
    this.contentsAlignment,
    this.child,
    this.clipBehavior = Clip.antiAlias,
  });

  final EdgeInsets cardPadding;
  final Color? cardColor;
  final EdgeInsets contentsPadding;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final Gradient? gradient;
  final double? cardWidth;
  final double? cardHeight;
  final BorderRadius? borderRadius;
  final BoxConstraints? cardConstraints;
  final Alignment? contentsAlignment;
  final Widget? child;
  final Clip clipBehavior;

  /// Generates a default box shadow for the card.
  ///
  /// Uses the app's theme color if available; otherwise, falls back to a light
  /// theme color.
  List<BoxShadow> _defaultBoxShadow(BuildContext context) => [
    BoxShadow(
      color: context.themeData.shadowColor,
      blurRadius: CustomCardDefaults.blurRadius,
      spreadRadius: CustomCardDefaults.spreadRadius,
    ),
  ];

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: AnimationDefaults.animationDuration,
    curve: Curves.easeInOut,
    width: cardWidth,
    height: cardHeight,
    constraints: cardConstraints,
    alignment: contentsAlignment ?? Alignment.center,
    child: Padding(
      padding: cardPadding,
      child: AnimatedContainer(
        duration: AnimationDefaults.animationDuration,
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: gradient,
          color: cardColor ?? context.themeData.colorScheme.surface,
          border: border,
          borderRadius: borderRadius ?? CustomCardDefaults.borderRadius,
          boxShadow: boxShadow ?? _defaultBoxShadow(context),
        ),
        clipBehavior: clipBehavior,
        child: Padding(padding: contentsPadding, child: child),
      ),
    ),
  );
}

class CustomCardDefaults {
  /// Default padding for the card.
  static const EdgeInsets cardPadding = EdgeInsets.all(5);

  /// Default padding for the card contents.
  static const EdgeInsets contentsPadding = EdgeInsets.all(20);

  /// Default blur radius for the card.
  static const double blurRadius = 4;

  /// Default spread radius for the card.
  static const double spreadRadius = 4;

  static BorderRadiusGeometry borderRadius = BorderRadius.circular(20);
}
