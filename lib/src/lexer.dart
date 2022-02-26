import 'dart:async';

import 'token.dart';
import 'token_types.dart';
import 'char_codes.dart' as codes;

typedef TT = TokenType;
typedef CodePoint = int;

// symbolToUnicode = {
// }

class Lexer {
  // final StreamIterator<int> _source;
  final Stream<int> _source;
  int offset = 0;
  int line = 0;
  int lineOffset = 0;
  final List<int> prefixRunes = [];

  Lexer(Stream<int> this._source) : super();
  // Lexer(Stream<int> source)
  // : _source = StreamIterator(source),
  // :  super();

  Stream<Token> tokens() async* {
    await for (final rune in _source) {
      _scanToken(rune);
      // yield Token();

      // count lines/offsets
      offset++;
      lineOffset++;
      if (rune == codes.newLine) {
        line++;
        lineOffset = 0;
      }
    }

    // add eof token at the end
    yield Token(type: TT.eof, lexeme: '', line: line);
  }

  void _scanToken(int rune) {
    switch (rune) {
      // Single-character tokens
      case codes.leftParen:
        addToken(TT.leftParen);
        break;
      case codes.rightParen:
        addToken(TT.rightParen);
        break;
      case codes.leftBrace:
        addToken(TT.leftBrace);
        break;
      case codes.rightBrace:
        addToken(TT.rightBrace);
        break;
      case codes.comma:
        addToken(TT.comma);
        break;
      case codes.dot:
        addToken(TT.dot);
        break;
      case codes.minus:
        addToken(TT.minus);
        break;
      case codes.plus:
        addToken(TT.plus);
        break;
      case codes.semicolon:
        addToken(TT.semicolon);
        break;
      case codes.star:
        addToken(TT.star);
        break;
      case codes.star:
        addToken(TT.star);
        break;
      case codes.star:
        addToken(TT.star);
        break;
      case codes.star:
        addToken(TT.star);
        break;
      case codes.star:
        addToken(TT.star);
        break;
      case codes.star:
        addToken(TT.star);
        break;
      case codes.star:
        addToken(TT.star);
        break;
      case codes.star:
        addToken(TT.star);
        break;
      // case codes.slash:
      default:
      // TODO: ERROR!
    }
    // return null;
  }

  Token addToken(TokenType type) {
    final token = Token(type: type, lexeme: 'lexeme', line: line);
    print(token);
    return token;
  }
}
