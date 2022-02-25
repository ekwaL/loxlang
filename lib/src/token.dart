import 'package:lox/src/token_types.dart';

class Token {
  final TokenType type;
  final String lexeme;
  final Object literal;
  final int line;

  const Token(this.type, this.lexeme, this.literal, this.line);

  @override
  String toString() {
    return "Token{type: $type, lexeme: $lexeme, literal: $literal}";
  }
}
