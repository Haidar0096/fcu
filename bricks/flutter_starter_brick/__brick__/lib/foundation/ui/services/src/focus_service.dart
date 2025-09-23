import 'package:flutter/material.dart';

/// Unfocuses the currently focused widget
void unfocus() => FocusManager.instance.primaryFocus?.unfocus();
