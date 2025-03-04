import 'package:fconnectivity/fconnectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/common/widgets/src/root_blocs_provider.dart';
import 'package:{{proj_name}}/infrastructure/l10n/l10n.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';
import 'package:{{proj_name}}/resources/resources.dart';
import 'package:{{proj_name}}/router/router.dart';

/// The root widget of the application.
///
/// This widget sets up the BLoC providers, routing, theming, and localization
/// for the entire app. It also handles connectivity status.
class RootAppWidget extends StatefulWidget {
  /// Creates a [RootAppWidget].
  const RootAppWidget({super.key});

  @override
  State<RootAppWidget> createState() => _RootAppWidgetState();
}

class _RootAppWidgetState extends State<RootAppWidget> {
  bool _isFirstCapturedState = true;

  @override
  Widget build(BuildContext context) => RootBlocsProvider(
    builder:
        (context) => AutoLightDarkModeBuilder(
          builder:
              (context, theme) => MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: router,
                theme: theme.themeData,
                builder:
                    (context, routerWidget) => Builder(
                      builder: (context) {
                        Widget result = Overlay(
                          initialEntries: [
                            OverlayEntry(builder: (context) => routerWidget!),
                          ],
                        );

                        // Wrap the result widget with the
                        // InternetAccessCubitListener
                        result = InternetAccessListener(
                          onInternetAccessGained: (BuildContext context) {
                            // TODO(Haidar): handle connected state
                            if (!_isFirstCapturedState) {
                              context.showSuccessSnackBar(
                                text: context.appLocalizations.connected,
                              );
                            }
                            _isFirstCapturedState = false;
                          },
                          onInternetAccessLost: (BuildContext context) {
                            // TODO(Haidar): handle disconnected state
                            context.showErrorSnackBar(
                              text: context.appLocalizations.disconnected,
                            );
                            _isFirstCapturedState = false;
                          },
                          child: result,
                        );

                        result = Scaffold(
                          resizeToAvoidBottomInset: false,
                          body: result,
                        );

                        return result;
                      },
                    ),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: Locale.fromSubtags(
                  languageCode: context.watch<LocalizationCubit>().state.code,
                ),
              ),
        ),
  );
}
