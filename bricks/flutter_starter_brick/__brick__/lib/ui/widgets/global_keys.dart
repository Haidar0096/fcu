import 'package:flutter/material.dart';

/// A global key for a [Scaffold] that is above all other widgets. It can
/// be used to show snackbars from anywhere in the app.
final GlobalKey<ScaffoldState> globalScaffoldKey =
    GlobalKey(debugLabel: 'global_scaffold_key');
