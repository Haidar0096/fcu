import 'package:flutter/material.dart';

DividerThemeData dividerThemeData(ColorScheme colorScheme) => DividerThemeData(
  thickness: 1,
  color: colorScheme.outlineVariant,
  space: 0,
  endIndent: 0,
  indent: 0,
);
