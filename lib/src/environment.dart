import 'package:lox/src/token.dart';
import 'interpreter.dart';

class Environment {
  final Environment? _enclosing;
  final Map<String, Object?> _values = {};

  Environment([this._enclosing]);

  void define(String name, Object? value) {
    _values[name] = value;
    // _values.putIfAbsent(key, () => null).add(name, value);
  }

  void assign(Token name, Object? value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }

    if (_enclosing != null) {
      _enclosing?.assign(name, value);
      return;
    }

    throw RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    final outer = _enclosing?.get(name);
    if (outer != null) return outer;

    throw RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }
}
