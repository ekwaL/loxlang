import 'dart:io';

import 'package:lox/src/token.dart';
import 'package:lox/src/token_types.dart';

void error(int line, String message) {
  report(line, "", message);
}

void parseError(Token token, String message) {
  if (token.type == TokenType.eof) {
    report(token.line, " at end", message);
  } else {
    report(token.line, "at '${token.lexeme}'", message);
  }
}

void report(int line, String where, String message) {
  stderr.writeln("[line $line] Error $where: $message");
}
