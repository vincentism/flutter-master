// // import 'package:cli/cli.dart' as cli;
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:command_runner/command_runner.dart';

// const version = '0.0.1';

// void main(List<String> arguments) {
//   print('arguments $arguments');
//   if (arguments.isEmpty) {
//     print('Hello world');
//   } else if (arguments.first == 'version') {
//     print('version $version');
//   } else if (arguments.first == 'wikipedia') {
//     final inputArgs = arguments.length > 1 ? arguments.sublist(1) : null;
//     searchWikipedia(inputArgs);
//     print('Search command recognized!');
//   } else {
//     printUsage();
//   }
// }


// void printUsage () {
//   print(
//     "The following commands are valid: 'help', 'version', 'search <ARTICLE-TITLE>'"
//   );
// }

// void searchWikipedia(List<String>? arguments) async {
//   late String? articleTitle;
  
//   if (arguments == null || arguments.isEmpty) {
//     print('Please provide an article title.');
//     final inputFromStdin = stdin.readLineSync();
//     if (inputFromStdin == null || inputFromStdin.isEmpty) {
//       return;
//     }
//     articleTitle = inputFromStdin;
//   } else {
//     articleTitle = arguments.join(' ');
//   }

//   var res = await getWikipediaArticles(articleTitle);
//   print(res);
// }

// Future <String> getWikipediaArticles(String articleTitle) async {
//   final client = http.Client();
//   final url  = Uri.https(
//     'en.wikipedia.org',
//     '/api/rest_v1/page/summary/$articleTitle',
//   );

//   print(url);

//   final response = await client.get(url);

//   if (response.statusCode == 200) {
//     return response.body;
//   }

//   return 'Error: Failed to fetch article "$articleTitle". Status code: ${response.statusCode}';

// }


import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:command_runner/command_runner.dart';

const version = '0.0.1';

void main(List<String> arguments) { // main is now async and awaits the runner
  var commandRunner = CommandRunner(
    onError: (Object error) async {
      if (error is Error) {
        throw error;
      }
      if (error is Exception) {
        print(error);
      }
    },
  )..addCommand(HelpCommand()); // Create an instance of your new CommandRunner
  commandRunner.run(arguments);
}
