import 'dart:io';

import 'package:lox/lox.dart';
import 'package:lox/src/char_codes.dart';
import 'package:lox/src/error.dart';
import 'package:lox/src/peeking_iterator.dart';
import 'package:lox/src/resolver.dart';
import 'package:lox/src/stmt.dart';

const usageInfo = """
Usage:
lox [script]  to run script
lox           to run REPL
""";

void main(List<String> arguments) {
  switch (arguments.length) {
    case 0:
      _runREPL();
      break;
    case 1:
      _runFile(arguments[0]);
      break;
    default:
      print(usageInfo);
      codes();
      exit(64);
  }
}

void _runREPL() {
  repl(stdin, stdout);
}

void _runFile(String path) {
  try {
    final sourceFile = File(path);
    // TODO: Throws a FormatException
    // https://api.dart.dev/stable/2.16.1/dart-convert/Utf8Decoder-class.html
    // Stream<String> sourceCode = sourceFile.openRead().transform(utf8.decoder);

    String sourceCode = sourceFile.readAsStringSync();

    final lexer = Lexer(PeekingIterable(sourceCode.runes));
    final tokens = lexer.getTokens();

    final parser = Parser(tokens.iterator);
    final List<Stmt> statements = parser.parse();

    stdout.writeln(AstPrinter().printStatements(statements));

    final interpreter = Interpreter();
    final resolver = Resolver(interpreter);
    if (!hadError) resolver.resolve(statements);

    if (!hadError) interpreter.interpret(statements);
  } catch (error) {
    stderr
        .writeln('Could not open file $path : $error'); // or can not decode it
  } finally {}
}
