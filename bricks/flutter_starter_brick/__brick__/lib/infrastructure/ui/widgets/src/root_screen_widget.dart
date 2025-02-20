import 'dart:io';

import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:flutter/material.dart';

/// A widget that represents a screen with common properties and functionality.
///
/// This widget serves as the root widget of a screen, providing consistent
/// styling and behavior across the application.
class RootScreenWidget extends StatelessWidget {
  const RootScreenWidget({
    required this.body,
    super.key,
    this.applySafeArea = true,
    this.backgroundColor,
    this.safeAreaBackgroundColor,
    this.padding,
    this.resizeToAvoidBottomInset,
    this.canPop,
    this.applyTopSafeArea = true,
    this.applyBottomSafeArea = true,
    this.applyLeftSafeArea = true,
    this.applyRightSafeArea = true,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  /// The main content of the screen.
  final Widget body;

  /// Whether to apply SafeArea to the screen.
  final bool applySafeArea;

  /// The background color of the screen.
  final Color? backgroundColor;

  /// The background color of the SafeArea.
  final Color? safeAreaBackgroundColor;

  /// Padding to apply to the body.
  final EdgeInsets? padding;

  /// Controls the resizing behavior when the keyboard appears.
  final bool? resizeToAvoidBottomInset;

  /// Whether the screen can be popped.
  final bool? canPop;

  /// Whether to apply SafeArea to the top edge.
  final bool applyTopSafeArea;

  /// Whether to apply SafeArea to the bottom edge.
  final bool applyBottomSafeArea;

  /// Whether to apply SafeArea to the left edge.
  final bool applyLeftSafeArea;

  /// Whether to apply SafeArea to the right edge.
  final bool applyRightSafeArea;

  /// The app bar to display at the top of the screen.
  final PreferredSizeWidget? appBar;

  /// The bottom navigation bar to display at the bottom of the screen.
  final Widget? bottomNavigationBar;

  /// The floating action button.
  final Widget? floatingActionButton;

  /// Location of the floating action button.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = context.themeData.colorScheme.surface;
    const defaultSafeAreaBackgroundColor = black;

    final effectiveSafeAreaBackgroundColor =
        safeAreaBackgroundColor ?? defaultSafeAreaBackgroundColor;
    final effectiveBackgroundColor = backgroundColor ?? defaultBackgroundColor;

    Widget result = Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: effectiveBackgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Padding(padding: padding ?? EdgeInsets.zero, child: body),
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

    if (canPop != null) {
      if (!Platform.isIOS) {
        // For non-iOS devices, use the default WillPopScope
        result = PopScope(canPop: canPop!, child: result);
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
                Navigator.of(context).pop();
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
