part of 'general_dialog.dart';

class _CustomDialogContent extends StatefulWidget {
  const _CustomDialogContent({
    required this.content,
    required this.barrierDismissible,
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
  final OnAppLifecycleChangedCallback? onAppLifecycleStateChanged;

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
                } else if (Navigator.of(context).canPop()) {
                  // This closes a dialog route, so the Navigator stack is the
                  // stack that must be checked.
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
