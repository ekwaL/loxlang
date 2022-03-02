import 'package:lox/src/expr.dart';
import 'package:lox/src/token.dart';

abstract class Stmt {
  const Stmt();

  R accept<R>(StmtVisitor<R> visitor);
}

abstract class StmtVisitor<R> {
  R visitExpressionStmtStmt(ExpressionStmt stmt);
  R visitPrintStmt(Print stmt);
  R visitVarStmt(Var stmt);
}

class ExpressionStmt extends Stmt {
  final Expr expression;

  const ExpressionStmt({
    required this.expression,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitExpressionStmtStmt(this);
  }
}

class Print extends Stmt {
  final Expr expression;

  const Print({
    required this.expression,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitPrintStmt(this);
  }
}

class Var extends Stmt {
  final Token name;
  final Expr? initializer;

  const Var({
    required this.name,
    required this.initializer,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitVarStmt(this);
  }
}