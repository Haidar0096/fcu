import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

/// A widget that represents a screen with common properties and functionality.
///
/// This widget serves as the root widget of a screen, providing consistent
/// styling and behavior across the application.
class RootScreenWidget extends StatelessWidget {
  const RootScreenWidget({
    required this.body,
    required this.canPop,
    required this.applySafeArea,
    required this.resizeToAvoidBottomInset,
    required this.applyTopSafeArea,
    required this.applyBottomSafeArea,
    required this.applyStartSafeArea,
    required this.applyEndSafeArea,
    this.backgroundColor,
    this.safeAreaBackgroundColor,
    this.padding,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.scaffoldKey,
    super.key,
  });

  /// The main content of the screen.
  final Widget body;

  /// Whether to apply SafeArea to the screen.
  final bool applySafeArea;

  /// The background color of the screen.
  final Color? backgroundColor;

  /// The background color of the SafeArea.
  final Color? safeAreaBackgroundColor;

  /// Padding to apply to the body. Typed as a geometry so screens can hand
  /// down the directional (start/end) form and stay RTL-safe.
  final EdgeInsetsGeometry? padding;

  /// Controls the resizing behavior when the keyboard appears.
  final bool resizeToAvoidBottomInset;

  /// Whether the screen can be popped.
  final bool canPop;

  /// Whether to apply SafeArea to the top edge.
  final bool applyTopSafeArea;

  /// Whether to apply SafeArea to the bottom edge.
  final bool applyBottomSafeArea;

  /// Whether to apply SafeArea to the leading edge.
  final bool applyStartSafeArea;

  /// Whether to apply SafeArea to the trailing edge.
  final bool applyEndSafeArea;

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
      // SafeArea exposes physical left/right switches, so the app direction
      // maps the public start/end decision onto them here.
      final isLeftToRight = Directionality.of(context) == TextDirection.ltr;
      result = ColoredBox(
        color: effectiveSafeAreaBackgroundColor,
        child: SafeArea(
          bottom: applyBottomSafeArea,
          top: applyTopSafeArea,
          right: isLeftToRight ? applyEndSafeArea : applyStartSafeArea,
          left: isLeftToRight ? applyStartSafeArea : applyEndSafeArea,
          child: result,
        ),
      );
    }

    // PopScope feeds the screen's decision into every framework back path,
    // including the route's edge-bound, direction-aware iOS back gesture.
    result = PopScope(canPop: canPop, child: result);

    return result;
  }
}
