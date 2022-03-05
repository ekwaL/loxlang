import 'dart:io';

import 'package:lox/src/interpreter.dart';
import 'package:lox/src/token.dart';
import 'package:lox/src/token_types.dart';

bool hadError = false;
bool hadRuntimeError = false;

void error(int line, String message) {
  hadError = true;
  report(line, "", message);
}

void parseError(Token token, String message) {
  hadError = true;
  if (token.type == TokenType.eof) {
    report(token.line, " at end", message);
  } else {
    report(token.line, "at '${token.lexeme}'", message);
  }
}

void runtimeError(RuntimeError error) {
  stderr.writeln(error.message);
  stderr.writeln("[line ${error.token.line}]");
  hadRuntimeError = true;
}

void report(int line, String where, String message) {
  stderr.writeln("[line $line] Error $where: $message");
}
