import 'package:flutter/material.dart';

ScrollbarThemeData scrollbarThemeData(ColorScheme colorScheme) =>
    ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(colorScheme.primary.withOpacity(0.8)),
      thickness: const WidgetStatePropertyAll(10),
      radius: const Radius.circular(20),
    );
