import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'lexer.dart';

const replWelcomeMessage = """
This is a Lox REPL.
More info on usage later.
""";

final List<String> toPrint = [];

void printSync(String line) {
  toPrint.add(line);
}

void printIfAny() {
  if (toPrint.isEmpty) return;
  for (final line in toPrint) {
    print(line);
  }
  toPrint.clear();
}

void repl(Stream<List<int>> input, IOSink output) async {
  output.writeln(replWelcomeMessage);

  final userInput = StreamController<int>(); // UTF16 Code points (Runes)

  final lexer = Lexer(userInput.stream);
  final tokens = lexer.tokens();
  tokens.listen((event) {
    // printSync("Token: $event");
    stdout.writeln("Token: $event");
  });

  var line = 1;
  output.write("lox:${_lineNumberToString(line)}> ");

  await for (final code in _readLine()) {
    code.runes.forEach(userInput.add);
    // Runes(code).forEach(userInput.add);
    printIfAny();
    line++;

    // print("readline: $code");
    output.write("lox:${_lineNumberToString(line)}> ");
  }

  // _readLine().listen((e) {});

  // final input = StreamController<String>();

  // final lexer = Lexer(input.stream);
  // final tokens = lexer.tokens();
  // tokens.listen((event) {
  //   stdout.writeln("Token: $event");
  // });

  // input.stream.listen((event) {
  //   print("input: $event");
  // });

  // await for (final event in input.stream) {
  //     print("await for: $event");
  // }

  // stdin.transform(utf8.decoder).pipe(input.sink);
  // stdin.transform(utf8.decoder).listen((code) {
  // print("readline: $code");
  // input.add(code);
  // });

  // for (var line = 1;; line++) {
  //   final lineNumber = _lineNumberToString(line);
  //   stdout.write("lox:$lineNumber> ");
  //   final code = stdin.readLineSync();
  //   if (code != null) {
  //     print("readline: $code");
  //     input.sink.add(code);
  //   }
  // }
}


Stream<String> _readLine() =>
    stdin.transform(utf8.decoder).transform(const LineSplitter());

String _lineNumberToString(int line) {
  if (line ~/ 10 == 0) return "00$line";
  if (line ~/ 100 == 0) return "0$line";
  return line.toString();
}
