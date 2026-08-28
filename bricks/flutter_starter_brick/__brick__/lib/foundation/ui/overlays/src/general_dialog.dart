import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/animations/animations.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

part 'general_dialog_content.dart';

RouteTransitionsBuilder _createBlurDimTransitionBuilder({
  required bool applyBlur,
  required bool applyDim,
}) =>
    (context, animation, secondaryAnimation, child) => Stack(
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: animation,
            child: BlurWidget(
              applyBlur: applyBlur,
              child: DimWidget(applyDim: applyDim, child: Container()),
            ),
          ),
        ),
        ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: AnimationDefaults.curveEaseOut,
          ),
          child: child,
        ),
      ],
    );

/// Calls the framework's [showGeneralDialog] function with the given [context]
/// and some default values.
/// - [onBarrierDismissed] : This function is called when the dialog is
/// dismissed
/// by tapping on the barrier. Only called if [barrierDismissible] is true.
/// If null, the dialog will be dismissed by tapping on the barrier and this
/// function will not be called. If not null, the dialog will not be dismissed
/// by tapping on the barrier and this function will be called instead.
/// - [applyBlur] : Whether to apply blur effect to the background.
/// - [applyDim] : Whether to apply dim effect to the background.
Future<T?> showCustomGeneralDialog<T>({
  required BuildContext context,
  required Widget content,
  required bool barrierDismissible,
  required bool applyBlur,
  required bool applyDim,
  Color? backgroundColor,
  Color? barrierColor,
  Alignment? contentAlignment,
  void Function(BuildContext context)? onBarrierDismissed,
  OnAppLifecycleChangedCallback? onAppLifecycleStateChanged,
  Duration? transitionDuration,
  RouteTransitionsBuilder? transitionBuilder,
}) async => showGeneralDialog(
  context: context,
  barrierColor: barrierColor ?? Colors.transparent,
  pageBuilder: (context, animation, secondaryAnimation) => _CustomDialogContent(
    content: content,
    barrierDismissible: barrierDismissible,
    backgroundColor: backgroundColor,
    contentAlignment: contentAlignment,
    onBarrierDismissed: onBarrierDismissed,
    onAppLifecycleStateChanged: onAppLifecycleStateChanged,
  ),
  transitionDuration: transitionDuration ?? AnimationDefaults.animationDuration,
  transitionBuilder: (applyBlur || applyDim)
      ? _createBlurDimTransitionBuilder(
          applyBlur: applyBlur,
          applyDim: applyDim,
        )
      : transitionBuilder ?? scaleTransitionBuilder,
);
