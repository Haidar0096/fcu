import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

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
    this.drawer,
    this.endDrawer,
    this.scaffoldKey,
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

  /// The drawer to display.
  final Widget? drawer;

  /// The end drawer to display.
  final Widget? endDrawer;

  /// The scaffold key to control the scaffold.
  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final defaultBackgroundColor = context.themeData.colorScheme.surface;
    final defaultSafeAreaBackgroundColor =
        context.themeData.colorScheme.surface;

    final effectiveSafeAreaBackgroundColor =
        safeAreaBackgroundColor ?? defaultSafeAreaBackgroundColor;
    final effectiveBackgroundColor = backgroundColor ?? defaultBackgroundColor;

    Widget result = Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: effectiveBackgroundColor,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
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
      // Check web first to avoid Platform calls on web
      if (kIsWeb || !Platform.isIOS) {
        // For non-iOS devices, use the default WillPopScope
        result = PopScope(canPop: canPop!, child: result);
      } else {
        // There is a bug in OnWillPopScope on iOS, it does not work with back
        // gestures. This is a workaround.
        result = GestureDetector(
          onHorizontalDragUpdate: (details) async {
            const sensitivity = RootScreenWidgetDefaults.swipeSensitivity;

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

class RootScreenWidgetDefaults {
  static const int swipeSensitivity = 20;
}
