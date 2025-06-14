import 'package:flutter/material.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/models/ui_models/ui_joke.dart';

class JokeCard extends StatelessWidget {
  const JokeCard({required this.joke, super.key});

  final UiJoke joke;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(joke.content, textAlign: TextAlign.center),
    ),
  );
}
