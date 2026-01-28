import 'dart:async';
import 'package:command_runner/command_runner.dart';
import 'console.dart';
import 'exceptions.dart';

class HelpCommand extends Command {
  HelpCommand() {
    addFlag(
      'verbose',
      abbr: 'v',
      help: 'when true, this command will print each command and its options.',
    );
    addOption(
      'command',
      abbr: 'c',
      help: "When a command is passed as an argument, prints only that command's verbose usage.",
    );
  }

  @override
  String get name => 'help';

  @override
  String get description => 'Prints usage information to the command line.';

  @override
  String? get help => 'Prints this usage information';

  @override
  FutureOr<Object?> run(ArgResults args) async {
    final buffer = StringBuffer();
    buffer.writeln(runner.usage.titleText);
    if (args.flag('verbose')) {
      

    }
  }
}