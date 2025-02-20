import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/src/snackbars.dart'
    as snackbars;
import 'package:flutter/material.dart';

final class SnackBarDefaults {
  static const DismissDirection defaultSnackbarDismissDirection =
      DismissDirection.horizontal;

  /// Default duration for snackbars
  static const Duration defaultSnackbarDuration = Duration(seconds: 4);
}

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
  DismissDirection dismissDirection =
      SnackBarDefaults.defaultSnackbarDismissDirection,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      margin: margin,
      content:
          content ??
          Center(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 400,
                minHeight: ThemeDefaults.buttonHeight,
                maxHeight: ThemeDefaults.buttonHeight,
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 32),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(ThemeDefaults.buttonBorderRadius),
                ),
              ),
              child: Text(
                text!,
                style:
                    textStyle ??
                    context.typography?.body6.copyWith(
                      color: context.themeData.colorScheme.onPrimary,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration ?? SnackBarDefaults.defaultSnackbarDuration,
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
}) => showCustomSnackBar(
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
}) => showCustomSnackBar(
  context: context,
  text: text,
  backgroundColor: successGreen,
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
}) => showCustomSnackBar(
  context: context,
  text: text,
  backgroundColor: context.themeData.colorScheme.secondary,
  duration: duration,
  action: action,
);

/// Extension on BuildContext to provide easy access to snackbar functions
extension SnackBarsBuildContextExtension on BuildContext {
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
    DismissDirection dismissDirection =
        SnackBarDefaults.defaultSnackbarDismissDirection,
    SnackBarAction? action,
    EdgeInsetsGeometry? margin,
    Widget? content,
  }) => snackbars.showCustomSnackBar(
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
  }) => snackbars.showErrorSnackBar(
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
  }) => snackbars.showSuccessSnackBar(
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
  }) => snackbars.showWarningSnackBar(
    context: this,
    text: text,
    duration: duration,
    action: action,
  );
}
