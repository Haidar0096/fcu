// The variants are `part` files because a sealed family must live in one
// library.
part 'command_flag.dart';
part 'command_multi_option.dart';
part 'command_option.dart';

sealed class CommandArg<T> {
  const CommandArg({
    required this.name,
    required this.defaultsTo,
    required this.prompt,
    this.abbr,
    this.help,
    this.choices,
  });

  final String name;
  final String? abbr;
  final String? help;
  final T defaultsTo;
  final String prompt;
  final List<String>? choices;
}
