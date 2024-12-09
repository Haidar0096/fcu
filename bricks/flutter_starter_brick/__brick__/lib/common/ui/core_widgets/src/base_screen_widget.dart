import 'dart:io';

import 'package:flutter/material.dart';
import 'package:{{proj_name}}/router/router.dart';
import 'package:{{proj_name}}/common/ui/core_widgets/src/base_blur_widget.dart';
import 'package:{{proj_name}}/common/ui/core_widgets/src/base_dim_widget.dart';
import 'package:{{proj_name}}/common/ui/core_widgets/src/base_loader_widget.dart';
import 'package:{{proj_name}}/common/ui/theme/theme.dart';

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
    this.applyAppBar = false,
  });

  /// The main content of the screen.
  final Widget body;

  /// Whether to apply SafeArea to the screen.
  final bool applySafeArea;

  /// Whether to apply the app bar.
  final bool applyAppBar;

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

  static const loadingIndicatorSpacing = 24.0;

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = context.themeData.colorScheme.surface;
    final defaultAppBarBackgroundColor =
        context.themeData.colorScheme.surfaceContainer;
    final defaultSafeAreaBackgroundColor =
        context.themeData.colorScheme.surfaceContainerHighest;
    const defaultAppBarElevation = 0.0;

    final effectiveSafeAreaBackgroundColor =
        safeAreaBackgroundColor ?? defaultSafeAreaBackgroundColor;
    final effectiveBackgroundColor = backgroundColor ?? defaultBackgroundColor;
    final effectiveAppBarBackgroundColor =
        appBarBackgroundColor ?? defaultAppBarBackgroundColor;

    Widget result = Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: applyAppBar
          ? AppBar(
              toolbarHeight: appBarToolbarHeight,
              backgroundColor: effectiveAppBarBackgroundColor,
              elevation: appBarElevation ?? defaultAppBarElevation,
              title: DefaultTextStyle(
                style: context.typography?.title3 ?? const TextStyle(),
                child: appBarTitle ?? const SizedBox(),
              ),
              leading: appBarLeading,
              actions: appBarActions,
              centerTitle: centerAppBarTitle,
            )
          : null,
      backgroundColor: effectiveBackgroundColor,
      body: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: body,
      ),
    );

    if (applySafeArea) {
      result = ColoredBox(
        color: effectiveSafeAreaBackgroundColor,
        child: SafeArea(
          bottom: applyBottomSafeArea,
          top: applyTopSafeArea,
          right: applyRightSafeArea,
          left: applyLeftSafeArea,
          child: result,
        ),
      );
    }

    if (loading) {
      final effectiveLoadingTextStyle = loadingTextStyle ??
          context.typography?.body1.copyWith(
            color: context.themeData.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            height: 1.5,
          );
      result = Stack(
        children: [
          result,
          BaseBlurWidget(
            child: BaseDimWidget(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Center(child: BaseLoaderWidget()),
                    const SizedBox(height: loadingIndicatorSpacing),
                    if (loadingText != null)
                      Center(
                        child: Text(
                          loadingText!,
                          style: effectiveLoadingTextStyle,
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
