import 'package:flutter/material.dart';
import 'package:{{proj_name}}/common/ui/animations/animations.dart';
import 'package:{{proj_name}}/common/ui/core_widgets/src/base_blur_widget.dart';
import 'package:{{proj_name}}/common/ui/core_widgets/src/base_dim_widget.dart';

typedef AppLifeCycleChangedCallback = void Function(
  BuildContext context,
  AppLifecycleState appLifecycleState,
);

/// Calls the framework's [showGeneralDialog] function with the given [context]
/// and some default values.
/// - [onBarrierDismissed] : This function is called when the dialog is
/// dismissed
/// by tapping on the barrier. Only called if [barrierDismissible] is true.
/// If null, the dialog will be dismissed by tapping on the barrier and this
/// function will not be called. If not null, the dialog will not be dismissed
/// by tapping on the barrier and this function will be called instead.
Future<T?> showDefaultGeneralDialog<T>({
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
  bool applyBlur = true,
  bool applyDim = true,
}) async =>
    showGeneralDialog(
      context: context,
      barrierColor: barrierColor ?? Colors.transparent,
      pageBuilder: (_, __, ___) => _CustomDialogContent(
        content: content,
        barrierDismissible: barrierDismissible,
        backgroundColor: backgroundColor,
        contentAlignment: contentAlignment,
        onBarrierDismissed: onBarrierDismissed,
        onAppLifecycleStateChanged: onAppLifecycleStateChanged,
        applyBlur: applyBlur,
        applyDim: applyDim,
      ),
      transitionDuration:
          transitionDuration ?? const Duration(milliseconds: 300),
      transitionBuilder: transitionBuilder ?? scaleTransitionBuilder,
    );

class _CustomDialogContent extends StatefulWidget {
  const _CustomDialogContent({
    required this.content,
    required this.applyBlur,
    required this.applyDim,
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
  final bool applyBlur;
  final bool applyDim;

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
    Widget body = Stack(
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

    if (widget.applyDim) {
      body = BaseDimWidget(child: body);
    }

    if (widget.applyBlur) {
      body = BaseBlurWidget(child: body);
    }

    return PopScope(
      canPop: widget.barrierDismissible,
      child: Scaffold(
        backgroundColor: widget.backgroundColor ?? Colors.transparent,
        body: body,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      widget.onAppLifecycleStateChanged?.call(context, state);
}
