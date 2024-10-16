import 'package:bloc/bloc.dart';
import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';
{{#has_envs}}import 'package:{{proj_name}}/services/environments/environments.dart';{{/has_envs}}

@Service()
class CounterCubit extends Cubit<int> {
  {{#has_envs}}
  CounterCubit()
      : super(ServiceProvider.get<Environment>().initialCounterValue);
  {{/has_envs}}
  {{^has_envs}}
  CounterCubit() : super(0);
  {{/has_envs}}

  final int _incrementValue = ServiceProvider.get<int>(
    instanceName: DependencyInjectionInstances.incrementValue,
  );

  void increment() => emit(state + _incrementValue);

  void decrement() => emit(state - _incrementValue);
}
