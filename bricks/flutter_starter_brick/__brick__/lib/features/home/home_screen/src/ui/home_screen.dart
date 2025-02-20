import 'package:flutter/material.dart';
import 'package:{{proj_name}}/infrastructure/ui/theme/theme.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => RootScreenWidget(
    body: Center(child: Text('Home Screen', style: context.typography?.title3)),
  );
}
