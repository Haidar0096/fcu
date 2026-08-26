import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/foundation/logging/logging.dart';
import 'package:{{proj_name}}/foundation/ui/animations/animations.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Global loader singleton for managing app-wide loading overlays.
class GlobalLoader {
  GlobalLoader._({required this.appLogger, required this.rootNavigatorKey});

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
    _hideTimer?.cancel();
    _hideTimer = null;

    final context = rootNavigatorKey.currentContext;

    if (context == null) {
      appLogger.log('Tried to show loader using a null context', tag: _tag);
      return;
    }

    if (Overlay.maybeOf(context) == null) {
      appLogger.log(
        'Tried to show loader on a context that is not attached to an'
        ' overlay',
        tag: _tag,
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
                  SizedBox(height: SpacingSize.spacing24.value),
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
    _hideTimer?.cancel();

    // The delay absorbs rapid show/hide cycles so the overlay does not flicker.
    _hideTimer = Timer(AnimationDefaults.animationDurationVeryShort, () {
      if (_loadingOverlay != null) {
        if (_loadingOverlay!.mounted) {
          try {
            _loadingOverlay!.remove();
          } catch (e) {
            appLogger.log('Error removing loader overlay: $e', tag: _tag);
          }
        }
        _loadingOverlay = null;
      }
      _hideTimer = null;
    });
  }
}

void showGlobalLoader({String? loadingText, TextStyle? loadingTextStyle}) {
  GlobalLoader.instance.show(
    loadingText: loadingText,
    loadingTextStyle: loadingTextStyle,
  );
}

void hideGlobalLoader() {
  GlobalLoader.instance.hide();
}
