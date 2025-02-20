import 'dart:io';

import 'package:flutter_cli_utils/src/command_runner.dart';

Future<void> main(List<String> args) async =>
    _flushThenExit(await FlutterCliUtilsCommandRunner().run(args));

/// Flushes the stdout and stderr streams, then exits the program with the given
/// status code.
///
/// This returns a Future that will never complete, since the program will have
/// exited already. This is useful to prevent Future chains from proceeding
/// after you've decided to exit.
Future<void> _flushThenExit(int status) => Future.wait<void>([
  stdout.close(),
  stderr.close(),
]).then<void>((_) => exit(status));
