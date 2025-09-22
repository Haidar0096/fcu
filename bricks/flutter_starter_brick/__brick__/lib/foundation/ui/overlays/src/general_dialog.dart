import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/animations/animations.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Creates a custom transition builder for blur/dim effects
RouteTransitionsBuilder _createBlurDimTransitionBuilder({
  required bool applyBlur,
  required bool applyDim,
}) =>
    (context, animation, secondaryAnimation, child) => Stack(
      children: [
        // Background blur/dim with fade animation only
        Positioned.fill(
          child: FadeTransition(
            opacity: animation,
            child: BlurWidget(
              applyBlur: applyBlur,
              child: DimWidget(applyDim: applyDim, child: Container()),
            ),
          ),
        ),
        // Dialog content with scale animation
        ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOut),
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
  bool barrierDismissible = true,
  Color? backgroundColor,
  Color? barrierColor,
  Alignment? contentAlignment,
  void Function(BuildContext context)? onBarrierDismissed,
  AppLifeCycleChangedCallback? onAppLifecycleStateChanged,
  Duration? transitionDuration,
  RouteTransitionsBuilder? transitionBuilder,
  bool applyBlur = false,
  bool applyDim = false,
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
    final child = Stack(
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
