import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'lexer.dart';
import 'peeking_iterator.dart';

const replWelcomeMessage = """
This is a Lox REPL.
More info on usage later.
""";

void repl(Stream<List<int>> input, IOSink output) async {
  output.writeln(replWelcomeMessage);

  final userInput =
      StreamController<PeekingIterable<int>>(); // UTF32 Code points (Runes)

  final lexer = Lexer(userInput.stream);
  // final tokens = lexer.tokens();

  var line = 1;
  output.write("lox:${_lineNumberToString(line)}> ");

  await for (final code in _readLine()) {
    userInput.add(PeekingIterable((code + '\n').runes));

    line++;

    output.write("lox:${_lineNumberToString(line)}> ");
  }
}

Stream<String> _readLine() =>
    stdin.transform(utf8.decoder).transform(const LineSplitter());

String _lineNumberToString(int line) {
  if (line ~/ 10 == 0) return "00$line";
  if (line ~/ 100 == 0) return "0$line";
  return line.toString();
}
