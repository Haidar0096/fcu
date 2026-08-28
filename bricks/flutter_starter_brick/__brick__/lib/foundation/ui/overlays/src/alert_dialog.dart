import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/overlays/src/alert_dialog_defaults.dart';
import 'package:{{proj_name}}/foundation/ui/overlays/src/general_dialog.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// A reusable alert dialog that follows the app's design system.
/// Shows a single action dialog with an optional icon.
Future<void> showAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  required bool barrierDismissible,
  required bool autoDismissOnAction,
  String? actionText,
  VoidCallback? onAction,
  Widget? icon,
}) async => showCustomGeneralDialog<void>(
  context: context,
  barrierColor: context.themeData.dialogTheme.barrierColor,
  barrierDismissible: barrierDismissible,
  applyBlur: true,
  applyDim: true,
  content: AlertDialog(
    contentPadding: EdgeInsets.only(
      left: AlertDialogDefaults.horizontalPadding,
      right: AlertDialogDefaults.horizontalPadding,
      top: AlertDialogDefaults.contentTopPadding,
      bottom: AlertDialogDefaults.contentBottomPadding,
    ),
    actionsPadding: EdgeInsets.only(
      left: AlertDialogDefaults.horizontalPadding,
      right: AlertDialogDefaults.horizontalPadding,
      bottom: AlertDialogDefaults.actionsBottomPadding,
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon,
          Spacing.vertical(SpacingSize.spacing24),
        ],
        Text(
          title,
          style: context.typography?.primaryTitle.copyWith(
            color: context.themeData.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        Spacing.vertical(SpacingSize.spacing16),
        Text(
          message,
          style: context.typography?.bodyText.copyWith(
            color: context.themeData.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          // Chosen deviation from go_router's context.canPop(): this closes a
          // dialog route on the Navigator stack, which is the stack that has
          // to be asked.
          if (autoDismissOnAction && Navigator.of(context).canPop()) {
            Navigator.pop(context);
          }
          onAction?.call();
        },
        child: Text(
          (actionText ?? context.appLocalizations.continueButton).toUpperCase(),
        ),
      ),
    ],
    actionsAlignment: MainAxisAlignment.center,
  ),
);
