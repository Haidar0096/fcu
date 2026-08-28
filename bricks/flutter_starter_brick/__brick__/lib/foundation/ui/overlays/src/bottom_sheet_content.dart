part of 'bottom_sheets.dart';

class _CustomBottomSheetContent extends StatefulWidget {
  const _CustomBottomSheetContent({
    required this.content,
    this.onAppLifecycleStateChanged,
  });

  final Widget content;
  final OnAppLifecycleChangedCallback? onAppLifecycleStateChanged;

  @override
  State<_CustomBottomSheetContent> createState() =>
      _CustomBottomSheetContentState();
}

class _CustomBottomSheetContentState extends State<_CustomBottomSheetContent>
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
  Widget build(BuildContext context) => widget.content;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      widget.onAppLifecycleStateChanged?.call(state);
}
