import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:{{proj_name}}/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/features/critical_error_screen/critical_error_screen.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes.dart';
import 'package:{{proj_name}}/features/splash_screen/splash_screen.dart';
import 'package:{{proj_name}}/foundation/ui/navigation/navigation.dart';
import 'package:{{proj_name}}/router/src/route_paths.dart';
import 'package:{{proj_name}}/router/src/router_constants.dart';

part 'router.g.dart';

final GoRouter router = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: $appRoutes,
  initialLocation: SplashRoutePath.path,
  redirect: (context, state) {
    final splashCubit = serviceLocator.tryGet<SplashCubit>();

    if (splashCubit == null) {
      return null; // During initialization
    }

    final splashState = splashCubit.state;
    final currentPath = state.matchedLocation;

    // Get current route type - handle unknown routes
    final RoutePath currentRoute;
    try {
      currentRoute = RoutePath.fromPath(currentPath);
    } catch (e) {
      // Unknown/invalid route path - show error screen
      return CriticalErrorRoutePath.path;
    }

    // Handle critical error state from any route
    if (currentRoute.isSplashRoute && splashState is SplashCriticalError) {
      return Uri(
        path: CriticalErrorRoutePath.path,
        queryParameters: {
          if (splashState.errorMessage != null)
            QueryParamKeys.errorMessage: splashState.errorMessage,
        },
      ).toString();
    }

    // Handle splash screen completion - navigate to main app
    if (currentRoute.isSplashRoute && splashState.isComplete) {
      return RandomJokesRoutePath.path;
    }

    // If all checks above passed, let the app go to the requested route
    return null;
  },
  refreshListenable: _GoRouterRefreshStream([
    serviceLocator.get<SplashCubit>().stream.asBroadcastStream(),
  ]),
);

/// Adapter to make multiple bloc streams work with GoRouter refresh
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(List<Stream<dynamic>> streams) {
    // Trigger an immediate redirect evaluation when the router is created.
    // This ensures the app navigates to the correct initial route based on
    // the current state (auth, splash, subscription) without waiting for
    // a state change. Without this, the app would stay on the initial
    // location until one of the streams emits a new value.
    notifyListeners();

    // Use RxDart's combineLatest to listen to all streams
    // TODO({{dev_name}}): Currently only using SplashCubit, but this pattern
    // supports multiple streams (auth, user prefs, etc.) for future scaling
    // Start with current values to ensure immediate emission
    _subscription = Rx.combineLatestList(
      streams.map((stream) => stream.startWith(null)).toList(),
    ).listen((states) => notifyListeners());
  }

  late final StreamSubscription<List<dynamic>> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

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

@TypedGoRoute<_SplashScreenRoute>(path: SplashRoutePath.path)
@immutable
class _SplashScreenRoute extends GoRouteData with _$_SplashScreenRoute {
  const _SplashScreenRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        child: BlocProvider.value(
          value: serviceLocator.get<SplashCubit>(),
          child: const SplashScreen(),
        ),
      );
}

@TypedGoRoute<_CriticalErrorScreenRoute>(path: CriticalErrorRoutePath.path)
@immutable
class _CriticalErrorScreenRoute extends GoRouteData
    with _$_CriticalErrorScreenRoute {
  const _CriticalErrorScreenRoute({this.errorMessage});

  final String? errorMessage;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        child: CriticalErrorScreen(
          errorMessage: errorMessage,
        ),
      );
}

@TypedGoRoute<_RandomJokesScreenRoute>(path: RandomJokesRoutePath.path)
@immutable
class _RandomJokesScreenRoute extends GoRouteData with _$_RandomJokesScreenRoute {
  const _RandomJokesScreenRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) =>
      _getPageByPlatform<void>(
        pageKey: state.pageKey,
        child: BlocProvider(
          create: (_) => serviceLocator.get<RandomJokesCubit>(),
          child: const RandomJokesScreen(),
        ),
      );
}