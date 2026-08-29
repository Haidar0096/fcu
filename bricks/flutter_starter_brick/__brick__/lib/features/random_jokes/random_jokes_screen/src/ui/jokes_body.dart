part of 'random_jokes_screen.dart';

class _JokesBody extends StatelessWidget {
  const _JokesBody({required this.onFetchJoke});

  final VoidCallback onFetchJoke;

  @override
  Widget build(BuildContext context) => BlocBuilder<JokesCubit, JokesState>(
    builder: (context, state) => switch (state) {
      JokesInitialState() => const SizedBox.shrink(),
      JokesLoadingState(:final lastGoodJoke) => Stack(
        alignment: Alignment.center,
        children: [
          if (lastGoodJoke != null)
            SingleChildScrollView(child: JokeCard(joke: lastGoodJoke)),
          const LoaderWidget(),
        ],
      ),
      JokesLoadedState(:final joke) => SingleChildScrollView(
        child: JokeCard(joke: joke),
      ),
      JokesFailedState(:final uiFailure, :final lastGoodJoke) => Column(
        children: [
          if (lastGoodJoke != null)
            Expanded(
              child: SingleChildScrollView(
                child: JokeCard(joke: lastGoodJoke),
              ),
            ),
          StatusBannerWidget(
            type: StatusBannerType.error,
            message: uiFailure.getDisplayText(context.appLocalizations),
            actionText: context.appLocalizations.retry,
            onAction: onFetchJoke,
          ),
        ],
      ),
    },
  );
}
