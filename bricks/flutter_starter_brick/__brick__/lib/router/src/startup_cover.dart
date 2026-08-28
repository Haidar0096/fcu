part of 'router.dart';

class _StartupCover extends StatelessWidget {
  const _StartupCover({required this.onStartupComplete});

  final OnStartupCoverCompleteCallback onStartupComplete;

  @override
  Widget build(BuildContext context) => BlocProvider<SplashCubit>(
    create: (_) => serviceLocator.get<SplashCubit>(),
    child: SplashScreen(
      onNavigateToCriticalError: ({required String message}) {
        if (!context.mounted) return;
        CriticalErrorScreenRoute($extra: message).go(context);
        onStartupComplete();
      },
      onStartupComplete: onStartupComplete,
    ),
  );
}
