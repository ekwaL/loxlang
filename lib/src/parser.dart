import 'package:lox/src/error.dart';
import 'package:lox/src/expr.dart';
import 'package:lox/src/stmt.dart';
import 'package:lox/src/token.dart';
import 'package:lox/src/token_types.dart';

class ParseError extends Error {
  // final String message;

  // ParseError(this.message);
}

class Parser {
  final Iterator<Token> _tokens;

  Parser(this._tokens);

  List<Stmt> parse() {
    final List<Stmt> statements = [];
    if (!_tokens.moveNext()) return statements;

    while (!_isAtEnd) {
      final stmt = _declaration();
      if (stmt == null) continue;
      statements.add(stmt);
    }

    return statements;
  }

  // helpers
  Token get _currentToken => _tokens.current;
  bool get _isAtEnd => _currentToken.type == TT.eof;

  bool _moveNext() {
    return _tokens.moveNext();
  }

  bool _match(Iterable<TokenType> types) {
    for (final type in types) {
      // if (_check(type)) {
      //   _moveNext();
      //   return true;
      // }
      if (_check(type)) return true;
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd) return false;
    return _currentToken.type == type;
  }

  Token _consume() {
    final token = _currentToken;
    _moveNext();
    return token;
  }

  Token _ensure(TokenType type, String errorMessage) {
    if (_check(type)) return _consume();

    throw _error(_currentToken, errorMessage);
  }

  ParseError _error(Token token, String message) {
    parseError(token, message);
    return ParseError();
  }

  // error handling
  void _synchronize() {
    // _moveNext();

    while (!_isAtEnd) {
      // if (_currentToken.type == TT.semicolon) {
      //   _moveNext();
      //   return;
      // }
      switch (_currentToken.type) {
        case TT.semicolon:
          _moveNext();
          return;
        case TT.$class:
        case TT.$fun:
        case TT.$var:
        case TT.$for:
        case TT.$if:
        case TT.$while:
        case TT.$print:
        case TT.$return:
          return;
        default:
          _moveNext();
      }
    }
  }

  // rules // expressions
  Expr _expression() {
    return _equality();
  }

  Expr _equality() {
    Expr expr = _comparison();

    while (_match([TT.bangEqual, TT.equalEqual])) {
      Token operator = _consume();
      Expr right = _comparison();
      expr = Binary(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _comparison() {
    Expr expr = _term();

    while (_match([TT.greater, TT.greaterEqual, TT.less, TT.lessEqual])) {
      Token operator = _consume();
      Expr right = _term();
      expr = Binary(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _term() {
    Expr expr = _factor();

    while (_match([TT.plus, TT.minus])) {
      Token operator = _consume();
      Expr right = _factor();
      expr = Binary(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _factor() {
    Expr expr = _unary();

    while (_match([TT.slash, TT.star])) {
      Token operator = _consume();
      Expr right = _unary();
      expr = Binary(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _unary() {
    if (_match([TT.bang, TT.minus])) {
      Token operator = _consume();
      Expr right = _unary();
      return Unary(operator: operator, right: right);
    }

    return _primary();
  }

  Expr _primary() {
    if (_match([TT.$false])) return Literal(value: false);
    if (_match([TT.$true])) return Literal(value: true);
    if (_match([TT.$nil])) return Literal(value: null);

    if (_match([TT.number, TT.string])) {
      return Literal(value: _consume().literal);
    }

    if (_match([TT.identifier])) {
      return Variable(name: _consume());
    }
    if (_match([TT.leftParen])) {
      _consume();
      Expr expr = _expression();

      _ensure(TT.rightParen, "Expect ')' after expression.");
      return Grouping(expression: expr);
    }

    throw _error(_currentToken, "Expect expression.");
  }

  // statements
  Stmt _statement() {
    if (_match([TT.$print])) return _printStatement();

    return _expressionStatement();
  }

  Stmt _printStatement() {
    _consume();

    final value = _expression();
    _ensure(TT.semicolon, "Expect ';'");
    return Print(expression: value);
  }

  Stmt _expressionStatement() {
    final expr = _expression();
    _ensure(TT.semicolon, "Expect ';'");
    return ExpressionStmt(expression: expr);
  }

  // declaration
  Stmt? _declaration() {
    try {
      if (_match([TT.$var])) return _varDeclaration();

      return _statement();
    } on ParseError catch (err) {
      _synchronize();
      return null;
    }
  }

  Stmt _varDeclaration() {
    _consume();
    Token name = _ensure(TT.identifier, "Expect variable name");

    // Expr initializer = Literal(value: Token(TT.$nil));
    Expr? initializer;

    if (_match([TT.equal])) {
      _consume();
      initializer = _expression();
    }

    _ensure(TT.semicolon, "Expect ';' after variable declaration");
    return Var(name: name, initializer: initializer);
  }
}
