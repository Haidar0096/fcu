import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/common/widgets/widgets.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/blocs/jokes_cubit/jokes_cubit.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/ui/joke_card.dart';
import 'package:{{proj_name}}/infrastructure/l10n/l10n.dart';
import 'package:{{proj_name}}/infrastructure/ui/widgets/widgets.dart';

class RandomJokesScreen extends StatelessWidget {
  const RandomJokesScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocConsumer<JokesCubit, JokesState>(
    listener: (context, state) {
      switch (state) {
        case JokesInitial():
        case JokesLoading():
        case JokesLoaded():
          // No action needed for these states.
          break;
        case JokesFailed():
          context.showErrorSnackBar(text: state.message);
      }
    },
    builder: (context, state) {
      final fetchButton = MainButton(
        text: context.appLocalizations.tellMeAJoke,
        onPressed: () => context.read<JokesCubit>().fetch(),
      );
      return RootScreenWidget(
        body: Center(
          child: switch (state) {
            JokesLoading() => const LoaderWidget(),
            JokesLoaded() => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                JokeCard(joke: state.joke),
                const SizedBox(height: 16),
                fetchButton,
              ],
            ),
            _ => fetchButton,
          },
        ),
      );
    },
  );
}
