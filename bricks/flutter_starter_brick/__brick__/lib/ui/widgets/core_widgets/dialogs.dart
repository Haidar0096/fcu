import 'package:{{proj_name}}/l10n/l10n.dart';
import 'package:{{proj_name}}/ui/animations/animations.dart';
import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_blur_widget.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_card.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_dim_widget.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_elevated_button.dart';
import 'package:flutter/material.dart';

/// Callback for app lifecycle state changes.
typedef OnAppLifeCycleChanged = void Function(
  BuildContext context,
  AppLifecycleState appLifecycleState,
);

/// Shows a general dialog with customizable properties.
///
/// This function wraps Flutter's [showGeneralDialog] with some default values
/// and additional customization options.
///
/// Parameters:
/// - [context]: The build context.
/// - [content]: The main content of the dialog.
/// - [barrierDismissible]: Whether the dialog can be dismissed by tapping
/// outside.
/// - [backgroundColor]: The background color of the dialog.
/// - [barrierColor]: The color of the barrier behind the dialog.
/// - [contentAlignment]: The alignment of the content within the dialog.
/// - [onBarrierDismissed]: Callback when the barrier is tapped
/// (if dismissible).
/// - [onAppLifecycleStateChanged]: Callback for app lifecycle state changes.
/// - [transitionDuration]: Duration of the dialog's entrance/exit animation.
/// - [transitionBuilder]: Custom transition builder for the dialog.
/// - [applyBlur]: Whether to apply a blur effect to the background.
/// - [applyDim]: Whether to apply a dim effect to the background.
///
/// Returns a [Future] that completes with the result of the dialog.
Future<T?> showBaseGeneralDialog<T>({
  required BuildContext context,
  required Widget content,
  bool barrierDismissible = true,
  Color? backgroundColor,
  Color? barrierColor,
  Alignment? contentAlignment,
  void Function(BuildContext context)? onBarrierDismissed,
  OnAppLifeCycleChanged? onAppLifecycleStateChanged,
  Duration? transitionDuration,
  RouteTransitionsBuilder? transitionBuilder,
  bool applyBlur = true,
  bool applyDim = false,
}) async =>
    showGeneralDialog(
      context: context,
      barrierColor: barrierColor ?? const Color(0x80000000),
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
      transitionBuilder: transitionBuilder ?? fadeTransitionBuilder(),
    );

/// A custom widget to handle the content and behavior of the dialog.
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
  final OnAppLifeCycleChanged? onAppLifecycleStateChanged;
  final bool applyBlur;
  final bool applyDim;

  @override
  State<_CustomDialogContent> createState() => _CustomDialogContentState();
}

class _CustomDialogContentState extends State<_CustomDialogContent>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
                  widget.onBarrierDismissed!(context);
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

/// Shows an action dialog with customizable content and buttons.
///
/// This dialog includes a header, title icon, title text, body content,
/// and up to two action buttons.
///
/// Parameters:
/// - [context]: The build context.
/// - [dialogPadding]: Padding for the entire dialog.
/// - [showHeader]: Whether to show the header section.
/// - [headerHeight]: Height of the header section.
/// - [headerContent]: Custom content for the header.
/// - [headerPadding]: Padding for the header content.
/// - [titleIcon]: Icon to display above the title.
/// - [title]: Title text for the dialog.
/// - [dialogWidth]: Width of the dialog.
/// - [dialogHeight]: Height of the dialog.
/// - [componentVerticalSpacing]: Vertical spacing between components.
/// - [body]: Main content of the dialog.
/// - [onRightButtonPressed]: Callback for the right button.
/// - [onLeftButtonPressed]: Callback for the left button.
/// - [rightButtonText]: Text for the right button.
/// - [leftButtonText]: Text for the left button.
/// - [showRightButton]: Whether to show the right button.
/// - [showLeftButton]: Whether to show the left button.
/// - [barrierDismissible]: Whether the dialog can be dismissed by tapping
/// outside.
/// - [onBarrierDismissed]: Callback when the barrier is tapped
/// (if dismissible).
/// - [onAppLifecycleStateChanged]: Callback for app lifecycle state changes.
/// - [rightButtonWidth]: Width of the right button.
/// - [leftButtonWidth]: Width of the left button.
/// - [rightButtonHeight]: Height of the right button.
/// - [leftButtonHeight]: Height of the left button.
///
/// Returns a [Future] that completes with the result of the dialog.
Future<T?> showActionDialog<T>({
  required BuildContext context,
  EdgeInsets? dialogPadding,
  bool showHeader = true,
  double headerHeight = 12,
  Widget? headerContent,
  EdgeInsets? headerPadding,
  Widget? titleIcon,
  String? title,
  double? dialogWidth,
  double? dialogHeight,
  double? componentVerticalSpacing,
  Widget? body,
  void Function(BuildContext context)? onRightButtonPressed,
  void Function(BuildContext context)? onLeftButtonPressed,
  String? rightButtonText,
  String? leftButtonText,
  bool showRightButton = true,
  bool showLeftButton = true,
  bool barrierDismissible = true,
  void Function(BuildContext context)? onBarrierDismissed,
  void Function(BuildContext, AppLifecycleState)? onAppLifecycleStateChanged,
  double? rightButtonWidth,
  double? leftButtonWidth,
  double? rightButtonHeight,
  double? leftButtonHeight,
}) async =>
    showBaseGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      onBarrierDismissed: onBarrierDismissed,
      onAppLifecycleStateChanged: onAppLifecycleStateChanged,
      content: _ActionDialogContent(
        dialogPadding: dialogPadding,
        showHeader: showHeader,
        headerHeight: headerHeight,
        headerContent: headerContent,
        headerPadding: headerPadding,
        titleIcon: titleIcon,
        title: title,
        dialogWidth: dialogWidth,
        dialogHeight: dialogHeight,
        componentVerticalSpacing: componentVerticalSpacing,
        body: body,
        onRightButtonPressed: onRightButtonPressed,
        onLeftButtonPressed: onLeftButtonPressed,
        rightButtonText: rightButtonText,
        leftButtonText: leftButtonText,
        showRightButton: showRightButton,
        showLeftButton: showLeftButton,
        rightButtonWidth: rightButtonWidth,
        leftButtonWidth: leftButtonWidth,
        rightButtonHeight: rightButtonHeight,
        leftButtonHeight: leftButtonHeight,
      ),
    );

/// A widget that represents the content of an action dialog.
class _ActionDialogContent extends StatelessWidget {
  const _ActionDialogContent({
    required this.showHeader,
    required this.headerHeight,
    required this.showRightButton,
    required this.showLeftButton,
    this.dialogPadding,
    this.headerContent,
    this.headerPadding,
    this.titleIcon,
    this.title,
    this.dialogWidth,
    this.dialogHeight,
    this.componentVerticalSpacing,
    this.body,
    this.onRightButtonPressed,
    this.onLeftButtonPressed,
    this.rightButtonText,
    this.leftButtonText,
    this.rightButtonWidth,
    this.leftButtonWidth,
    this.rightButtonHeight,
    this.leftButtonHeight,
  });

  final EdgeInsets? dialogPadding;
  final bool showHeader;
  final double headerHeight;
  final Widget? headerContent;
  final EdgeInsets? headerPadding;
  final Widget? titleIcon;
  final String? title;
  final double? dialogWidth;
  final double? dialogHeight;
  final double? componentVerticalSpacing;
  final Widget? body;
  final void Function(BuildContext context)? onRightButtonPressed;
  final void Function(BuildContext context)? onLeftButtonPressed;
  final String? rightButtonText;
  final String? leftButtonText;
  final bool showRightButton;
  final bool showLeftButton;
  final double? rightButtonWidth;
  final double? leftButtonWidth;
  final double? rightButtonHeight;
  final double? leftButtonHeight;

  @override
  Widget build(BuildContext context) {
    final headerPaddingHorizontal =
        dialogWidth != null ? dialogWidth! * 0.1 : 150.0;

    final Widget headerWidget = Padding(
      padding: headerPadding ??
          EdgeInsets.symmetric(horizontal: headerPaddingHorizontal),
      child: Container(
        height: headerHeight,
        decoration: const BoxDecoration(
          color: AppColorsTheme.purple,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child: headerContent,
      ),
    );

    const fixedActionButtonSize =
        WidgetStatePropertyAll<Size>(Size.fromHeight(40));

    final Widget verticalSpace =
        SizedBox(height: componentVerticalSpacing ?? 20);

    return SizedBox(
      width: dialogWidth,
      height: dialogHeight,
      child: BaseCard(
        cardPadding:
            dialogPadding ?? const EdgeInsets.symmetric(horizontal: 100),
        contentsPadding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(5),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            if (showHeader) headerWidget,
            if (titleIcon != null) ...[
              if (showHeader) verticalSpace,
              titleIcon!,
            ],
            if (title != null) ...[
              if (showHeader) verticalSpace,
              Text(
                title!,
                style: context.appTextTheme.title6
                    .copyWith(color: AppColorsTheme.purple),
                textAlign: TextAlign.center,
              ),
            ],
            if (body != null) ...[
              if (showHeader || titleIcon != null || title != null)
                verticalSpace,
              body!,
            ],
            if (showLeftButton || showRightButton) ...[
              if (showHeader ||
                  titleIcon != null ||
                  title != null ||
                  body != null)
                verticalSpace,
              IntrinsicWidth(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (showLeftButton) ...[
                      BaseElevatedButton(
                        width: leftButtonWidth,
                        height: leftButtonHeight,
                        fixedSize: fixedActionButtonSize,
                        onPressed: () => onLeftButtonPressed?.call(context),
                        text: leftButtonText ?? context.appLocalizations.cancel,
                        textStyle: context.appTextTheme.body3
                            .copyWith(color: AppColorsTheme.purple),
                      ),
                      const SizedBox(width: 20),
                    ],
                    if (showRightButton)
                      BaseElevatedButton(
                        width: rightButtonWidth,
                        height: rightButtonHeight,
                        fixedSize: fixedActionButtonSize,
                        backgroundColor: WidgetStatePropertyAll(
                          context.appColorsTheme.primaryColor,
                        ),
                        onPressed: () => onRightButtonPressed?.call(context),
                        text: rightButtonText ?? context.appLocalizations.ok,
                        textStyle: context.appTextTheme.body3
                            .copyWith(color: AppColorsTheme.white),
                      ),
                  ],
                ),
              ),
              verticalSpace,
            ],
          ],
        ),
      ),
    );
  }
}
