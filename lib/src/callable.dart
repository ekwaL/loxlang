import 'package:lox/src/interpreter.dart';
import 'package:lox/src/stmt.dart';

typedef NativeFunction = Object? Function(List<Object?>);

abstract class LoxCallable {
  factory LoxCallable.fromFunction(int arity, NativeFunction function) {
    return _LoxNativeFunction(arity, function);
  }
  int get arity;
  Object? call(Interpreter interpreter, List<Object?> arguments);
}

class _LoxNativeFunction implements LoxCallable {
  final int _arity;
  final NativeFunction _fn;

  const _LoxNativeFunction(this._arity, this._fn);

  @override
  int get arity => _arity;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    return _fn(arguments);
  }

  @override
  String toString() {
    return "<native fun>";
  }
}

class LoxFunction implements LoxCallable {
  final FunctionStmt _declaration;

  LoxFunction(this._declaration);

  @override
  int get arity => _declaration.params.length;

  @override
  Object? call(Interpreter interpreter, List<Object?> arguments) {
    final environment = interpreter.globals;

    for (int i = 0; i < _declaration.params.length; i++) {
      environment.define(_declaration.params[i].lexeme, arguments[i]);
    }

    // Block(_declaration.body).apply(interpreter) with fixed env...
    try {
      interpreter.executeBlock(_declaration.body, environment);
    } on RuntimeReturn catch (rr) {
      return rr.value;
    }

    return null;
  }

  @override
  String toString() {
    return "<fun ${_declaration.name.lexeme}>";
  }
}
