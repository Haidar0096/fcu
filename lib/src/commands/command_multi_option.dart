part of 'command_arg.dart';

class CommandMultiOption extends CommandArg<List<String>> {
  const CommandMultiOption({
    required super.name,
    required super.defaultsTo,
    required super.prompt,
    super.abbr,
    super.help,
    super.choices,
    super.aliases,
  });
}
