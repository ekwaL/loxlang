import 'package:lox/src/callable.dart';
import 'package:lox/src/interpreter.dart';
import 'package:lox/src/token.dart';

class LoxClass implements LoxCallable {
  final String name;
  final LoxClass? superclass;
  final Map<String, LoxFunction> methods;

  const LoxClass(this.name, this.superclass, this.methods);

  @override
  toString() {
    return name;
  }

  @override
  int get arity {
    final initializer= findMethod("init");
    if (initializer == null) return 0;
    return initializer.arity;
  }

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    LoxInstance instance = LoxInstance(this);

    final initializer = findMethod("init");
    if (initializer != null) {
      initializer.bind(instance).call(interpreter, arguments);
    }
    return instance;
  }

  LoxFunction? findMethod(String name) {
    if (methods.containsKey(name)) {
      return methods[name];
    }

    return superclass?.findMethod(name);
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
    if (method != null) return method.bind(this);

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
