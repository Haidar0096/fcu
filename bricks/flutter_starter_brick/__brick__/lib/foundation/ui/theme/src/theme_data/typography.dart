import 'package:flutter/material.dart';
import 'package:{{proj_name}}/resources/resources.dart';

/// Enum representing fonts used in the application.
///
/// This enum provides a centralized way to manage and access font data.
/// Each enum value corresponds to a specific font.
extension FontExtension on Fonts {
  TextStyle get textStyle => TextStyle(
    fontFamily: fontFamilyName,
    fontStyle: fontStyle,
    fontWeight: fontWeight,
  );
}

/// Typography system providing text styles with font properties only.
///
/// IMPORTANT: All typography styles define ONLY font-related properties
/// (fontFamily, fontWeight, fontSize, fontStyle, height, letterSpacing).
/// Colors are NEVER included in typography styles.
///
/// Always provide colors explicitly via .copyWith(color: ...) when using
/// these styles in UI code.
///
/// Example:
/// ```dart
/// Text(
///   'Title',
///   style: context.typography?.primaryTitle.copyWith(
///     color: primaryTitleColor,
///   ),
/// )
/// ```
final class Typography extends ThemeExtension<Typography> {
  const Typography._({
    required this.primaryTitle,
    required this.indicationText,
    required this.fieldInput,
    required this.linkText,
    required this.smallLinkText,
    required this.bodyText,
    required this.mediumBodyText,
    required this.errorText,
  });

  factory Typography() => Typography._(
    primaryTitle: Fonts.montserratBold.textStyle.copyWith(fontSize: 24),
    indicationText: Fonts.montserratRegular.textStyle.copyWith(fontSize: 12),
    fieldInput: Fonts.montserratRegular.textStyle.copyWith(fontSize: 14),
    linkText: Fonts.montserratRegular.textStyle.copyWith(fontSize: 16),
    smallLinkText: Fonts.montserratRegular.textStyle.copyWith(fontSize: 12),
    bodyText: Fonts.montserratRegular.textStyle.copyWith(fontSize: 14),
    mediumBodyText: Fonts.montserratRegular.textStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    errorText: Typography.defaultErrorFont.textStyle.copyWith(fontSize: 14),
  );

  // Default fonts used by theme components
  static const Fonts defaultErrorFont = Fonts.montserratItalic;
  static const Fonts defaultButtonFont = Fonts.montserratRegular;
  static const Fonts defaultDropdownFont = Fonts.montserratRegular;

  // Figma-named styles (added as we build screens)

  /// Primary screen titles (Montserrat Bold, 24px)
  /// Color: Provide via copyWith (commonly a primary text color)
  final TextStyle primaryTitle;

  /// Small labels and hints (Montserrat Regular, 12px)
  /// Color: Provide via copyWith (commonly a secondary/muted color)
  final TextStyle indicationText;

  /// Text field input text (Montserrat Regular, 14px)
  /// Color: Provide via copyWith (commonly onSurface or secondary)
  final TextStyle fieldInput;

  /// Link text (Montserrat Regular, 16px)
  /// Color: Use theme.colorScheme.primary or custom color
  final TextStyle linkText;

  /// Small link text (Montserrat Regular, 12px)
  /// Color: Use theme.colorScheme.primary or custom color
  final TextStyle smallLinkText;

  /// General body text (Montserrat Regular, 14px)
  /// Color: Provide via copyWith (commonly secondary or onSurface)
  final TextStyle bodyText;

  /// Medium body text (Montserrat Regular, 14px, w500, height 1.5)
  /// Color: Provide via copyWith
  final TextStyle mediumBodyText;

  /// Error text (Montserrat Italic, 14px)
  /// Color: Use theme.colorScheme.error
  final TextStyle errorText;

  @override
  ThemeExtension<Typography> copyWith({
    TextStyle? primaryTitle,
    TextStyle? indicationText,
    TextStyle? fieldInput,
    TextStyle? linkText,
    TextStyle? smallLinkText,
    TextStyle? bodyText,
    TextStyle? mediumBodyText,
    TextStyle? errorText,
  }) => Typography._(
    primaryTitle: primaryTitle ?? this.primaryTitle,
    indicationText: indicationText ?? this.indicationText,
    fieldInput: fieldInput ?? this.fieldInput,
    linkText: linkText ?? this.linkText,
    smallLinkText: smallLinkText ?? this.smallLinkText,
    bodyText: bodyText ?? this.bodyText,
    mediumBodyText: mediumBodyText ?? this.mediumBodyText,
    errorText: errorText ?? this.errorText,
  );

  @override
  ThemeExtension<Typography> lerp(
    covariant ThemeExtension<Typography>? other,
    double t,
  ) {
    if (other == null) return this;
    if (other is! Typography) return this;
    return Typography._(
      primaryTitle: TextStyle.lerp(primaryTitle, other.primaryTitle, t)!,
      indicationText: TextStyle.lerp(indicationText, other.indicationText, t)!,
      fieldInput: TextStyle.lerp(fieldInput, other.fieldInput, t)!,
      linkText: TextStyle.lerp(linkText, other.linkText, t)!,
      smallLinkText: TextStyle.lerp(smallLinkText, other.smallLinkText, t)!,
      bodyText: TextStyle.lerp(bodyText, other.bodyText, t)!,
      mediumBodyText: TextStyle.lerp(mediumBodyText, other.mediumBodyText, t)!,
      errorText: TextStyle.lerp(errorText, other.errorText, t)!,
    );
  }
}

extension TypographyBuildContextExtension on BuildContext {
  Typography? get typography => Theme.of(this).extension<Typography>();
}
