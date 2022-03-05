import 'dart:collection';

import 'package:lox/src/error.dart';
import 'package:lox/src/expr.dart';
import 'package:lox/src/interpreter.dart';
import 'package:lox/src/stmt.dart';
import 'package:lox/src/token.dart';

enum FunctionType { none, function, method }

class Resolver implements ExprVisitor<void>, StmtVisitor<void> {
  final Interpreter _interpreter;
  final Queue<Map<String, bool>> _scopes = ListQueue();
  FunctionType currentFunction = FunctionType.none;

  Resolver(this._interpreter);

  _beginScope() {
    _scopes.addLast({});
  }

  _endScope() {
    _scopes.removeLast();
  }

  _declare(Token name) {
    if (_scopes.isEmpty) return;
    if (_scopes.last.containsKey(name.lexeme)) {
      parseError(name, "Already a variable with this name in this scope.");
    }
    _scopes.last[name.lexeme] = false;
  }

  _define(Token name) {
    if (_scopes.isEmpty) return;
    _scopes.last[name.lexeme] = true;
  }

  _resolveLocal(Expr expr, Token name) {
    for (int i = _scopes.length - 1; i >= 0; i--) {
      if (_scopes.elementAt(i).containsKey(name.lexeme)) {
        _interpreter.resolve(expr, _scopes.length - 1 - i);
      }
    }
  }

  resolve(List<Stmt> statements) {
    for (final stmt in statements) {
      _resolveStmt(stmt);
    }
  }

  _resolveStmt(Stmt statement) {
    statement.accept(this);
  }

  _resolveExpr(Expr expression) {
    expression.accept(this);
  }

  _resolveFunction(FunctionStmt stmt, FunctionType type) {
    FunctionType enclosingFunction = currentFunction;
    currentFunction = type;
    _beginScope();

    for (final param in stmt.params) {
      _declare(param);
      _define(param);
    }
    resolve(stmt.body);

    _endScope();
    currentFunction = enclosingFunction;
  }

  @override
  void visitAssignExpr(Assign expr) {
    _resolveExpr(expr.value);
    _resolveLocal(expr, expr.name);
  }

  @override
  void visitBinaryExpr(Binary expr) {
    _resolveExpr(expr.left);
    _resolveExpr(expr.right);
  }

  @override
  void visitBlockStmt(Block stmt) {
    _beginScope();
    resolve(stmt.statements);
    _endScope();
  }

  @override
  void visitCallExpr(Call expr) {
    _resolveExpr(expr.callee);
    for (final arg in expr.arguments) {
      _resolveExpr(arg);
    }
  }

  @override
  void visitGetExpr(Get expr) {
    _resolveExpr(expr.object);
  }

  @override
  void visitSetExpr(Set expr) {
    _resolveExpr(expr.object);
    _resolveExpr(expr.value);
  }

  @override
  void visitExpressionStmtStmt(ExpressionStmt stmt) {
    _resolveExpr(stmt.expression);
  }

  @override
  void visitFunctionStmtStmt(FunctionStmt stmt) {
    _declare(stmt.name);
    _define(stmt.name);

    _resolveFunction(stmt, FunctionType.function);
  }

  @override
  void visitGroupingExpr(Grouping expr) {
    _resolveExpr(expr.expression);
  }

  @override
  void visitIfStmtStmt(IfStmt stmt) {
    _resolveExpr(stmt.condition);
    _resolveStmt(stmt.thenBranch);
    final elseBranch = stmt.elseBranch;
    if (elseBranch != null) _resolveStmt(elseBranch);
  }

  @override
  void visitLiteralExpr(Literal expr) {}

  @override
  void visitLogicalExpr(Logical expr) {
    _resolveExpr(expr.left);
    _resolveExpr(expr.right);
  }

  @override
  void visitPrintStmt(Print stmt) {
    _resolveExpr(stmt.expression);
  }

  @override
  void visitReturnStmt(Return stmt) {
    if (currentFunction == FunctionType.none) {
      parseError(stmt.keyword, "Can't return from top-level code");
    }
    final value = stmt.value;
    if (value != null) _resolveExpr(value);
  }

  @override
  void visitUnaryExpr(Unary expr) {
    _resolveExpr(expr.right);
  }

  @override
  void visitVarStmt(Var stmt) {
    _declare(stmt.name);
    final init = stmt.initializer;
    if (init != null) {
      _resolveExpr(init);
    }
    _define(stmt.name);
  }

  @override
  void visitVariableExpr(Variable expr) {
    if (_scopes.isNotEmpty && _scopes.last[expr.name.lexeme] == false) {
      parseError(
          expr.name, "Can't read local variable in its own initializer.");
    }

    _resolveLocal(expr, expr.name);
  }

  @override
  void visitWhileStmt(While stmt) {
    _resolveExpr(stmt.condition);
    _resolveStmt(stmt.body);
  }

  @override
  void visitClassStmt(Class stmt) {
    _declare(stmt.name);
    for (final method in stmt.methods) {
      _resolveFunction(method, FunctionType.method);
    }
    _define(stmt.name);
  }
}
