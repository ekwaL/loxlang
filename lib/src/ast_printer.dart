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
  String visitLogicalExpr(Logical expr) {
    return _parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
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

  @override
  String visitThisExpr(This expr) {
    return expr.keyword.lexeme;
  }

  @override
  String visitSuperExpr(Super expr) {
    return expr.keyword.lexeme + "." + expr.method.lexeme;
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
  }

  @override
  String visitIfStmtStmt(IfStmt stmt) {
    return _parenthesizeStatements(
      "if (${stmt.condition.accept(this)})",
      [stmt.thenBranch, stmt.elseBranch],
    );
  }

  @override
  String visitPrintStmt(Print stmt) {
    return _parenthesize("print", [stmt.expression]);
  }

  @override
  String visitVarStmt(Var stmt) {
    final init = stmt.initializer;
    final List<Expr> exprs = init == null ? [] : [init];
    return _parenthesize("var ${stmt.name.lexeme}", exprs);
  }

  @override
  String visitBlockStmt(Block stmt) {
    return _parenthesizeStatements("", stmt.statements);
  }

  @override
  String visitWhileStmt(While stmt) {
    String content = "(while ";
    content += stmt.condition.accept(this);
    content += " ";
    content += stmt.body.accept(this);
    content += " )";
    return content;
  }

  String _parenthesizeStatements(String name, List<Stmt?> stmts) {
    String content = "{" + name;

    for (final stmt in stmts) {
      content += " ";
      content += stmt?.accept(this) ?? "nil";
    }

    content += " }";

    return content;
  }

  @override
  String visitCallExpr(Call expr) {
    return _parenthesize(expr.callee.accept(this), expr.arguments);
  }

  @override
  String visitGetExpr(Get expr) {
    return "${expr.object.accept(this)}.${expr.name.lexeme}";
  }

  @override
  String visitSetExpr(Set expr) {
    return "(= ${expr.object.accept(this)}.${expr.name.lexeme} ${expr.value.accept(this)})";
  }

  @override
  String visitFunctionStmtStmt(FunctionStmt stmt) {
    final params =
        _parenthesize(stmt.params.map((p) => p.lexeme).join(", "), []);
    final body = _parenthesizeStatements("", stmt.body);
    return "(fun ${stmt.name.lexeme} $params $body)";
  }

  @override
  String visitReturnStmt(Return stmt) {
    return _parenthesize(
        stmt.keyword.lexeme, stmt.value == null ? [] : [stmt.value!]);
  }

  @override
  String visitClassStmt(Class stmt) {
    final superclass = stmt.superclass;
    final superclassText =
        superclass == null ? "" : " < " + superclass.name.lexeme;
    return _parenthesizeStatements(
        "class ${stmt.name.lexeme}$superclassText", stmt.methods);
  }
}
