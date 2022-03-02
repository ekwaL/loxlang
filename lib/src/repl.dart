import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:lox/src/ast_printer.dart';
import 'package:lox/src/expr.dart';
import 'package:lox/src/interpreter.dart';
import 'package:lox/src/lexer.dart';
import 'package:lox/src/parser.dart';
import 'package:lox/src/peeking_iterator.dart';

const replWelcomeMessage = """
This is a Lox REPL.
More info on usage later.
""";

void repl(Stream<List<int>> input, IOSink output) async {
  output.writeln(replWelcomeMessage);

  // final userInput =
  //     StreamController<PeekingIterable<int>>(); // UTF32 Code points (Runes)

  // final lexer = Lexer(userInput.stream);
  // final tokens = lexer.tokens();

  var line = 1;
  output.write("lox:${_lineNumberToString(line)}> ");

  await for (final code in _readLine()) {
    // userInput.add(PeekingIterable((code + '\n').runes));
    final lexer = Lexer(PeekingIterable((code + '\n').runes));
    final tokens = lexer.getTokens();
    final parser = Parser(tokens.iterator);
    final Expr? expression = parser.parse();

    if (expression == null) return;
    // if (hadError) return;
    // for (final token in tokens) {
    //   output.writeln(token);
    // }

    output.writeln(AstPrinter().print(expression));

    final interpreter = Interpreter();
    interpreter.interpret(expression);

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
