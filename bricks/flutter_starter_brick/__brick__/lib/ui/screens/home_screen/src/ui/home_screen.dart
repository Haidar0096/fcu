import 'package:{{proj_name}}/services/dependency_injection/dependency_injection.dart';
import 'package:{{proj_name}}/ui/screens/home_screen/src/cubit/counter_cubit.dart';
import 'package:{{proj_name}}/ui/styles/app_styles.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/base_screen_widget.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/filled_button.dart';
import 'package:{{proj_name}}/ui/widgets/core_widgets/shallow_button.dart';
import 'package:flutter/material.dart' hide FilledButton;
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = 'home_screen';

  @override
  Widget build(BuildContext context) => BlocProvider<CounterCubit>(
        create: (context) => ServiceProvider.get(),
        child: Builder(
          builder: (context) => BaseScreenWidget(
            centerAppBarTitle: true,
            appBarTitle: Text(
              'Counter App',
              style: context.appTextTheme.title4
                  .copyWith(color: AppColorsTheme.gold),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: BlocBuilder<CounterCubit, int>(
                      builder: (context, counterState) {
                        return Text(
                          'Counter value: $counterState',
                          style: context.appTextTheme.body2,
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                  FilledButton(
                    text: 'Increment',
                    onPressed: context.read<CounterCubit>().increment,
                    backgroundColor: AppColorsTheme.green,
                  ),
                  const SizedBox(height: 10),
                  ShallowButton(
                    color: AppColorsTheme.gold,
                    text: 'Decrement',
                    onPressed: context.read<CounterCubit>().decrement,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
