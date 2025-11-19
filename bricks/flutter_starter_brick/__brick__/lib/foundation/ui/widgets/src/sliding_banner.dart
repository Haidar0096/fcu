import 'dart:async';

import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/animations/animations.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Default constants for sliding banners.
class SlidingBannerDefaults {
  static const Duration defaultDuration = Duration(seconds: 6);
  static const Duration errorDuration = Duration(seconds: 6);
  static const Duration successDuration = Duration(seconds: 4);
  static const Duration warningDuration = Duration(seconds: 5);
  static const Duration infoDuration = Duration(seconds: 4);
  static const Duration slideDuration = AnimationDefaults.animationDuration;
  static const double swipeThreshold = -5;
}

/// A unified banner that slides from the top of the screen.
/// Replaces both snackbars and static banners with a consistent experience.
class SlidingBanner {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;
  static String? _currentMessage;
  static GlobalKey<_SlidingBannerWidgetState>? _currentKey;

  /// Shows a sliding banner with the specified configuration.
  static Future<void> show({
    required BuildContext context,
    required StatusBannerType type,
    required String message,
    Duration duration = SlidingBannerDefaults.defaultDuration,
    VoidCallback? onAction,
    String? actionText,
    VoidCallback? onDismiss,
    bool autoDismiss = true,
  }) async {
    // Prevent duplicate messages
    if (_currentMessage == message && _currentEntry != null) {
      return;
    }

    // Hide existing banner if present (don't wait for animation)
    if (_currentEntry != null) {
      hide();
    }

    _currentMessage = message;

    if (!context.mounted) return;
    final overlay = Overlay.of(context);

    // Create a global key to access the widget's dismiss method
    final widgetKey = GlobalKey<_SlidingBannerWidgetState>();
    _currentKey = widgetKey;

    _currentEntry = OverlayEntry(
      builder:
          (context) => _SlidingBannerWidget(
            key: widgetKey,
            type: type,
            message: message,
            onAction: onAction,
            actionText: actionText,
            onDismiss: () {
              hide();
              onDismiss?.call();
            },
          ),
    );

    overlay.insert(_currentEntry!);

    // Set up auto-dismiss timer if enabled
    if (autoDismiss) {
      _dismissTimer = Timer(duration, () {
        // Check if widget still exists and trigger animation before removing
        final state = widgetKey.currentState;
        if (state != null && state.mounted) {
          unawaited(state._dismiss());
        } else {
          // Fallback: immediately hide if widget is gone
          hide();
        }
      });
    }
  }

  /// Shows an error banner.
  static void showError({
    required BuildContext context,
    required String message,
    Duration? duration,
    VoidCallback? onAction,
    String? actionText,
  }) => show(
    context: context,
    type: StatusBannerType.error,
    message: message,
    duration: duration ?? SlidingBannerDefaults.errorDuration,
    onAction: onAction,
    actionText: actionText,
  );

  /// Shows a success banner.
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) => show(
    context: context,
    type: StatusBannerType.success,
    message: message,
    duration: duration ?? SlidingBannerDefaults.successDuration,
  );

  /// Shows a warning banner.
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) => show(
    context: context,
    type: StatusBannerType.warning,
    message: message,
    duration: duration ?? SlidingBannerDefaults.warningDuration,
  );

  /// Shows an info banner.
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration? duration,
  }) => show(
    context: context,
    type: StatusBannerType.info,
    message: message,
    duration: duration ?? SlidingBannerDefaults.infoDuration,
  );

  /// Hides the current banner if one is showing.
  static void hide() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
    _currentMessage = null;
    _currentKey = null;
  }
}

/// Internal widget that renders the sliding banner.
class _SlidingBannerWidget extends StatefulWidget {
  const _SlidingBannerWidget({
    required this.type,
    required this.message,
    required this.onDismiss,
    this.onAction,
    this.actionText,
    super.key,
  });

  final StatusBannerType type;
  final String message;
  final VoidCallback? onAction;
  final String? actionText;
  final VoidCallback onDismiss;

  @override
  State<_SlidingBannerWidget> createState() => _SlidingBannerWidgetState();
}

class _SlidingBannerWidgetState extends State<_SlidingBannerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: SlidingBannerDefaults.slideDuration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    // Cancel any pending auto-dismiss timer
    SlidingBanner._dismissTimer?.cancel();
    SlidingBanner._dismissTimer = null;

    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    // Get safe area padding
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            // Allow swipe up to dismiss
            if (details.delta.dy < SlidingBannerDefaults.swipeThreshold) {
              unawaited(_dismiss());
            }
          },
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: EdgeInsets.only(
                  top: topPadding + SpacingSize.spacing8.value,
                  left: SpacingSize.spacing16.value,
                  right: SpacingSize.spacing16.value,
                  bottom: SpacingSize.spacing8.value,
                ),
                child: StatusBannerWidget(
                  type: widget.type,
                  message: widget.message,
                  onAction: widget.onAction,
                  actionText: widget.actionText,
                  onDismiss: _dismiss,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension on BuildContext for easy access to sliding banner methods.
extension SlidingBannerBuildContextExtension on BuildContext {
  /// Shows a sliding banner with custom configuration.
  void showSlidingBanner({
    required StatusBannerType type,
    required String message,
    Duration duration = SlidingBannerDefaults.defaultDuration,
    VoidCallback? onAction,
    String? actionText,
    VoidCallback? onDismiss,
    bool autoDismiss = true,
  }) => SlidingBanner.show(
    context: this,
    type: type,
    message: message,
    duration: duration,
    onAction: onAction,
    actionText: actionText,
    onDismiss: onDismiss,
    autoDismiss: autoDismiss,
  );

  /// Shows an error sliding banner.
  void showErrorBanner({
    required String message,
    Duration? duration,
    VoidCallback? onAction,
    String? actionText,
  }) => SlidingBanner.showError(
    context: this,
    message: message,
    duration: duration,
    onAction: onAction,
    actionText: actionText,
  );

  /// Shows a success sliding banner.
  void showSuccessBanner({required String message, Duration? duration}) =>
      SlidingBanner.showSuccess(
        context: this,
        message: message,
        duration: duration,
      );

  /// Shows a warning sliding banner.
  void showWarningBanner({required String message, Duration? duration}) =>
      SlidingBanner.showWarning(
        context: this,
        message: message,
        duration: duration,
      );

  /// Shows an info sliding banner.
  void showInfoBanner({required String message, Duration? duration}) =>
      SlidingBanner.showInfo(
        context: this,
        message: message,
        duration: duration,
      );

  /// Hides the current sliding banner.
  void hideSlidingBanner() => SlidingBanner.hide();
}
