import 'package:{{proj_name}}/common/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:{{proj_name}}/common/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/common/ui/theme/theme.dart';
import 'package:{{proj_name}}/router/router.dart';
{{#has_ic}}
import 'package:fconnectivity/fconnectivity.dart';
{{/has_ic}}
import 'package:{{proj_name}}/common/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:{{proj_name}}/common/ui/core_widgets/core_widgets.dart';

import 'global_scaffold_key.dart';
import 'root_blocs_provider.dart';

/// The root widget of the application.
///
/// This widget sets up the BLoC providers, routing, theming, and localization
/// for the entire app.{{#has_ic}} It also handles connectivity status.{{/has_ic}}  
class RootAppWidget extends State{{#has_ic}}fulWidget{{/has_ic}}{{^has_ic}}lessWidget{{/has_ic}} {
  /// Creates a [RootAppWidget].
  const RootAppWidget({super.key});

  {{#has_ic}}
  @override
  State<RootAppWidget> createState() => _RootAppWidgetState();
}

class _RootAppWidgetState extends State<RootAppWidget> {
  bool _isFirstCapturedState = true;
  {{/has_ic}}

  @override
  Widget build(BuildContext context) => RootBlocsProvider(
        builder: (context) => AutoLightDarkModeBuilder(
          builder: (context, themeState) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              theme: themeState.themeData,
              builder: (context, routerWidget) => Builder(
                builder: (context) {
                  {{#has_ic}}var{{/has_ic}}{{^has_ic}}final{{/has_ic}} result = routerWidget!;

                  {{#has_ic}}
                  // Wrap the result widget with the InternetAccessCubitListener
                  result = InternetAccessListener(
                    onInternetAccessGained: (BuildContext context) {
                      // TODO({{dev_name}}): handle connected state
                      if (!_isFirstCapturedState) {
                        context.showSuccessSnackBar(
                          text: context.appLocalizations.connected,
                        );
                      }
                      _isFirstCapturedState = false;
                    },
                    onInternetAccessLost: (BuildContext context) {
                      // TODO({{dev_name}}): handle disconnected state
                      context.showErrorSnackBar(
                        text: context.appLocalizations.disconnected,
                      );
                      _isFirstCapturedState = false;
                    },
                    child: result,
                  );
                  {{/has_ic}}

                  // Wrap the result with a scaffold with a global key
                  // to be used to show snackbars from anywhere in the app
                  {{#has_ic}}result = {{/has_ic}}{{^has_ic}}return {{/has_ic}}Scaffold(
                    key: globalScaffoldKey,
                    resizeToAvoidBottomInset: false,
                    body: result,
                  );

                  {{#has_ic}}return result;{{/has_ic}}
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
