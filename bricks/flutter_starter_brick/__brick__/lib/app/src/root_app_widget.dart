import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/app/src/root_blocs_provider.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/resources/resources.dart';
import 'package:{{proj_name}}/router/router.dart';

/// The root widget of the application.
///
/// This widget sets up the BLoC providers, routing, theming, and localization
/// for the entire app.
class RootAppWidget extends StatefulWidget {
  /// Creates a [RootAppWidget].
  const RootAppWidget({super.key});

  @override
  State<RootAppWidget> createState() => _RootAppWidgetState();
}

class _RootAppWidgetState extends State<RootAppWidget> {
  bool _showStartupCover = true;

  @override
  Widget build(BuildContext context) => RootBlocsProvider(
    builder:
        (context) => BlocBuilder<ThemeCubit, {{proj_name.pascalCase()}}Theme>(
          buildWhen: (previous, current) => !identical(previous, current),
          builder:
              (context, themeState) => MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: router,
                theme: themeState.themeData,
                builder: (context, child) => AnnotatedRegion(
                  value: _systemUiOverlayStyle(context),
                  child: Directionality(
                    textDirection: context
                        .select<LocalizationCubit, TextDirection>(
                          (cubit) => cubit.state.textDirection,
                        ),
                    child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      body: Stack(
                        fit: StackFit.expand,
                        children: [
                          child!,
                          if (_showStartupCover)
                            router.startupCover(
                              onStartupComplete: _hideStartupCover,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: Locale.fromSubtags(
                  languageCode: context.select<LocalizationCubit, String>(
                    (cubit) => cubit.state.code,
                  ),
                ),
              ),
        ),
  );

  void _hideStartupCover() {
    if (!mounted || !_showStartupCover) return;
    setState(() => _showStartupCover = false);
  }

  SystemUiOverlayStyle _systemUiOverlayStyle(BuildContext context) {
    final theme = context.themeData;
    final iconBrightness = theme.brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: theme.brightness,
      statusBarIconBrightness: iconBrightness,
      systemNavigationBarColor: theme.colorScheme.surface,
      systemNavigationBarIconBrightness: iconBrightness,
    );
  }
}
