import 'package:flutter/material.dart';
import 'package:{{proj_name}}/features/random_jokes/src/models/ui_models/ui_joke.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

/// Card widget for displaying a joke
class JokeCard extends StatelessWidget {
  const JokeCard({
    required this.joke,
    super.key,
  });

  final UiJoke joke;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.all(Spacing.medium),
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(Spacing.large),
      child: Text(
        joke.content,
        style: context.typography?.body2,
        textAlign: TextAlign.center,
      ),
    ),
  );
}
