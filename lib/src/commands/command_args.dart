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

class CommandOption extends CommandArg<String> {
  const CommandOption({
    required super.name,
    required super.defaultsTo,
    required super.prompt,
    super.abbr,
    super.help,
    super.choices,
  });
}

class CommandMultiOption extends CommandArg<List<String>> {
  const CommandMultiOption({
    required super.name,
    required super.defaultsTo,
    required super.prompt,
    super.abbr,
    super.help,
    super.choices,
  });
}

class CommandFlag extends CommandArg<bool> {
  const CommandFlag({
    required super.name,
    required super.defaultsTo,
    required super.prompt,
    super.abbr,
    super.help,
    super.choices,
  });
}