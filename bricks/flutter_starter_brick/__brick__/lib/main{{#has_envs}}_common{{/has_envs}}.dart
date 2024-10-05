import 'package:flutter/material.dart';
{{#has_envs}}import 'package:{{proj_name}}/environments/environments.dart';{{/has_envs}}

Future<void> main{{#has_envs}}Common{{/has_envs}}({{#has_envs}}Environment env{{/has_envs}}) async {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Hello World!',
          ),
        ),
      ),
    ),
  );
}
