import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/random_jokes/src/blocs/jokes_cubit/jokes_cubit.dart';
import 'package:{{proj_name}}/features/random_jokes/src/ui/joke_card.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Screen for displaying random jokes
class RandomJokesScreen extends StatelessWidget {
  const RandomJokesScreen({super.key});

  @override
  Widget build(BuildContext context) => const RootScreenWidget(
    body: Column(
      children: [
        Expanded(child: Center(child: _JokesBody())),
        _FetchJokeButton(),
      ],
    ),
  );
}

class _JokesBody extends StatelessWidget {
  const _JokesBody();

  @override
  Widget build(BuildContext context) => BlocBuilder<JokesCubit, JokesState>(
    builder: (context, state) => switch (state) {
      JokesInitial() => const SizedBox.shrink(),
      JokesLoading() => const LoaderWidget(),
      JokesLoaded(:final joke) => SingleChildScrollView(
        child: JokeCard(joke: joke),
      ),
      JokesFailed(:final uiFailure) => StatusBannerWidget(
        type: StatusBannerType.error,
        message: uiFailure.getDisplayText(context),
        actionText: context.appLocalizations.retry,
        onAction: () => context.read<JokesCubit>().fetchJoke(),
      ),
    },
  );
}

class _FetchJokeButton extends StatelessWidget {
  const _FetchJokeButton();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(ThemeDefaults.screenContentPadding),
    child: MainButton(
      text: context.appLocalizations.tellMeAJoke,
      onPressed: () => context.read<JokesCubit>().fetchJoke(),
    ),
  );
}
