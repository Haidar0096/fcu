import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
  Widget? content,
  AppLifeCycleChangedCallback? onAppLifecycleStateChanged,
}) async => showModalBottomSheet<T>(
  context: context,
  isDismissible: isDismissible,
  enableDrag: enableDrag,
  backgroundColor: backgroundColor,
  builder: (BuildContext context) => _CustomBottomSheetContent(
    content: content ?? const SizedBox(),
    onAppLifecycleStateChanged: onAppLifecycleStateChanged,
  ),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(ThemeDefaults.bottomSheetBorderRadius),
      topRight: Radius.circular(ThemeDefaults.bottomSheetBorderRadius),
    ),
  ),
  barrierColor: context.themeData.defaultScrim,
);

class _CustomBottomSheetContent extends StatefulWidget {
  const _CustomBottomSheetContent({
    required this.content,
    this.onAppLifecycleStateChanged,
  });

  final Widget content;
  final AppLifeCycleChangedCallback? onAppLifecycleStateChanged;

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
