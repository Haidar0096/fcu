import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:{{proj_name}}/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/features/critical_error_screen/critical_error_screen.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes.dart';
import 'package:{{proj_name}}/features/splash_screen/splash_screen.dart';
import 'package:{{proj_name}}/foundation/ui/navigation/navigation.dart';
import 'package:{{proj_name}}/router/src/route_paths.dart';

part 'router.g.dart';

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: $appRoutes,
  initialLocation: SplashRoutePath.path,
  debugLogDiagnostics: kDebugMode,
  redirect: (context, state) {
    final currentPath = state.matchedLocation;

    // Get current route type - handle unknown routes
    final RoutePath currentRoute;
    try {
      currentRoute = RoutePath.fromPath(currentPath);
    } catch (e) {
      // Unknown/invalid route path - show error screen
      return CriticalErrorRoutePath.path;
    }

    // TODO({{dev_name}}): Add auth guard here when authentication is 
    // implemented
    // Example:
    // final authBloc = serviceLocator.tryGet<AuthenticationBloc>();
    // if (authBloc == null) return null;
    // final authState = authBloc.state;
    // if (!authState.isAuthenticated && currentRoute.requiresAuth) {
    //   return LoginRoutePath.path;
    // }


    // If all checks above passed, let the app go to the requested route
    return null;
  },
);

/// Returns a [Page] based on the platform.
Page<T> _getPageByPlatform<T>({
  required Widget child,
  required LocalKey pageKey,
}) {
  if (kIsWeb) {
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

@TypedGoRoute<SplashScreenRoute>(path: SplashRoutePath.path)
@immutable
class SplashScreenRoute extends GoRouteData with $SplashScreenRoute {
  const SplashScreenRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        child: BlocProvider.value(
          value: serviceLocator.get<SplashCubit>(),
          child: SplashScreen(
            onNavigateToCriticalError: ({required String message}) {
              if (context.mounted) {
                CriticalErrorScreenRoute(errorMessage: message).go(context);
              }
            },
            onNavigateToRandomJokes: () {
              if (context.mounted) {
                const RandomJokesScreenRoute().go(context);
              }
            },
          ),
        ),
      );
}

@TypedGoRoute<CriticalErrorScreenRoute>(path: CriticalErrorRoutePath.path)
@immutable
class CriticalErrorScreenRoute extends GoRouteData
    with $CriticalErrorScreenRoute {
  const CriticalErrorScreenRoute({this.errorMessage});
  final String? errorMessage;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        child: CriticalErrorScreen(errorMessage: errorMessage),
      );
}

@TypedGoRoute<RandomJokesScreenRoute>(path: RandomJokesRoutePath.path)
@immutable
class RandomJokesScreenRoute extends GoRouteData with $RandomJokesScreenRoute {
  const RandomJokesScreenRoute();
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        child: BlocProvider(
          create: (_) => serviceLocator.get<JokesCubit>(),
          child: const RandomJokesScreen(),
        ),
      );
}
