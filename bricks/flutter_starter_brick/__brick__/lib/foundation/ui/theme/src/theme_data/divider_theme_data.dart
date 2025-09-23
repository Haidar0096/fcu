import 'package:flutter/material.dart';

DividerThemeData dividerThemeData(ColorScheme colorScheme) => DividerThemeData(
  thickness: 1,
  color: colorScheme.outlineVariant,
  space: 1,
  endIndent: 0,
  indent: 0,
);
