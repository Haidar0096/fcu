import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:flutter/material.dart';

/// Extension methods for [BuildContext] to access theme extensions.
extension BuildContextExtension on BuildContext {
  /// Returns the theme extension of type [T] or null if not found.
  T? extensionOrNull<T>() => Theme.of(this).extension<T>();

  /// Returns the [AppButtonTheme] extension or null if not found.
  AppButtonTheme? get appButtonThemeOrNull =>
      Theme.of(this).extension<AppButtonTheme>();

  /// Returns the [AppColorsTheme] extension or null if not found.
  AppColorsTheme? get appColorsThemeOrNull =>
      Theme.of(this).extension<AppColorsTheme>();

  /// Returns the [AppDropdownMenuTheme] extension or null if not found.
  AppDropdownMenuTheme? get appDropdownMenuThemeOrNull =>
      Theme.of(this).extension<AppDropdownMenuTheme>();

  /// Returns the [AppTextFieldTheme] extension or null if not found.
  AppTextFieldTheme? get appTextFieldThemeOrNull =>
      Theme.of(this).extension<AppTextFieldTheme>();

  /// Returns the [AppTextTheme] extension or null if not found.
  AppTextTheme? get appTextThemeOrNull =>
      Theme.of(this).extension<AppTextTheme>();

  /// Returns the [AppTheme] extension or null if not found.
  AppTheme? get appThemeOrNull => Theme.of(this).extension<AppTheme>();

  /// Returns the theme extension of type [T].
  ///
  // ignore: lines_longer_than_80_chars
  /// {@template {{org_name}}.{{proj_name}}.theme_extension_must_not_be_null}
  /// The theme extension must be non-null.
  /// {@endtemplate}
  T extension<T>() => Theme.of(this).extension<T>()!;

  /// Returns the [AppButtonTheme] extension, guaranteed to be non-null.
  ///
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.theme_extension_must_not_be_null}
  AppButtonTheme get appButtonTheme => extension<AppButtonTheme>();

  /// Returns the [AppColorsTheme] extension, guaranteed to be non-null.
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.theme_extension_must_not_be_null}
  AppColorsTheme get appColorsTheme => extension<AppColorsTheme>();

  /// Returns the [AppDropdownMenuTheme] extension, guaranteed to be non-null.
  ///
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.theme_extension_must_not_be_null}
  AppDropdownMenuTheme get appDropdownMenuTheme =>
      extension<AppDropdownMenuTheme>();

  /// Returns the [AppTextFieldTheme] extension, guaranteed to be non-null.
  ///
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.theme_extension_must_not_be_null}
  AppTextFieldTheme get appTextFieldTheme => extension<AppTextFieldTheme>();

  /// Returns the [AppTextTheme] extension, guaranteed to be non-null.
  ///
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.theme_extension_must_not_be_null}
  AppTextTheme get appTextTheme => extension<AppTextTheme>();

  /// Returns the [AppTheme] extension, guaranteed to be non-null.
  ///
  // ignore: lines_longer_than_80_chars
  /// {@macro {{org_name}}.{{proj_name}}.theme_extension_must_not_be_null}
  AppTheme get appTheme => extension<AppTheme>();
}
