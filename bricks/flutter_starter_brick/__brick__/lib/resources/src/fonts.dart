import 'package:flutter/painting.dart';

enum Fonts {
  montserratBold(
    fontFamilyName: 'montserrat',
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.normal,
  ),
  montserratItalic(
    fontFamilyName: 'montserrat',
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  ),
  montserratRegular(
    fontFamilyName: 'montserrat',
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
  );

  const Fonts({
    required this.fontFamilyName,
    required this.fontStyle,
    required this.fontWeight,
  });

  final String fontFamilyName;
  final FontStyle fontStyle;
  final FontWeight fontWeight;
}
