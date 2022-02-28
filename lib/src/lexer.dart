import 'peeking_iterator.dart';
import 'token.dart';
import 'token_types.dart';
import 'char_codes.dart' as codes;

typedef TT = TokenType;
typedef CodePoint = int;

const keywords = {
  "and": TT.$and,
  "class": TT.$class,
  "else": TT.$else,
  "false": TT.$false,
  "fun": TT.$fun,
  "for": TT.$for,
  "if": TT.$if,
  "nil": TT.$nil,
  "or": TT.$or,
  "print": TT.$print,
  "return": TT.$return,
  "super": TT.$super,
  "this": TT.$this,
  "true": TT.$true,
  "var": TT.$var,
  "while": TT.$while,
};

class Lexer {
  final PeekingIterator<int> _source;
  int offset = 0;
  int line = 1;
  int lineOffset = 0;

  final List<Token> _tokens = [];

  Lexer(PeekingIterable<int> source)
      : _source = source.iterator,
        super();

  int? get _nextRune => _source.peek();
  int get _currentRune => _source.current;
  bool get _isAtEnd => _nextRune == null;

  bool _moveNext() {
    offset++;
    lineOffset++;
    final moveResult = _source.moveNext();
    if (_source.current == codes.newLine) {
      line++;
      lineOffset = 0;
    }
    return moveResult;
  }

  List<Token> getTokens() {
    while (_moveNext()) {
      _scanToken();
    }
    // add eof token at the end
    _tokens.add(Token(type: TT.eof, lexeme: '', line: line));
    return _tokens;
  }

  bool _match(int expected) {
    if (_isAtEnd) return false;
    if (_nextRune != expected) return false;

    _moveNext();
    return true;
  }

  void _string() {
    final List<int> value = [];
    while (_nextRune != codes.doubleQuote && _moveNext()) {
      value.add(_currentRune);
    }
    if (_isAtEnd) {
      print("error: unterminated string");
      return;
    }
    _moveNext(); // skip closing double quote
    addToken(TT.string, literal: String.fromCharCodes(value));
  }

  void _number() {
    final List<int> value = [_currentRune];
    while (codes.isDigit(_nextRune) && _moveNext()) value.add(_currentRune);
    if (_nextRune == codes.dot && _moveNext()) {
      value.add(_currentRune);
      while (codes.isDigit(_nextRune) && _moveNext()) value.add(_currentRune);
    }

    final number = double.tryParse(String.fromCharCodes(value));
    if (number == null) {
      print("error: something went wrong while parsing number literal");
      return;
    }
    addToken(TT.number, literal: number);
  }

  void _identifier() {
    final List<int> value = [_currentRune];

    while (codes.isAlphaNumeric(_nextRune) && _moveNext())
      value.add(_currentRune);

    final identifier = String.fromCharCodes(value);
    final tokenType = keywords[identifier];

    if (tokenType == null) {
      addToken(TT.identifier, lexeme: identifier);
      return;
    }

    addToken(tokenType);
  }

  String _readWhile(bool Function(int) predicate,
      [bool includeCurrent = true]) {
    final List<int> result = [];
    if (includeCurrent) result.add(_currentRune);

    while (_moveNext()) {
      if (predicate(_currentRune)) result.add(_currentRune);
    }

    return String.fromCharCodes(result);
  }

  void addToken(TokenType type, {String lexeme = "", Object? literal}) {
    final token = Token(
      type: type,
      lexeme: lexeme,
      line: line,
      literal: literal,
    );
    _tokens.add(token);
  }

  void _scanToken() {
    switch (_currentRune) {
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
        if (_nextRune == codes.slash) {
          print("readWhile: ${_readWhile((rune) => rune != codes.newLine)}");
        } else {
          addToken(TT.slash);
        }
        break;
      case codes.whitespace:
      case codes.tab:
      case codes.carriageReturn:
        break; // Ignore whitespace.

      // case codes.newLine:
      //   line++;
      //   lineOffset = 0;
      //   break;

      // String literals
      case codes.doubleQuote:
        _string();
        break;
      default:
        // Number literals
        if (codes.isDigit(_currentRune)) {
          _number();
        } else if (codes.isAlphaNumeric(_currentRune)) {
          _identifier();
        } else {
          print("ERROR: Unexpected character");
        }
    }
  }
}
