import 'package:lox/src/token.dart';

import 'interpreter.dart';

class Environment {
  final Map<String, Object?> _values = {};

  void define(String name, Object? value) {
    _values[name] = value;
    // _values.putIfAbsent(key, () => null).add(name, value);
  }

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    throw RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }
}
