part of 'random_jokes_screen.dart';

class _FetchJokeButton extends StatelessWidget {
  const _FetchJokeButton({required this.onFetchJoke});

  final VoidCallback onFetchJoke;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(ThemeDefaults.screenContentPadding),
    child: MainButton(
      text: context.appLocalizations.tellMeAJoke,
      onPressed: onFetchJoke,
    ),
  );
}
