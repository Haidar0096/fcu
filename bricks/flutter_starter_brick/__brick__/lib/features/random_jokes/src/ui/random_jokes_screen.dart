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
        body: Column(
          children: [
            // Error banner if there's an error
            if (state is JokesFailed)
              StatusBannerWidget(
                type: StatusBannerType.error,
                message: state.uiFailure.getDisplayText(context),
                actionText: context.appLocalizations.retry,
                onAction: () => context.read<JokesCubit>().fetchJoke(),
              ),

            // Main content
            Expanded(
              child: Center(
                child: switch (state) {
                  JokesInitial() => fetchButton,
                  JokesLoading() => const LoaderWidget(),
                  JokesLoaded() => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      JokeCard(joke: state.joke),
                      const Spacing.vertical(SpacingSize.small),
                      fetchButton,
                    ],
                  ),
                  JokesFailed() => const SizedBox.shrink(), // Error handled by banner
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
