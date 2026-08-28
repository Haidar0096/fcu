import 'dart:async';

import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/animations/animations.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

part 'sliding_banner_widget.dart';

/// Default constants for sliding banners.
abstract final class SlidingBannerDefaults {
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

  /// Shows a sliding banner with the specified configuration.
  static Future<void> show({
    required BuildContext context,
    required StatusBannerType type,
    required String message,
    required bool autoDismiss,
    Duration? duration,
    VoidCallback? onAction,
    String? actionText,
    VoidCallback? onDismiss,
  }) async {
    if (_currentMessage == message && _currentEntry != null) {
      return;
    }

    if (_currentEntry != null) {
      hide();
    }

    _currentMessage = message;

    if (!context.mounted) return;
    final overlay = Overlay.of(context);

    final widgetKey = GlobalKey<_SlidingBannerWidgetState>();

    _currentEntry = OverlayEntry(
      builder: (context) => _SlidingBannerWidget(
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

    if (autoDismiss) {
      _dismissTimer = Timer(
        duration ?? SlidingBannerDefaults.defaultDuration,
        () {
        final state = widgetKey.currentState;
        if (state != null && state.mounted) {
          unawaited(state._dismiss());
        } else {
          hide();
        }
        },
      );
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
    autoDismiss: true,
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
    autoDismiss: true,
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
    autoDismiss: true,
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
    autoDismiss: true,
  );

  /// Hides the current banner if one is showing.
  static void hide() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
    _currentMessage = null;
  }
}

/// Extension on BuildContext for easy access to sliding banner methods.
extension SlidingBannerBuildContextExtension on BuildContext {
  /// Shows a sliding banner with custom configuration.
  void showSlidingBanner({
    required StatusBannerType type,
    required String message,
    required bool autoDismiss,
    Duration? duration,
    VoidCallback? onAction,
    String? actionText,
    VoidCallback? onDismiss,
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
