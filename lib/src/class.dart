import 'package:lox/src/callable.dart';
import 'package:lox/src/interpreter.dart';
import 'package:lox/src/token.dart';

class LoxClass implements LoxCallable {
  final String name;

  const LoxClass(this.name);

  @override
  toString() {
    return name;
  }

  @override
  int get arity => 0;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    LoxInstance instance = LoxInstance(this);
    return instance;
  }
}

class LoxInstance {
  final LoxClass klass;
  final Map<String, Object?> fields = {};

  LoxInstance(this.klass);

  Object? get(Token name) {
    if (fields.containsKey(name.lexeme)) {
      return fields[name.lexeme];
    }

    throw RuntimeError(name, "Undefined property '${name.lexeme}' .");
  }

  @override
  String toString() {
    return klass.name + " instance";
  }
}
