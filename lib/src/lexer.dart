import 'dart:async';

import 'package:lox/src/token.dart';
import 'package:lox/src/token_types.dart';

typedef TT = TokenType;
typedef CodePoint = int;

class Lexer {
  final Stream<int> _source;

  Lexer(this._source) : super();

  Stream<Token> tokens() async* {
    await for(final ch in _source) {
      _scanToken(ch);
      // yield Token();
    }
  }

  Token? _scanToken(int ch) {
    // print(ch);
    printSync(ch);
    return null;
  }
}
