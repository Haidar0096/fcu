import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:flutter/material.dart';

const DismissDirection defaultSnackbarDismissDirection =
    DismissDirection.horizontal;

const Duration defaultSnackbarDuration = Duration(seconds: 4);

/// Clears all snack bars and shows a new one.
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
                Theme.of(context)
                    .extension<AppTextTheme>()
                    ?.body2
                    ?.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
      backgroundColor: backgroundColor,
      duration: duration ?? defaultSnackbarDuration,
      dismissDirection: dismissDirection,
      action: action,
    ),
  );
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showErrorSnackBar({
  required BuildContext context,
  required String text,
  Duration? duration,
  SnackBarAction? action,
}) =>
    showCustomSnackBar(
      context: context,
      text: text,
      backgroundColor: AppColors.redValidation,
      duration: duration,
      action: action,
    );

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSuccessSnackBar({
  required BuildContext context,
  required String text,
  Duration? duration,
  SnackBarAction? action,
}) =>
    showCustomSnackBar(
      context: context,
      text: text,
      backgroundColor: AppColors.green,
      duration: duration,
      action: action,
    );

ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showWarningSnackBar({
  required BuildContext context,
  required String text,
  Duration? duration,
  SnackBarAction? action,
}) =>
    showCustomSnackBar(
      context: context,
      text: text,
      backgroundColor: AppColors.yellowValidation,
      duration: duration,
      action: action,
    );

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
          backgroundColor: AppColors.midGrey,
          duration: duration,
          action: action,
        );
