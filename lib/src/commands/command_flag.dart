part of 'command_arg.dart';

class CommandFlag extends CommandArg<bool> {
  const CommandFlag({
    required super.name,
    required super.defaultsTo,
    required super.prompt,
    super.abbr,
    super.help,
    super.choices,
    super.aliases,
  });
}
