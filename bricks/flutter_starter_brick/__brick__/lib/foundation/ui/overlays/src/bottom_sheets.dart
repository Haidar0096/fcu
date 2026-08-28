import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

part 'bottom_sheet_content.dart';

Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required bool isDismissible,
  required bool enableDrag,
  Color? backgroundColor,
  Widget? content,
  OnAppLifecycleChangedCallback? onAppLifecycleStateChanged,
}) async => showModalBottomSheet<T>(
  context: context,
  isDismissible: isDismissible,
  enableDrag: enableDrag,
  backgroundColor: backgroundColor,
  builder:
      (BuildContext context) => _CustomBottomSheetContent(
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
