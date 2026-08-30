import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/ui/animations/animations.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Global loader singleton for managing app-wide loading overlays.
class GlobalLoader {
  GlobalLoader._({
    required AppLogger appLogger,
    required ErrorLogger errorLogger,
    required GlobalKey<NavigatorState> rootNavigatorKey,
  }) : _appLogger = appLogger,
       _errorLogger = errorLogger,
       _rootNavigatorKey = rootNavigatorKey;

  static const String _tag = 'GlobalLoader';

  static GlobalLoader? _instance;

  /// Gets the singleton instance. Throws if not initialized.
  static GlobalLoader get instance {
    if (_instance == null) {
      throw StateError(
        'GlobalLoader not initialized. Call GlobalLoader.init() first',
      );
    }
    return _instance!;
  }

  /// Initializes the global loader singleton.
  static void init({
    required AppLogger appLogger,
    required ErrorLogger errorLogger,
    required GlobalKey<NavigatorState> rootNavigatorKey,
  }) {
    _instance = GlobalLoader._(
      appLogger: appLogger,
      errorLogger: errorLogger,
      rootNavigatorKey: rootNavigatorKey,
    );
  }

  final AppLogger _appLogger;
  final ErrorLogger _errorLogger;
  final GlobalKey<NavigatorState> _rootNavigatorKey;
  final Set<Object> _owners = <Object>{};
  OverlayEntry? _loadingOverlay;
  Timer? _hideTimer;

  /// Acquires the global loading overlay for [owner].
  ///
  /// Returns false when no usable overlay exists, so a caller never records
  /// ownership that was not actually acquired.
  bool acquire({
    required Object owner,
    String? loadingText,
    TextStyle? loadingTextStyle,
  }) {
    _hideTimer?.cancel();
    _hideTimer = null;

    if (_owners.contains(owner) && _loadingOverlay?.mounted == true) {
      return true;
    }
    _owners.remove(owner);

    final context = _rootNavigatorKey.currentContext;

    if (context == null) {
      _appLogger.log(
        message: 'Tried to show loader using a null context',
        tag: _tag,
      );
      return false;
    }

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      _appLogger.log(
        message: 'Tried to show loader on a context that is not attached to an'
        ' overlay',
        tag: _tag,
      );
      return false;
    }

    if (_loadingOverlay != null) {
      if (_loadingOverlay!.mounted) {
        _owners.add(owner);
        return true;
      } else {
        _loadingOverlay = null;
      }
    }

    final entry = OverlayEntry(
      builder: (context) {
        final effectiveLoadingTextStyle =
            loadingTextStyle ??
            context.typography?.mediumBodyText.copyWith(
              color: context.themeData.colorScheme.onSurface,
            );

        return BlurWidget(
          applyBlur: true,
          child: DimWidget(
            applyDim: true,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Center(child: LoaderWidget()),
                  Spacing.vertical(SpacingSize.spacing24),
                  if (loadingText != null)
                    Center(
                      child: Text(
                        loadingText,
                        style: effectiveLoadingTextStyle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      overlay.insert(entry);
      _loadingOverlay = entry;
      _owners.add(owner);
      return true;
    } catch (error, stackTrace) {
      final message = 'Failed to insert the global loader overlay: $error';
      _appLogger.log(
        message: message,
        tag: _tag,
        stackTrace: stackTrace,
      );
      unawaited(
        _errorLogger.recordError(error: message, stackTrace: stackTrace),
      );
      return false;
    }
  }

  /// Releases [owner] and hides the overlay after the final owner leaves.
  void release({required Object owner}) {
    if (!_owners.remove(owner) || _owners.isNotEmpty) return;

    _hideTimer?.cancel();

    // The delay absorbs rapid show/hide cycles so the overlay does not flicker.
    _hideTimer = Timer(AnimationDefaults.animationDurationVeryShort, () {
      if (_owners.isNotEmpty) return;
      if (_loadingOverlay != null) {
        if (_loadingOverlay!.mounted) {
          try {
            _loadingOverlay!.remove();
          } catch (error, stackTrace) {
            final message = 'Failed to remove the global loader overlay: '
                '$error';
            _appLogger.log(
              message: message,
              tag: _tag,
              stackTrace: stackTrace,
            );
            unawaited(
              _errorLogger.recordError(
                error: message,
                stackTrace: stackTrace,
              ),
            );
          }
        }
        _loadingOverlay = null;
      }
      _hideTimer = null;
    });
  }
}

bool showGlobalLoader({
  required Object owner,
  String? loadingText,
  TextStyle? loadingTextStyle,
}) => GlobalLoader.instance.acquire(
      owner: owner,
      loadingText: loadingText,
      loadingTextStyle: loadingTextStyle,
    );

void hideGlobalLoader({required Object owner}) =>
    GlobalLoader.instance.release(owner: owner);
