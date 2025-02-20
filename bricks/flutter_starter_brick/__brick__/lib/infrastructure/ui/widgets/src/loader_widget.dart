import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// A widget that displays a loading animation.
///
/// This widget is useful for indicating loading states in the application.
class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.fallingDot(color: yellow, size: 100);
  }
}
