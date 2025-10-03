import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Global loader singleton for managing app-wide loading overlays.
class GlobalLoader {
  GlobalLoader._({required this.appLogger, required this.rootNavigatorKey});

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
    required GlobalKey<NavigatorState> rootNavigatorKey,
  }) {
    _instance = GlobalLoader._(
      appLogger: appLogger,
      rootNavigatorKey: rootNavigatorKey,
    );
  }

  final AppLogger appLogger;
  final GlobalKey<NavigatorState> rootNavigatorKey;
  OverlayEntry? _loadingOverlay;
  Timer? _hideTimer;

  /// Shows the global loading overlay.
  void show({String? loadingText, TextStyle? loadingTextStyle}) {
    // Cancel any pending hide operation
    _hideTimer?.cancel();
    _hideTimer = null;

    final context = rootNavigatorKey.currentContext;

    if (context == null) {
      appLogger.log('Tried to show loader using a null context');
      return;
    }

    if (Overlay.maybeOf(context) == null) {
      appLogger.log(
        'Tried to show loader on a context that is not attached to an'
        ' overlay',
      );
      return;
    }

    // If loader already exists and is mounted, don't create a new one
    if (_loadingOverlay != null) {
      if (_loadingOverlay!.mounted) {
        return;
      } else {
        _loadingOverlay = null;
      }
    }

    _loadingOverlay = OverlayEntry(
      builder: (context) {
        final effectiveLoadingTextStyle =
            loadingTextStyle ??
            context.typography?.mediumBodyText.copyWith(
              color: context.themeData.colorScheme.onSurface,
            );

        return BlurWidget(
          child: DimWidget(
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Center(child: LoaderWidget()),
                  const Spacing.vertical(SpacingSize.medium),
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

    Overlay.of(context).insert(_loadingOverlay!);
  }

  /// Hides the global loading overlay.
  void hide() {
    // Cancel any pending hide operation
    _hideTimer?.cancel();

    // Schedule the hide with a small delay to handle rapid show/hide cycles
    _hideTimer = Timer(const Duration(milliseconds: 50), () {
      if (_loadingOverlay != null) {
        if (_loadingOverlay!.mounted) {
          try {
            _loadingOverlay!.remove();
          } catch (e) {
            appLogger.log('Error removing loader overlay: $e');
          }
        }
        _loadingOverlay = null;
      }
      _hideTimer = null;
    });
  }
}

// Convenience functions that delegate to the singleton
void showGlobalLoader({String? loadingText, TextStyle? loadingTextStyle}) {
  GlobalLoader.instance.show(
    loadingText: loadingText,
    loadingTextStyle: loadingTextStyle,
  );
}

void hideGlobalLoader() {
  GlobalLoader.instance.hide();
}
