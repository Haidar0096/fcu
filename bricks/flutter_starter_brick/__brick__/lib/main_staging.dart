import 'package:{{proj_name}}/infrastructure/environments/src/environments.dart';
import 'package:{{proj_name}}/main_common.dart';

Future<void> main() async {
  // run the app with the staging environment
  await mainCommon(const StagingEnvironment());
}
