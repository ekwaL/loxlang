import 'dart:io';

import 'package:lox/lox.dart';
import 'package:lox/src/peeking_iterator.dart';
import 'package:test/test.dart';

void main() {
  group('examples', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('lox run test', () {
      List<String> files = ["print.lox"];
      for (final path in files) {
        try {
          final sourceFile = File(path);
          String sourceCode = sourceFile.readAsStringSync();

          final lexer = Lexer(PeekingIterable(sourceCode.runes));
          final tokens = lexer.getTokens();

          final parser = Parser(tokens.iterator);

          final interpreter = Interpreter();
          interpreter.interpret(parser.parse());
        } catch (error) {
          stderr.writeln('Could not open file $path : $error');
        }
      }
    });
  });
}
