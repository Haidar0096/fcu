import 'package:{{proj_name}}/infrastructure/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A widget that displays the app version and build number.
/// If the app version is not available, a shrinked sized box is shown.
class AppVersionTextWidget extends StatelessWidget {
  const AppVersionTextWidget({
    super.key,
    this.style,
    this.emptyWidget = const SizedBox.shrink(),
  });

  /// The style to use for the text.
  final TextStyle? style;

  /// Widget to display when the version string is empty.
  final Widget emptyWidget;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppMetaDataCubit, AppMetaDataState>(
        builder: (context, appMetaDataState) {
          if (appMetaDataState.appVersionAndBuildNumberString.isNotEmpty) {
            return Text(
              appMetaDataState.appVersionAndBuildNumberString,
              style: style ?? context.typography?.body3,
            );
          }
          return emptyWidget;
        },
      );
}
