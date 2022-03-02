import 'package:lox/src/token.dart';

abstract class Expr {
  const Expr();

  R accept<R>(Visitor<R> visitor);
}

abstract class Visitor<R> {
  R visitBinaryExpr(Binary expr);
  R visitGroupingExpr(Grouping expr);
  R visitLiteralExpr(Literal expr);
  R visitUnaryExpr(Unary expr);
}

class Binary extends Expr {
  final Expr left;
  final Token operator;
  final Expr right;

  const Binary({
    required this.left,
    required this.operator,
    required this.right,
  });

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitBinaryExpr(this);
  }
}

class Grouping extends Expr {
  final Expr expression;

  const Grouping({
    required this.expression,
  });

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitGroupingExpr(this);
  }
}

class Literal extends Expr {
  final Object? value;

  const Literal({
    required this.value,
  });

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitLiteralExpr(this);
  }
}

class Unary extends Expr {
  final Token operator;
  final Expr right;

  const Unary({
    required this.operator,
    required this.right,
  });

  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitUnaryExpr(this);
  }
}
