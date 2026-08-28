import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/blocs/jokes_cubit/jokes_cubit.dart';
import 'package:{{proj_name}}/features/random_jokes/random_jokes_screen/src/ui/joke_card.dart';
import 'package:{{proj_name}}/foundation/l10n/l10n.dart';
import 'package:{{proj_name}}/foundation/ui/theme/theme.dart';
import 'package:{{proj_name}}/foundation/ui/widgets/widgets.dart';

part 'fetch_joke_button.dart';
part 'jokes_body.dart';

/// Screen for displaying random jokes
class RandomJokesScreen extends StatefulWidget {
  const RandomJokesScreen({super.key});

  @override
  State<RandomJokesScreen> createState() => _RandomJokesScreenState();
}

class _RandomJokesScreenState extends State<RandomJokesScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_fetchJoke());
  }

  @override
  Widget build(BuildContext context) => RootScreenWidget(
    canPop: false,
    applySafeArea: true,
    resizeToAvoidBottomInset: true,
    applyTopSafeArea: true,
    applyBottomSafeArea: true,
    applyStartSafeArea: true,
    applyEndSafeArea: true,
    body: Column(
      children: [
        Expanded(child: Center(child: _JokesBody(onFetchJoke: _fetchJoke))),
        _FetchJokeButton(onFetchJoke: _fetchJoke),
      ],
    ),
  );

  Future<void> _fetchJoke() => context.read<JokesCubit>().fetchJoke();
}
