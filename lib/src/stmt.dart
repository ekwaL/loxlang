import 'package:lox/src/expr.dart';
import 'package:lox/src/token.dart';

abstract class Stmt {
  const Stmt();

  R accept<R>(StmtVisitor<R> visitor);
}

abstract class StmtVisitor<R> {
  R visitBlockStmt(Block stmt);
  R visitClassStmt(Class stmt);
  R visitExpressionStmtStmt(ExpressionStmt stmt);
  R visitFunctionStmtStmt(FunctionStmt stmt);
  R visitIfStmtStmt(IfStmt stmt);
  R visitPrintStmt(Print stmt);
  R visitReturnStmt(Return stmt);
  R visitVarStmt(Var stmt);
  R visitWhileStmt(While stmt);
}

class Block extends Stmt {
  final List<Stmt> statements;

  const Block({
    required this.statements,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitBlockStmt(this);
  }
}

class Class extends Stmt {
  final Token name;
  final List<FunctionStmt> methods;

  const Class({
    required this.name,
    required this.methods,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitClassStmt(this);
  }
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

class FunctionStmt extends Stmt {
  final Token name;
  final List<Token> params;
  final List<Stmt> body;

  const FunctionStmt({
    required this.name,
    required this.params,
    required this.body,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitFunctionStmtStmt(this);
  }
}

class IfStmt extends Stmt {
  final Expr condition;
  final Stmt thenBranch;
  final Stmt? elseBranch;

  const IfStmt({
    required this.condition,
    required this.thenBranch,
    required this.elseBranch,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitIfStmtStmt(this);
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

class Return extends Stmt {
  final Token keyword;
  final Expr? value;

  const Return({
    required this.keyword,
    required this.value,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitReturnStmt(this);
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

class While extends Stmt {
  final Expr condition;
  final Stmt body;

  const While({
    required this.condition,
    required this.body,
  });

  @override
  R accept<R>(StmtVisitor<R> visitor) {
    return visitor.visitWhileStmt(this);
  }
}
