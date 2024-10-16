import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// A widget that displays a loading animation.
///
/// This widget is useful for indicating loading states in the application.
class BaseLoaderWidget extends StatelessWidget {
  const BaseLoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.flickr(
      rightDotColor: AppColorsTheme.blue,
      leftDotColor: AppColorsTheme.pink,
      size: 60,
    );
  }
}
