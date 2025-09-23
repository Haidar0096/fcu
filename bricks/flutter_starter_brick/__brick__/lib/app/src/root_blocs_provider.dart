import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/foundation/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';

class RootBlocsProvider extends StatefulWidget {
  const RootBlocsProvider({required this.builder, super.key});

  final Widget Function(BuildContext) builder;

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
      // TODO({{dev_name}}): Add app-specific global blocs here
      BlocProvider<LocalizationCubit>.value(
        value: _localizationCubit,
      ),
      BlocProvider<ThemeCubit>.value(
        value: _themeCubit,
      ),
      BlocProvider<AppMetaDataCubit>.value(
        value: _appMetaDataCubit,
      ),
    ],
    child: Builder(builder: widget.builder),
  );
}
