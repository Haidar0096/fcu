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

  factory Typography(ColorScheme colorScheme) => Typography._(
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
        errorText: Typography.defaultErrorFont.textStyle.copyWith(
          fontSize: 14,
          color: colorScheme.error,
        ),
      );

  // Default fonts used by theme components
  static const Fonts defaultErrorFont = Fonts.montserratItalic;
  static const Fonts defaultButtonFont = Fonts.montserratRegular;
  static const Fonts defaultDropdownFont = Fonts.montserratRegular;

  // Figma-named styles (added as we build screens)
  final TextStyle primaryTitle;
  final TextStyle indicationText;
  final TextStyle fieldInput;
  final TextStyle linkText;
  final TextStyle smallLinkText;
  final TextStyle bodyText;
  final TextStyle mediumBodyText;
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
