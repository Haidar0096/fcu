import 'package:flutter/material.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';

class {{=<% %>=}}{{<%={{ }}=%>feature_name.pascalCase(){{=<% %>=}}}}<%={{ }}=%>Screen extends StatelessWidget {
  const {{=<% %>=}}{{<%={{ }}=%>feature_name.pascalCase(){{=<% %>=}}}}<%={{ }}=%>Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RootScreenWidget(
      body: Center(
        child: Text(
          '{{=<% %>=}}{{<%={{ }}=%>feature_name.pascalCase(){{=<% %>=}}}}<%={{ }}=%> Screen',
          style: TextStyle(
            fontSize: 40,
          ),
        ),
      ),
    );
  }
}
