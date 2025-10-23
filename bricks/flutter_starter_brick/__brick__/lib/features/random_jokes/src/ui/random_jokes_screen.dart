import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/random_jokes/src/blocs/jokes_cubit/jokes_cubit.dart';
import 'package:{{proj_name}}/features/random_jokes/src/ui/joke_card.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Screen for displaying random jokes
class RandomJokesScreen extends StatelessWidget {
  const RandomJokesScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<JokesCubit, JokesState>(
    builder: (context, state) {
      final fetchButton = MainButton(
        text: context.appLocalizations.tellMeAJoke,
        onPressed: () => context.read<JokesCubit>().fetchJoke(),
      );

      return RootScreenWidget(
        body:
            state is JokesFailed
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusBannerWidget(
                      type: StatusBannerType.error,
                      message: state.uiFailure.getDisplayText(context),
                      actionText: context.appLocalizations.retry,
                      onAction: () => context.read<JokesCubit>().fetchJoke(),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: switch (state) {
                          JokesInitial() => const SizedBox.shrink(),
                          JokesLoading() => const LoaderWidget(),
                          JokesLoaded() => SingleChildScrollView(
                            child: JokeCard(joke: state.joke),
                          ),
                          JokesFailed() =>
                            const SizedBox.shrink(), // Never reached
                        },
                      ),
                    ),
                    // Button docked at bottom
                    Padding(
                      padding: EdgeInsets.all(SpacingSize.spacing24.value),
                      child: fetchButton,
                    ),
                  ],
                ),
      );
    },
  );
}
