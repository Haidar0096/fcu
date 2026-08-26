part of 'command_arg.dart';

class CommandOption extends CommandArg<String> {
  const CommandOption({
    required super.name,
    required super.defaultsTo,
    required super.prompt,
    super.abbr,
    super.help,
    super.choices,
    super.aliases,
  });
}
