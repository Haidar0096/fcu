import 'dart:io';

import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_blur_widget.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_dim_widget.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A widget that represents a screen with common properties and functionality.
/// 
/// This widget serves as the root widget of a screen, providing consistent
/// styling and behavior across the application.
class BaseScreenWidget extends StatelessWidget {
  const BaseScreenWidget({
    required this.body,
    super.key,
    this.applySafeArea = true,
    this.backgroundColor,
    this.safeAreaBackgroundColor,
    this.appBarBackgroundColor,
    this.padding,
    this.loading = false,
    this.loadingText,
    this.loadingTextStyle,
    this.resizeToAvoidBottomInset,
    this.canPop,
    this.appBarToolbarHeight,
    this.appBarElevation,
    this.appBarTitle,
    this.appBarLeading,
    this.appBarActions,
    this.centerAppBarTitle,
    this.applyTopSafeArea = true,
    this.applyBottomSafeArea = true,
    this.applyLeftSafeArea = true,
    this.applyRightSafeArea = true,
  });

  /// The main content of the screen.
  final Widget body;

  /// Whether to apply SafeArea to the screen.
  final bool applySafeArea;

  /// The background color of the screen.
  final Color? backgroundColor;

  /// The background color of the SafeArea.
  final Color? safeAreaBackgroundColor;

  /// The background color of the AppBar.
  final Color? appBarBackgroundColor;

  /// Padding to apply to the body.
  final EdgeInsets? padding;

  /// Whether to show a loading indicator.
  final bool loading;

  /// Text to display below the loading indicator.
  final String? loadingText;

  /// Style for the loading text.
  final TextStyle? loadingTextStyle;

  /// Controls the resizing behavior when the keyboard appears.
  final bool? resizeToAvoidBottomInset;

  /// Whether the screen can be popped.
  final bool? canPop;

  /// The height of the AppBar toolbar.
  final double? appBarToolbarHeight;

  /// The elevation of the AppBar.
  final double? appBarElevation;

  /// The title widget for the AppBar.
  final Widget? appBarTitle;

  /// The leading widget for the AppBar.
  final Widget? appBarLeading;

  /// The action widgets for the AppBar.
  final List<Widget>? appBarActions;

  /// Whether to center the AppBar title.
  final bool? centerAppBarTitle;

  /// Whether to apply SafeArea to the top edge.
  final bool applyTopSafeArea;

  /// Whether to apply SafeArea to the bottom edge.
  final bool applyBottomSafeArea;

  /// Whether to apply SafeArea to the left edge.
  final bool applyLeftSafeArea;

  /// Whether to apply SafeArea to the right edge.
  final bool applyRightSafeArea;

  @override
  Widget build(BuildContext context) {
    var result = body;

    final defaultBackgroundColor = context.appColorsTheme.background;
    const defaultSafeAreaBackgroundColor = AppColorsTheme.black;

    if (applySafeArea) {
      result = ColoredBox(
        color: safeAreaBackgroundColor ?? defaultSafeAreaBackgroundColor,
        child: SafeArea(
          bottom: applyBottomSafeArea,
          top: applyTopSafeArea,
          right: applyRightSafeArea,
          left: applyLeftSafeArea,
          child: Scaffold(
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            appBar: AppBar(
              toolbarHeight: appBarToolbarHeight,
              backgroundColor: appBarBackgroundColor ?? safeAreaBackgroundColor,
              elevation: appBarElevation,
              title: appBarTitle,
              leading: appBarLeading,
              actions: appBarActions,
              centerTitle: centerAppBarTitle,
            ),
            backgroundColor: backgroundColor ?? defaultBackgroundColor,
            body: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: body,
            ),
          ),
        ),
      );
    }

    if (loading) {
      result = Stack(
        children: [
          result,
          // Loader with dim and blur effect
          BaseBlurWidget(
            child: BaseDimWidget(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Center(child: BaseLoaderWidget()),
                    const SizedBox(height: 20),
                    if (loadingText != null)
                      Center(
                        child: Text(
                          loadingText!,
                          style: loadingTextStyle ??
                              const TextStyle(
                                color: AppColorsTheme.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (canPop != null) {
      if (!Platform.isIOS) {
        // For non-iOS devices, use the default WillPopScope
        result = PopScope(
          canPop: canPop!,
          child: result,
        );
      } else {
        // There is a bug in OnWillPopScope on iOS, it does not work with back
        // gestures. This is a workaround.
        result = GestureDetector(
          onHorizontalDragUpdate: (details) async {
            const sensitivity = 20;

            if (details.delta.dx > sensitivity) {
              // Swipe from left to right. Pop the screen.
              if (canPop!) {
                if (!context.mounted) return;
                context.pop();
              }
            }
          },
          child: PopScope(
            // Prevent the user from using back gestures to exit the screen
            // (this is handled by the GestureDetector above)
            canPop: false,
            child: result,
          ),
        );
      }
    }

    return result;
  }
}
