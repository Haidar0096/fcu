import 'package:flutter/material.dart';
{{#has_envs}}import 'package:{{proj_name}}/services/environments/environments.dart';{{/has_envs}}
{{#has_di}}import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';{{/has_di}}

Future<void> main{{#has_envs}}Common{{/has_envs}}({{#has_envs}}Environment env{{/has_envs}}) async {
  WidgetsFlutterBinding.ensureInitialized();

  {{#has_di}}
  await ServiceProvider.init({{#has_envs}}environment: env{{/has_envs}});
  {{/has_di}}

  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    ),
  );
}
