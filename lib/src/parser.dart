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
    return _assignment();
  }

  Expr _assignment() {
    Expr expr = _or();

    if (_match([TT.equal])) {
      Token equals = _consume();
      Expr value = _assignment();

      if (expr is Variable) {
        Token name = expr.name;
        return Assign(name: name, value: value);
      }

      _error(equals, "Invalid assignment target");
    }

    return expr;
  }

  Expr _or() {
    Expr expr = _and();

    while (_match([TT.$or])) {
      final operator = _consume();
      final right = _and();
      expr = Logical(left: expr, operator: operator, right: right);
    }

    return expr;
  }

  Expr _and() {
    Expr expr = _equality();

    while (_match([TT.$and])) {
      final operator = _consume();
      final right = _equality();
      expr = Logical(left: expr, operator: operator, right: right);
    }

    return expr;
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

    return _call();
  }

  Expr _call() {
    Expr expr = _primary();

    while (true) {
      if (_match([TT.leftParen])) {
        _consume();
        expr = _finishCall(expr);
      } else {
        break;
      }
    }

    return expr;
  }

  Expr _finishCall(Expr callee) {
    final List<Expr> arguments = [];

    if (!_match([TT.rightParen])) {
      while (true) {
        if (arguments.length >= 255) {
          _error(_currentToken, "Can't have more that 255 arguments");
        }
        arguments.add(_expression());
        if (_match([TT.comma])) {
          _consume();
        } else {
          break;
        }
      }
    }

    Token paren = _ensure(TT.rightParen, "Expect ')' after arguments.");

    return Call(callee: callee, paren: paren, arguments: arguments);
  }

  Expr _primary() {
    if (_match([TT.$false])) {
      _consume();
      return Literal(value: false);
    }
    if (_match([TT.$true])) {
      _consume();
      return Literal(value: true);
    }
    if (_match([TT.$nil])) {
      _consume();
      return Literal(value: null);
    }

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
    if (_match([TT.leftBrace])) return Block(statements: _block());
    if (_match([TT.$if])) return _ifStatement();
    if (_match([TT.$print])) return _printStatement();
    if (_match([TT.$while])) return _whileStatement();
    if (_match([TT.$for])) return _forStatement();
    if (_match([TT.$return])) return _returnStatement();

    return _expressionStatement();
  }

  Stmt _ifStatement() {
    _consume();
    _ensure(TT.leftParen, "Expect '(' after 'if'.");
    final condition = _expression();
    _ensure(TT.rightParen, "Expect ')' after 'if' condition.");
    final thenBranch = _statement();
    Stmt? elseBranch;
    if (_match([TT.$else])) {
      _consume();
      elseBranch = _statement();
    }

    return IfStmt(
        condition: condition, thenBranch: thenBranch, elseBranch: elseBranch);
  }

  Stmt _printStatement() {
    _consume();

    final value = _expression();
    _ensure(TT.semicolon, "Expect ';'");
    return Print(expression: value);
  }

  Stmt _returnStatement() {
    final keyword = _consume();
    Expr? value;
    if (!_match([TT.semicolon])) {
      value = _expression();
    }
    _ensure(TT.semicolon, "Expect ';' after return statement.");

    return Return(keyword: keyword, value: value);
  }

  Stmt _whileStatement() {
    _consume();

    _ensure(TT.leftParen, "Expect '(' after 'while'.");
    final condition = _expression();
    _ensure(TT.rightParen, "Expect ')' after 'while' condition.");
    final body = _statement();

    return While(condition: condition, body: body);
  }

  Stmt _forStatement() {
    _consume();
    _ensure(TT.leftParen, "Expect '(' after 'while'.");

    Stmt? initializer;
    if (_match([TT.semicolon])) {
      _consume();
    } else if (_match([TT.$var])) {
      initializer = _varDeclaration();
    } else {
      initializer = _expressionStatement();
    }

    Expr? condition;
    if (!_match([TT.semicolon])) {
      condition = _expression();
    }
    _ensure(TT.semicolon, "Expect ';' after loop condition.");

    Expr? increment;
    if (!_match([TT.rightParen])) {
      increment = _expression();
    }
    _ensure(TT.rightParen, "Expect ')' after 'for' clauses.");

    Stmt body = _statement();

    if (increment != null) {
      body = Block(statements: [body, ExpressionStmt(expression: increment)]);
    }
    condition ??= Literal(value: true);
    body = While(condition: condition, body: body);

    if (initializer != null) {
      body = Block(statements: [initializer, body]);
    }

    return body;
  }

  Stmt _expressionStatement() {
    final expr = _expression();
    _ensure(TT.semicolon, "Expect ';'");
    return ExpressionStmt(expression: expr);
  }

  List<Stmt> _block() {
    _consume();
    final List<Stmt> statements = [];
    Stmt? dec;

    while (!_match([TT.rightBrace]) && !_isAtEnd) {
      dec = _declaration();
      if (dec != null) statements.add(dec);
    }

    _ensure(
        TT.rightBrace, "Expect '}' at the end of the block."); // after block.

    // return Block(statements: statements);
    return statements;
  }

  Stmt _function(String kind) {
    final name = _ensure(TT.identifier, "Expect $kind name.");
    _ensure(TT.leftParen, "Expect '(' after $kind name.");
    final List<Token> parameters = [];

    if (!_match([TT.rightParen])) {
      while (true) {
        if (parameters.length > 255) {
          _error(_currentToken, "Can't have more than 255 parameters.");
        }

        parameters.add(_ensure(TT.identifier, "Expect parameter name."));

        if (_match([TT.comma])) {
          _consume();
        } else {
          break;
        }
      }
    }
    _ensure(TT.rightParen, "Expect ')' after $kind parameters.");

    if (!_match([TT.leftBrace])) {
      throw _error(_currentToken, "Expect '{' before $kind body.");
    }
    List<Stmt> body = _block();

    return FunctionStmt(name: name, params: parameters, body: body);
  }

  // declaration
  Stmt? _declaration() {
    try {
      if (_match([TT.$var])) return _varDeclaration();
      if (_match([TT.$fun])) return _funDeclaration();

      return _statement();
    } on ParseError {
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

  Stmt _funDeclaration() {
    _consume();
    return _function("function");
  }
}
