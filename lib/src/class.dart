import 'package:lox/src/callable.dart';
import 'package:lox/src/interpreter.dart';
import 'package:lox/src/token.dart';

class LoxClass implements LoxCallable {
  final String name;
  final Map<String, LoxFunction> methods;

  const LoxClass(this.name, this.methods);

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

  LoxFunction? findMethod(String name) {
    return methods[name];
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

    final method = klass.findMethod(name.lexeme);
    if (method != null) return method;

    throw RuntimeError(name, "Undefined property '${name.lexeme}' .");
  }

  void set(Token name, Object? value) {
    fields[name.lexeme] = value;
  }

  @override
  String toString() {
    return klass.name + " instance";
  }
}
