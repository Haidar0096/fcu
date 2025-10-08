import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/overlays/src/dialog_constants.dart';
import 'package:{{proj_name}}/foundation/ui/overlays/src/dialog_with_two_actions.dart';
import 'package:{{proj_name}}/foundation/ui/overlays/src/general_dialog.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// A dialog with title, form content, and two action buttons.
///
/// Similar to [showDialogWithTwoActions] but optimized for form inputs
/// with proper state management support.
///
/// The [formBuilder] should return a form widget that will be wrapped
/// in a StatefulBuilder for state management.
///
/// Returns the value passed to Navigator.pop() when a button is pressed,
/// or null if the dialog is dismissed.
Future<T?> showFormDialog<T>({
  required BuildContext context,
  required String title,
  required Widget Function(BuildContext context, StateSetter setState)
  formBuilder,
  required String leftButtonText,
  required VoidCallback? Function(StateSetter setState) onLeftButtonPressed,
  required String rightButtonText,
  required VoidCallback? Function(StateSetter setState) onRightButtonPressed,
  bool barrierDismissible = true,
}) async => showCustomGeneralDialog<T>(
  context: context,
  barrierColor: context.themeData.dialogTheme.barrierColor,
  barrierDismissible: barrierDismissible,
  applyBlur: true,
  applyDim: true,
  content: StatefulBuilder(
    builder:
        (context, setState) => AlertDialog(
          title: Padding(
            padding: const EdgeInsets.only(
              top: DialogConstants.verticalPadding,
            ),
            child: Center(
              child: Text(
                title,
                style: context.typography?.primaryTitle.copyWith(
                  color: context.themeData.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DialogConstants.horizontalPadding,
            vertical: DialogConstants.formVerticalPadding,
          ),
          content: SingleChildScrollView(child: formBuilder(context, setState)),
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
                    onPressed: onLeftButtonPressed(setState),
                  ),
                ),
                const SizedBox(width: DialogConstants.buttonSpacing),
                Expanded(
                  child: MainButton(
                    text: rightButtonText.toUpperCase(),
                    onPressed: onRightButtonPressed(setState),
                  ),
                ),
              ],
            ),
          ],
        ),
  ),
);
