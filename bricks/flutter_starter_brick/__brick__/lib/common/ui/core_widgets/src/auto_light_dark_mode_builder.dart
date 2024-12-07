import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/common/ui/theme/theme.dart';

class AutoLightDarkModeBuilder extends StatefulWidget {
  const AutoLightDarkModeBuilder({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext, {{proj_name.pascalCase()}}Theme) builder;

  @override
  State<AutoLightDarkModeBuilder> createState() =>
      _AutoLightDarkModeBuilderState();
}

class _AutoLightDarkModeBuilderState extends State<AutoLightDarkModeBuilder> {
  late final ThemeCubit _themeCubit;

  @override
  void initState() {
    super.initState();
    _themeCubit = context.read<ThemeCubit>();
  }

  @override
  void didChangeDependencies() {
    final brightness = MediaQuery.platformBrightnessOf(context);
    _themeCubit.setTheme(
      brightness == Brightness.light
          ? {{proj_name.pascalCase()}}ThemeLight.instance
          : {{proj_name.pascalCase()}}ThemeDark.instance,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        _themeCubit.state,
      );
}
