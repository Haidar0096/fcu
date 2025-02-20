import 'package:{{proj_name}}/infrastructure/ui/animations/animations.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/src/common_typedefs.dart';
import 'package:flutter/material.dart';

/// Calls the framework's [showGeneralDialog] function with the given [context]
/// and some default values.
/// - [onBarrierDismissed] : This function is called when the dialog is
/// dismissed
/// by tapping on the barrier. Only called if [barrierDismissible] is true.
/// If null, the dialog will be dismissed by tapping on the barrier and this
/// function will not be called. If not null, the dialog will not be dismissed
/// by tapping on the barrier and this function will be called instead.
Future<T?> showCustomGeneralDialog<T>({
  required BuildContext context,
  required Widget content,
  bool barrierDismissible = true,
  Color? backgroundColor,
  Color? barrierColor,
  Alignment? contentAlignment,
  void Function(BuildContext context)? onBarrierDismissed,
  AppLifeCycleChangedCallback? onAppLifecycleStateChanged,
  Duration? transitionDuration,
  RouteTransitionsBuilder? transitionBuilder,
}) async => showGeneralDialog(
  context: context,
  barrierColor: barrierColor ?? Colors.transparent,
  pageBuilder:
      (context, animation, pageBuilder) => _CustomDialogContent(
        content: content,
        barrierDismissible: barrierDismissible,
        backgroundColor: backgroundColor,
        contentAlignment: contentAlignment,
        onBarrierDismissed: onBarrierDismissed,
        onAppLifecycleStateChanged: onAppLifecycleStateChanged,
      ),
  transitionDuration: transitionDuration ?? AnimationDefaults.animationDuration,
  transitionBuilder: transitionBuilder ?? scaleTransitionBuilder,
);

class _CustomDialogContent extends StatefulWidget {
  const _CustomDialogContent({
    required this.content,
    this.barrierDismissible = true,
    this.backgroundColor,
    this.contentAlignment,
    this.onBarrierDismissed,
    this.onAppLifecycleStateChanged,
  });

  final Widget content;
  final bool barrierDismissible;
  final Color? backgroundColor;
  final Alignment? contentAlignment;
  final void Function(BuildContext context)? onBarrierDismissed;
  final AppLifeCycleChangedCallback? onAppLifecycleStateChanged;

  @override
  State<_CustomDialogContent> createState() => _CustomDialogContentState();
}

class _CustomDialogContentState extends State<_CustomDialogContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = Stack(
      children: [
        if (widget.barrierDismissible)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (widget.onBarrierDismissed != null) {
                  widget.onBarrierDismissed!.call(context);
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        Align(
          alignment: widget.contentAlignment ?? Alignment.center,
          child: widget.content,
        ),
      ],
    );

    return PopScope(
      canPop: widget.barrierDismissible,
      child: Scaffold(
        backgroundColor: widget.backgroundColor ?? Colors.transparent,
        body: child,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      widget.onAppLifecycleStateChanged?.call(state);
}
