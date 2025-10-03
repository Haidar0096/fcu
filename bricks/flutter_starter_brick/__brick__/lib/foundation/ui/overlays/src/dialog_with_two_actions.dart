import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/overlays/src/dialog_constants.dart';
import 'package:{{proj_name}}/foundation/ui/overlays/src/general_dialog.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// A dialog with title, body content, and two action buttons.
///
/// The left button is typically used for cancel/secondary actions,
/// while the right button is used for confirm/primary actions.
///
/// Returns the value passed to Navigator.pop() when a button is pressed,
/// or null if the dialog is dismissed.
Future<T?> showDialogWithTwoActions<T>({
  required BuildContext context,
  required String title,
  required Widget body,
  required String leftButtonText,
  required VoidCallback? leftButtonOnPressed,
  required String rightButtonText,
  required VoidCallback? rightButtonOnPressed,
  bool barrierDismissible = true,
  bool rightButtonIsDestructive = false,
}) async => showCustomGeneralDialog<T>(
  context: context,
  barrierColor: context.themeData.dialogTheme.barrierColor,
  barrierDismissible: barrierDismissible,
  applyBlur: true,
  applyDim: true,
  content: AlertDialog(
    title: Padding(
      padding: const EdgeInsets.only(top: DialogConstants.verticalPadding),
      child: Center(
        child: Text(title, style: context.typography?.primaryTitle),
      ),
    ),
    content: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DialogConstants.horizontalPadding,
        vertical: DialogConstants.verticalPadding,
      ),
      child: body,
    ),
    actionsAlignment: MainAxisAlignment.center,
    actionsPadding: const EdgeInsets.only(
      left: DialogConstants.horizontalPadding,
      right: DialogConstants.horizontalPadding,
      bottom: DialogConstants.horizontalPadding,
      top: DialogConstants.verticalPadding,
    ),
    actions: [
      Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: leftButtonText.toUpperCase(),
              onPressed: leftButtonOnPressed,
            ),
          ),
          const SizedBox(width: DialogConstants.buttonSpacing),
          Expanded(
            child:
                rightButtonIsDestructive
                    ? DestructiveButton(
                      text: rightButtonText.toUpperCase(),
                      onPressed: rightButtonOnPressed,
                    )
                    : MainButton(
                      text: rightButtonText.toUpperCase(),
                      onPressed: rightButtonOnPressed,
                    ),
          ),
        ],
      ),
    ],
  ),
);
