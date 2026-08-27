import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

Page<T> platformPage<T>({
  required Widget child,
  required LocalKey pageKey,
  required String screenName,
}) => NoTransitionPage(child: child, key: pageKey, name: screenName);
