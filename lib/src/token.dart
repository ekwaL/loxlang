import 'token_types.dart';

class Token {
  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;

  const Token({
    required this.type,
    required this.lexeme,
    required this.line,
    this.literal,
  });

  @override
  String toString() {
    return "Token{type: $type, lexeme: $lexeme, literal: $literal, line: $line}";
  }
}
