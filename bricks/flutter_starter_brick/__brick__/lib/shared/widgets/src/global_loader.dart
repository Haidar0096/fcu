import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/shared/variables/variables.dart';
import 'package:{{proj_name}}/infrastructure/logging/logging.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';

OverlayEntry? _loadingOverlay;

void showGlobalLoader({String? loadingText, TextStyle? loadingTextStyle}) {
  final context = rootNavigatorKey.currentContext;

  final appLogger = serviceProvider.get<AppLogger>();

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

  hideGlobalLoader();

  _loadingOverlay = OverlayEntry(
    builder: (context) {
      final effectiveLoadingTextStyle =
          loadingTextStyle ??
          context.typography?.body1.copyWith(
            color: context.themeData.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            height: 1.5,
          );

      return BlurWidget(
        child: DimWidget(
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                const Center(child: LoaderWidget()),
                VerticalSpacing.medium,
                if (loadingText != null)
                  Center(
                    child: Text(loadingText, style: effectiveLoadingTextStyle),
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

void hideGlobalLoader() {
  if (_loadingOverlay?.mounted ?? false) {
    _loadingOverlay?.remove();
  }
  _loadingOverlay = null;
}
