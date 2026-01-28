import 'dart:io';


const String ansiEscapeLiteral = '\x1B';


Future<void> write(String text, {int duration = 50}) async {
  final List<String> lines = text.split('\n');
  for (final String l in lines) {
    await _delayedPrint('$l \n', duration: duration);
  }
}



Future<void> _delayedPrint (String text, {int duration = 0}) async {
  return Future<void>.delayed(
    Duration(milliseconds: duration),
    () => stdout.write(text),
  );
}

enum ConsoleColor {
  lightBlue(184, 234, 254),

  red(242, 93, 80),

  /// Light yellow - #F9F8C4
  yellow(249, 248, 196),

  /// Light grey, good for text, #F8F9FA
  grey(240, 240, 240),

  ///
  white(255, 255, 255);

  const ConsoleColor(this.r, this.g, this.b);

  final int r;
  final int g;
  final int b;

  String get enableForeground => '$ansiEscapeLiteral[38;2;$r;$g;${b}m';
  String get enableBackground => '$ansiEscapeLiteral[48;2;$r;$g;${b}m';

  static String get reset => '$ansiEscapeLiteral[0m';

  String applyForeground(String text) {
    return '$ansiEscapeLiteral[38;2;$r;$g;${b}m$text$reset';
  }

 String applyBackground(String text) {
    return '$ansiEscapeLiteral[48;2;$r;$g;${b}m$text$ansiEscapeLiteral[0m';
  }


}