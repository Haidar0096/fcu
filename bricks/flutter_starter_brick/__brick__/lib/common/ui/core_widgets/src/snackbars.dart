import 'package:flutter/material.dart';
import 'package:{{proj_name}}/common/ui/core_widgets/src/snackbars.dart'
    as snackbars;
import 'package:{{proj_name}}/common/ui/theme/theme.dart';

const DismissDirection defaultSnackbarDismissDirection =
    DismissDirection.horizontal;

/// Default duration for snackbars
const Duration defaultSnackbarDuration = Duration(seconds: 4);

/// Clears all snack bars and shows a new one.
///
/// [context] The build context.
/// [text] The text to display in the snackbar. Mutually exclusive with
/// [content].
/// [backgroundColor] The background color of the snackbar.
/// [textStyle] The style of the text in the snackbar.
/// [duration] How long the snackbar should be displayed.
/// [dismissDirection] The direction in which the snackbar can be dismissed.
/// [action] An optional action button for the snackbar.
/// [margin] The margin around the snackbar.
/// [content] A custom widget to display in the snackbar. Mutually exclusive
/// with [text].
ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showCustomSnackBar({
  required BuildContext context,
  String? text,
  Color? backgroundColor,
  TextStyle? textStyle,
  Duration? duration,
  DismissDirection dismissDirection = defaultSnackbarDismissDirection,
  SnackBarAction? action,
  EdgeInsetsGeometry? margin,
  Widget? content,
}) {
  assert(
    text == null || content == null,
    'You can only provide either text or content, not both.',
  );
  assert(
    text != null || content != null,
    'You must provide either text or content.',
  );
  ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
  return ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      margin: margin,
      content: content ??
          Text(
            text!,
            style: textStyle ??
                context.typography?.body3.copyWith(
                  color: context.themeData.colorScheme.onPrimary,
                ),
            textAlign: TextAlign.center,
          ),
      backgroundColor: backgroundColor,
      duration: duration ?? defaultSnackbarDuration,
      dismissDirection: dismissDirection,
      action: action,
    ),
  );
}

/// Shows an error snackbar.
///
/// [context] The build context.
/// [text] The text to display in the snackbar.
/// [duration] How long the snackbar should be displayed.
/// [action] An optional action button for the snackbar.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showErrorSnackBar({
  required BuildContext context,
  required String text,
  Duration? duration,
  SnackBarAction? action,
}) =>
    showCustomSnackBar(
      context: context,
      text: text,
      backgroundColor: context.themeData.colorScheme.error,
      duration: duration,
      action: action,
    );

/// Shows a success snackbar.
///
/// [context] The build context.
/// [text] The text to display in the snackbar.
/// [duration] How long the snackbar should be displayed.
/// [action] An optional action button for the snackbar.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSuccessSnackBar({
  required BuildContext context,
  required String text,
  Duration? duration,
  SnackBarAction? action,
}) =>
    showCustomSnackBar(
      context: context,
      text: text,
      backgroundColor: context.themeData.colorScheme.primary,
      duration: duration,
      action: action,
    );

/// Shows a warning snackbar.
///
/// [context] The build context.
/// [text] The text to display in the snackbar.
/// [duration] How long the snackbar should be displayed.
/// [action] An optional action button for the snackbar.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showWarningSnackBar({
  required BuildContext context,
  required String text,
  Duration? duration,
  SnackBarAction? action,
}) =>
    showCustomSnackBar(
      context: context,
      text: text,
      backgroundColor: context.themeData.colorScheme.secondary,
      duration: duration,
      action: action,
    );

/// Shows a notification snackbar.
///
/// [context] The build context.
/// [content] A custom widget to display in the snackbar.
/// [duration] How long the snackbar should be displayed.
/// [action] An optional action button for the snackbar.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
    showNotificationSnackBar({
  required BuildContext context,
  required Widget content,
  Duration? duration,
  SnackBarAction? action,
}) =>
        showCustomSnackBar(
          context: context,
          content: content,
          backgroundColor: context.themeData.colorScheme.surface,
          duration: duration,
          action: action,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100,
            left: 16,
            right: 16,
          ),
        );

/// Extension on BuildContext to provide easy access to snackbar functions
extension BuildContextExtension on BuildContext {
  /// Shows a custom snackbar with the given params using the context.
  ///
  /// It is the responsibility of the caller to make sure this context is
  /// associated with a [Scaffold] widget to show the snackbar.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      showCustomSnackBar({
    String? text,
    Color? backgroundColor,
    TextStyle? textStyle,
    Duration? duration,
    DismissDirection dismissDirection = defaultSnackbarDismissDirection,
    SnackBarAction? action,
    EdgeInsetsGeometry? margin,
    Widget? content,
  }) =>
          snackbars.showCustomSnackBar(
            context: this,
            text: text,
            backgroundColor: backgroundColor,
            textStyle: textStyle,
            duration: duration,
            dismissDirection: dismissDirection,
            action: action,
            margin: margin,
            content: content,
          );

  /// Shows an error snackbar with the given params using the context.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showErrorSnackBar({
    required String text,
    Duration? duration,
    SnackBarAction? action,
  }) =>
      snackbars.showErrorSnackBar(
        context: this,
        text: text,
        duration: duration,
        action: action,
      );

  /// Shows a success snackbar with the given params using the context.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      showSuccessSnackBar({
    required String text,
    Duration? duration,
    SnackBarAction? action,
  }) =>
          snackbars.showSuccessSnackBar(
            context: this,
            text: text,
            duration: duration,
            action: action,
          );

  /// Shows a warning snackbar with the given params using the context.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      showWarningSnackBar({
    required String text,
    Duration? duration,
    SnackBarAction? action,
  }) =>
          snackbars.showWarningSnackBar(
            context: this,
            text: text,
            duration: duration,
            action: action,
          );

  /// Shows a notification snackbar with the given params using the context.
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>?
      showNotificationSnackBar({
    required Widget content,
    Duration? duration,
    SnackBarAction? action,
  }) =>
          snackbars.showNotificationSnackBar(
            context: this,
            content: content,
            duration: duration,
            action: action,
          );
}
