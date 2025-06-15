import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes.dart';
import 'package:go_router/go_router.dart';
import 'package:{{proj_name}}/common/variables/variables.dart';
import 'package:{{proj_name}}/features/error_screen/error_screen.dart';
import 'package:{{proj_name}}/features/splash_screen/splash_screen.dart';

part 'router.g.dart';

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: $appRoutes,
  initialLocation: _SplashScreenRoute.path,
);

/// Returns a [Page] based on the platform.
Page<T> _getPageByPlatform<T>({
  required Widget child,
  required LocalKey pageKey,
}) {
  if(kIsWeb) {
    return NoTransitionPage(child: child);
  }
  if (Platform.isAndroid) {
    return MaterialPage(child: child, key: pageKey);
  }
  if (Platform.isIOS || Platform.isMacOS) {
    return CupertinoPage(child: child, key: pageKey);
  }
  return MaterialPage(child: child, key: pageKey);
}

@TypedGoRoute<_SplashScreenRoute>(path: _SplashScreenRoute.path)
@immutable
class _SplashScreenRoute extends GoRouteData with _$_SplashScreenRoute{
  const _SplashScreenRoute();

  static const String path = '/splash_screen';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        child: SplashScreen(
          onShouldNavigateToRandomJokesScreen:
              () => const _RandomJokesScreenRoute().go(context),
          onShouldNavigateToErrorScreen:
              () => const _ErrorScreenRoute().go(context),
        ),
      );
}

@TypedGoRoute<_RandomJokesScreenRoute>(path: _RandomJokesScreenRoute.path)
@immutable
class _RandomJokesScreenRoute extends GoRouteData with _$_RandomJokesScreenRoute {
  const _RandomJokesScreenRoute();

  static const String path = '/random_jokes_screen';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        child: BlocProvider(
          create: (_) => serviceProvider.get<JokesCubit>(),
          child: const RandomJokesScreen(),
        ),
      );
}

@TypedGoRoute<_ErrorScreenRoute>(path: _ErrorScreenRoute.path)
@immutable
class _ErrorScreenRoute extends GoRouteData  with _$_ErrorScreenRoute {
  const _ErrorScreenRoute({this.errorMessage});

  static const String path = '/error_screen';

  final String? errorMessage;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        child: ErrorScreen(errorMessage: errorMessage),
      );
}
