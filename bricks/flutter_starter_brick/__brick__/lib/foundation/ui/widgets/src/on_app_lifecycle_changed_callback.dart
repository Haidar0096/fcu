import 'package:flutter/widgets.dart';

/// Handles an app lifecycle change supplied by an overlay wrapper.
typedef OnAppLifecycleChangedCallback =
    void Function(AppLifecycleState lifecycleState);
