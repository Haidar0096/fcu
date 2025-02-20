import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class {{feature_name.pascalCase()}}Screen extends StatelessWidget {
  const {{feature_name.pascalCase()}}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return RootScreenWidget(
      body: const Center(
        child: Text(
          '{{feature_name.pascalCase()}} Screen',
          style: TextStyle(
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}
