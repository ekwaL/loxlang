import 'package:lox/src/expr.dart';
import 'package:lox/src/stmt.dart';

class AstPrinter implements ExprVisitor<String>, StmtVisitor<String> {
  String printStatements(List<Stmt> statements) {
    return statements.map((stmt) => stmt.accept(this)).join("\n");
  }

  String print(Expr expr) {
    return expr.accept(this);
  }

  @override
  String visitAssignExpr(Assign expr) {
    return _parenthesize("assign ${expr.name.lexeme}", [expr.value]);
  }

  @override
  String visitBinaryExpr(Binary expr) {
    return _parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGroupingExpr(Grouping expr) {
    return _parenthesize("group", [expr.expression]);
  }

  @override
  String visitLiteralExpr(Literal expr) {
    if (expr.value == null) return "nil";
    return expr.value.toString();
  }

  @override
  String visitUnaryExpr(Unary expr) {
    return _parenthesize(expr.operator.lexeme, [expr.right]);
  }

  @override
  String visitVariableExpr(Variable expr) {
    return expr.name.lexeme;
  }

  _parenthesize(String name, List<Expr> exprs) {
    String content = "(" + name;

    for (final expr in exprs) {
      content += " ";
      content += expr.accept(this);
    }

    content += ")";

    return content;
  }

  @override
  String visitExpressionStmtStmt(ExpressionStmt stmt) {
    return stmt.expression.accept(this);
    // return _parenthesize("print", [stmt.expression]);
  }

  @override
  String visitPrintStmt(Print stmt) {
    return _parenthesize("", [stmt.expression]);
  }

  @override
  String visitVarStmt(Var stmt) {
    final init = stmt.initializer;
    final List<Expr> exprs = init == null ? [] : [init];
    return _parenthesize("var ${stmt.name.lexeme}", exprs);
  }

  @override
  String visitBlockStmt(Block stmt) {
    String content = "{\n";

    for (final stmt in stmt.statements) {
      content += " ";
      content += stmt.accept(this);
    }

    content += "\n}";

    return content;
  }
}
