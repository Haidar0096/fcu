import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:flutter/material.dart';

/// A customizable card widget with default styling options.
class BaseCard extends StatelessWidget {
  const BaseCard({
    super.key,
    this.cardPadding,
    this.cardColor,
    this.contentsPadding,
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

  /// Default padding for the card.
  static const EdgeInsets _defaultCardPadding = EdgeInsets.all(5);

  /// Default padding for the card contents.
  static const EdgeInsets _defaultContentsPadding = EdgeInsets.all(20);

  final EdgeInsets? cardPadding;
  final Color? cardColor;
  final EdgeInsets? contentsPadding;
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
          color: context.appColorsTheme.cardShadowColor,
          blurRadius: 4,
          spreadRadius: 4,
        ),
      ];

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: cardWidth,
        height: cardHeight,
        constraints: cardConstraints,
        alignment: contentsAlignment ?? Alignment.center,
        child: Padding(
          padding: cardPadding ?? _defaultCardPadding,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: gradient,
              color: cardColor ?? AppColorsTheme.white,
              border: border,
              borderRadius: borderRadius ?? BorderRadius.circular(20),
              boxShadow: boxShadow ?? _defaultBoxShadow(context),
            ),
            clipBehavior: clipBehavior,
            child: Padding(
              padding: contentsPadding ?? _defaultContentsPadding,
              child: child,
            ),
          ),
        ),
      );
}
