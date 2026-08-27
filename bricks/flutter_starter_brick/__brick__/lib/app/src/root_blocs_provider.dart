import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/foundation/app_meta_data/app_meta_data.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/locator/locator.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

/// Builds the tree that sits under the app-wide blocs.
///
/// The [BuildContext] it receives is a descendant of the providers below, so
/// everything it builds can read them.
typedef RootBlocsChildBuilder = Widget Function(BuildContext context);

class RootBlocsProvider extends StatefulWidget {
  const RootBlocsProvider({required this.builder, super.key});

  final RootBlocsChildBuilder builder;

  @override
  State<RootBlocsProvider> createState() => _RootBlocsProviderState();
}

class _RootBlocsProviderState extends State<RootBlocsProvider> {
  late final LocalizationCubit _localizationCubit;
  late final ThemeCubit _themeCubit;
  late final AppMetaDataCubit _appMetaDataCubit;

  @override
  void initState() {
    super.initState();
    _localizationCubit = serviceLocator.get<LocalizationCubit>();
    _themeCubit = serviceLocator.get<ThemeCubit>();
    _appMetaDataCubit = serviceLocator.get<AppMetaDataCubit>();
    unawaited(_appMetaDataCubit.init());
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      // TODO({{dev_name.paramCase()}}): Add app-specific global blocs here
      BlocProvider<LocalizationCubit>.value(value: _localizationCubit),
      BlocProvider<ThemeCubit>.value(value: _themeCubit),
      BlocProvider<AppMetaDataCubit>.value(value: _appMetaDataCubit),
    ],
    child: Builder(builder: widget.builder),
  );
}
