import 'package:{{proj_name}}/foundation/environments/environments.dart';
import 'package:{{proj_name}}/main_common.dart';

Future<void> main() async {
  // run the app with the production environment
  await mainCommon(Environment.production);
}
