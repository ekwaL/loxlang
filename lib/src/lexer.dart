import 'dart:async';

import 'peeking_iterator.dart';
import 'token.dart';
import 'token_types.dart';
import 'char_codes.dart' as codes;

typedef TT = TokenType;
typedef CodePoint = int;

// symbolToUnicode = {
// }

class Lexer {
  // final StreamIterator<int> _source;
  final Stream<PeekingIterable<int>> _source;
  int offset = 0;
  int line = 1;
  int lineOffset = 1;

  Lexer(Stream<PeekingIterable<int>> this._source) : super();
  // Lexer(Stream<int> source)
  // : _source = StreamIterator(source),
  // :  super();

  Stream<Token> tokens() async* {
    await for (final runes in _source) {
    }
    // add eof token at the end
    yield Token(type: TT.eof, lexeme: '', line: line);
  }

  bool get isAtEnd => nextRune == 0;

  bool _match(int expected) {
    if (isAtEnd) return false;
    if (nextRune != expected) return false;

    shouldLookedAhead = true;
    return true;
  }

  void _scanToken() {
    switch (currentRune) {
      case codes.symbolNull:
        // addToken(TT.eof);
        break;
      // Symbol-tokens
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
      case codes.bang:
        addToken(_match(codes.equal) ? TT.bangEqual : TT.bang);
        break;
      case codes.equal:
        addToken(_match(codes.equal) ? TT.equalEqual : TT.equal);
        break;
      case codes.less:
        addToken(_match(codes.equal) ? TT.lessEqual : TT.less);
        break;
      case codes.greater:
        addToken(_match(codes.equal) ? TT.greaterEqual : TT.greater);
        break;
      case codes.slash:
        if (_match(codes.slash)) {
        } else {
          addToken(TT.slash);
        }
        break;
      // Literals
      // Keywords
      default:
      // TODO: ERROR!
    }
    // return null;
  }

  String _readWhile(bool Function() predicate) {
    _predicate = predicate;
    _state = LexerState.reading;


    return "";
  }

  void doneReading() {
    _state = LexerState.scanning;
  }

  Token addToken(TokenType type) {
    final token = Token(type: type, lexeme: 'lexeme', line: line);
    print(token);
    return token;
  }
}
