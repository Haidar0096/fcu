import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/common/variables/variables.dart';
import 'package:{{proj_name}}/infrastructure/blocs/app_meta_data_cubit/app_meta_data_cubit.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    required this.onShouldNavigateToHomeScreen,
    required this.onShouldNavigateToErrorScreen,
    super.key,
  });

  static const routeName = 'splash_screen';

  final void Function() onShouldNavigateToHomeScreen;

  final void Function() onShouldNavigateToErrorScreen;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(
      const Duration(milliseconds: 1500),
    ).then((_) => serviceProvider.get<AppMetaDataCubit>().init());
  }

  Future<void> _enableEdgeToEdge() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<AppMetaDataCubit, AppMetaDataState>(
        listener: (context, appMetaDataState) async {
          switch (appMetaDataState) {
            case AppMetaDataInitial():
            case AppMetaDataLoading():
              // no action needed for these states
              break;
            case AppMetaDataLoaded():
              await _enableEdgeToEdge();
              widget.onShouldNavigateToHomeScreen();
            case AppMetaDataLoadingFailed():
              await _enableEdgeToEdge();
              widget.onShouldNavigateToErrorScreen();
          }
        },
        builder:
            (context, appMetaDataState) => RootScreenWidget(
              backgroundColor: context.themeData.colorScheme.surface,
              applySafeArea: false,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: const AspectRatio(
                      aspectRatio: 2 / 1,
                      child: FlutterLogo(),
                    ),
                  ),
                ),
              ),
            ),
      );
}
