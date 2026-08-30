import 'package:flutter/material.dart';
import 'package:{{proj_name}}/foundation/ui/global_loader/global_loader.dart';

/// Mixin that handles global loader state management for widgets.
///
/// This mixin tracks whether a loader is shown and ensures proper cleanup
/// on dispose to prevent memory leaks.
///
/// Example usage:
/// ```dart
/// class MyWidget extends StatefulWidget {
///   @override
///   State<MyWidget> createState() => _MyWidgetState();
/// }
///
/// class _MyWidgetState extends State<MyWidget> with LoaderStateMixin {
///   void _onState(BuildContext context, MyState state) =>
///       changeLoaderVisibility(show: state.isLoading);
/// }
/// ```
mixin LoaderStateMixin<T extends StatefulWidget> on State<T> {
  final Object _loaderOwner = Object();
  bool _isLoaderShown = false;

  /// Changes the visibility of the global loader.
  ///
  /// Shows the global loader when [show] is true and it's not already
  /// shown. Hides the global loader when [show] is false and it's
  /// currently shown.
  void changeLoaderVisibility({required bool show}) {
    if (show && !_isLoaderShown) {
      _isLoaderShown = showGlobalLoader(owner: _loaderOwner);
    } else if (!show && _isLoaderShown) {
      hideGlobalLoader(owner: _loaderOwner);
      _isLoaderShown = false;
    }
  }

  @override
  void dispose() {
    // Ensure loader is hidden if widget is disposed while loading
    if (_isLoaderShown) {
      hideGlobalLoader(owner: _loaderOwner);
    }
    super.dispose();
  }
}
