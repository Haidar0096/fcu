import 'package:flutter/widgets.dart';
import 'package:{{proj_name}}/dependency_injection_impl/dependency_injection_impl.dart';
import 'package:{{proj_name}}/infrastructure/dependency_injection/dependency_injection.dart';

final ServiceProvider serviceProvider = GetItServiceProvider();

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigatorKey',
);
