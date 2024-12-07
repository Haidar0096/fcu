import 'package:flutter/material.dart';
import 'package:{{proj_name}}/common/l10n/l10n.dart';
import 'package:{{proj_name}}/common/ui/theme/theme.dart';
import 'package:{{proj_name}}/common/ui/core_widgets/core_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => BaseScreenWidget(
        body: Center(
          child: Text(
            '{{dev_name}}, YOU ROCK ^_^',
            style: context.typography?.title1,
            textAlign: TextAlign.center,
          ),
        ),
      );
}
