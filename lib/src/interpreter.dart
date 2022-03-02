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

class Interpreter implements ExprVisitor<Object?>, StmtVisitor<void> {
  void interpret(List<Stmt> statements) {
    try {
      for (final statement in statements) {
        _execute(statement);
      }
    } on RuntimeError catch (error) {
      runtimeError(error);
    }
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
    // TODO: implement visitVariableExpr
    throw UnimplementedError();
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
  void visitPrintStmt(Print stmt) {
    final value = _evaluate(stmt.expression);
    print(_stringify(value));
  }

  @override
  void visitVarStmt(Var stmt) {
    // TODO: implement visitVarStmt
  }
}
