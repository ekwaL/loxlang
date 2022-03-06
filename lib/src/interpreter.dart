import 'package:lox/src/callable.dart';
import 'package:lox/src/class.dart';
import 'package:lox/src/environment.dart';
import 'package:lox/src/error.dart';
import 'package:lox/src/expr.dart';
import 'package:lox/src/stmt.dart';
import 'package:lox/src/token.dart';
import 'package:lox/src/token_types.dart';

class RuntimeError extends Error {
  final Token token;
  final String message;

  RuntimeError(this.token, this.message);
}

class RuntimeReturn {
  final Object? value;
  const RuntimeReturn(this.value);
}

class Interpreter implements ExprVisitor<Object?>, StmtVisitor<void> {
  Environment globals = Environment();
  // late Environment _environment = Environment(globals);
  late Environment _environment = globals;
  final Map<Expr, int> _locals = {};

  Interpreter() {
    globals.define(
      "clock",
      LoxCallable.fromFunction(0, (_) => DateTime.now().microsecondsSinceEpoch.toDouble()),
    );
  }

  void interpret(List<Stmt> statements) {
    try {
      for (final statement in statements) {
        _execute(statement);
      }
    } on RuntimeError catch (error) {
      runtimeError(error);
    }
  }

  void resolve(Expr expr, int depth) {
    _locals[expr] = depth;
  }

  Object? _lookupVariable(Token name, Expr expr) {
    int? depth = _locals[expr];
    if (depth == null) {
      return globals.get(name);
    } else {
      return _environment.getAt(depth, name.lexeme);
      // return _environment.getAt(depth, name);
    }
  }

  @override
  Object? visitAssignExpr(Assign expr) {
    Object? value = _evaluate(expr.value);

    int? depth = _locals[expr];
    if (depth == null) {
      globals.assign(expr.name, value);
    } else {
      _environment.assignAt(depth, expr.name, value);
    }
    // _environment.assign(expr.name, value);
    return value;
  }

  @override
  Object? visitLogicalExpr(Logical expr) {
    final left = _evaluate(expr.left);

    if (expr.operator.type == TT.$or) {
      if (_isTruthy(left)) return left;
    } else {
      if (!_isTruthy(left)) return left;
    }

    return _evaluate(expr.right);
  }

  @override
  Object? visitBinaryExpr(Binary expr) {
    final right = _evaluate(expr.right);
    final left = _evaluate(expr.left);

    switch (expr.operator.type) {
      case TT.minus:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) - (right as double);
      case TT.plus:
        if (left is double && right is double) {
          return left + right;
        } else if (left is String && right is String) {
          return left + right;
        } else {
          if (left is double && right is String) {
            return _stringify(left) + right;
          } else if (left is String && right is double) {
            return left + _stringify(right);
          }
          throw RuntimeError(
              expr.operator, "Operands must be two numbers or two strings");
        }
      case TT.slash:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) / (right as double);
      case TT.star:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) * (right as double);
      // comparison
      case TT.greater:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) > (right as double);
      case TT.greaterEqual:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) >= (right as double);
      case TT.less:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) < (right as double);
      case TT.lessEqual:
        _checkNumberOperands(expr.operator, left, right);
        return (left as double) <= (right as double);
      case TT.bangEqual:
        return !_isEqual(left, right);
      case TT.equalEqual:
        return _isEqual(left, right);
      // unreachable
      default:
        return null;
    }
  }

  @override
  Object? visitGroupingExpr(Grouping expr) {
    return _evaluate(expr.expression);
  }

  @override
  Object? visitLiteralExpr(Literal expr) {
    return expr.value;
  }

  @override
  Object? visitUnaryExpr(Unary expr) {
    final right = _evaluate(expr.right);

    switch (expr.operator.type) {
      case TT.minus:
        _checkNumberOperand(expr.operator, right);
        return -(right as double);
      case TT.bang:
        return !_isTruthy(right);

      // unreachable
      default:
        return null;
    }
  }

  @override
  Object? visitVariableExpr(Variable expr) {
    return _lookupVariable(expr.name, expr);
  }

  @override
  Object? visitCallExpr(Call expr) {
    final callee = _evaluate(expr.callee);

    final List<Object?> arguments = [];
    for (final expr in expr.arguments) {
      arguments.add(_evaluate(expr));
    }

    if (callee is! LoxCallable) {
      throw RuntimeError(expr.paren, "Can only call functions and classes");
    }

    if (arguments.length != callee.arity) {
      throw RuntimeError(expr.paren,
          "Expected ${callee.arity} arguments but got ${arguments.length}.");
    }

    return callee.call(this, arguments);
  }

  @override
  Object? visitGetExpr(Get expr) {
    final object = _evaluate(expr.object);
    if (object is LoxInstance) {
      return object.get(expr.name);
    }

    throw RuntimeError(expr.name, "Only instances have properties.");
  }

  @override
  Object? visitSetExpr(Set expr) {
    final object = _evaluate(expr.object);

    if (object is! LoxInstance) {
      throw RuntimeError(expr.name, "Only instances have fields.");
    }

    final value = _evaluate(expr.value);
    object.set(expr.name, value);

    return value;
  }

  @override
  Object? visitThisExpr(This expr) {
    return _lookupVariable(expr.keyword, expr);
  }

  @override
  Object? visitSuperExpr(Super expr) {
    final depth = _locals[expr];
    assert(depth != null, "Can not resolve 'super' at ${expr.keyword.line}.");
    final superclass = _environment.getAt(depth!, "super") as LoxClass;
    final object = _environment.getAt(depth - 1, "this") as LoxInstance;

    final method = superclass.findMethod(expr.method.lexeme);
    if (method == null) {
      throw RuntimeError(
          expr.method, "Undefined property '${expr.method.lexeme}'.");
    }

    return method.bind(object);
  }

  Object? _evaluate(Expr expr) {
    return expr.accept(this);
  }

  void _execute(Stmt stmt) {
    return stmt.accept(this);
  }

  bool _isTruthy(Object? object) {
    if (object == null) return false;
    if (object is bool) return object;
    return true;
  }

  bool _isEqual(Object? a, Object? b) {
    if (a == null && b == null) return true;
    if (a == null) return false;

    return a == b;
  }

  String _stringify(Object? object) {
    if (object == null) {
      return "nil";
    } else if (object is double) {
      final txt = object.toString();
      return txt.endsWith(".0") ? txt.substring(0, txt.length - 2) : txt;
    } else {
      return object.toString();
    }
  }

  _checkNumberOperand(Token operator, Object? operand) {
    if (operand is double) return;
    throw RuntimeError(operator, "Operand must be a number.");
  }

  _checkNumberOperands(Token operator, Object? left, Object? right) {
    if (left is double && right is double) return;
    throw RuntimeError(operator, "Operands must be a number.");
  }

  @override
  void visitExpressionStmtStmt(ExpressionStmt stmt) {
    _evaluate(stmt.expression);
  }

  @override
  void visitFunctionStmtStmt(FunctionStmt stmt) {
    final fun = LoxFunction(stmt, _environment, false);
    _environment.define(stmt.name.lexeme, fun);
  }

  @override
  void visitIfStmtStmt(IfStmt stmt) {
    final check = _evaluate(stmt.condition);
    if (_isTruthy(check)) {
      _execute(stmt.thenBranch);
    } else {
      // TODO: как бы выразить это поэлегантнее?
      final elseBranch = stmt.elseBranch;
      if (elseBranch != null) _execute(elseBranch);
    }
  }

  @override
  void visitPrintStmt(Print stmt) {
    final value = _evaluate(stmt.expression);
    print(_stringify(value));
  }

  @override
  void visitReturnStmt(Return stmt) {
    final value = stmt.value;
    final result = value == null ? null : _evaluate(value);

    throw RuntimeReturn(result);
  }

  @override
  void visitWhileStmt(While stmt) {
    while (_isTruthy(_evaluate(stmt.condition))) {
      _execute(stmt.body);
    }
  }

  @override
  void visitVarStmt(Var stmt) {
    Object? value;
    final init = stmt.initializer;

    if (init != null) {
      value = _evaluate(init);
    }

    _environment.define(stmt.name.lexeme, value);
  }

  @override
  void visitBlockStmt(Block stmt) {
    executeBlock(stmt.statements, Environment(_environment));
  }

  void executeBlock(List<Stmt> statements, Environment env) {
    final outerEnv = _environment;

    try {
      _environment = env;

      for (final stmt in statements) {
        _execute(stmt);
      }
    } finally {
      _environment = outerEnv;
    }
  }

  @override
  void visitClassStmt(Class stmt) {
    final superclass = stmt.superclass;
    Object? superclassValue;
    if (superclass != null) {
      superclassValue = _evaluate(superclass);

      if (superclassValue is! LoxClass) {
        throw RuntimeError(superclass.name, "Superclass must be a class.");
      }
    }

    _environment.define(stmt.name.lexeme, null);

    if (superclass != null) {
      _environment = Environment(_environment);
      _environment.define("super", superclassValue);
    }

    final Map<String, LoxFunction> methods = {};
    for (final method in stmt.methods) {
      final function =
          LoxFunction(method, _environment, method.name.lexeme == "init");
      methods[method.name.lexeme] = function;
    }

    final klass =
        LoxClass(stmt.name.lexeme, superclassValue as LoxClass?, methods);

    if (superclass != null) {
      _environment = _environment.enclosing ?? globals;
    }

    _environment.assign(stmt.name, klass);
  }
}
