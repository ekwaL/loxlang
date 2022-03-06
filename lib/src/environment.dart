import 'package:lox/src/token.dart';
import 'interpreter.dart';

class Environment {
  final Environment? enclosing;
  final Map<String, Object?> _values = {};

  Environment([this.enclosing]);

  void define(String name, Object? value) {
    _values[name] = value;
    // _values.putIfAbsent(key, () => null).add(name, value);
  }

  void assign(Token name, Object? value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }

    if (enclosing != null) {
      enclosing?.assign(name, value);
      return;
    }

    throw RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }

  Object? get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    final outer = enclosing?.get(name);
    if (outer != null) return outer;

    throw RuntimeError(name, "Undefined variable '${name.lexeme}'.");
  }

  Environment _ancestor(int depth) {
    Environment? semanticScope = this;
    while (depth > 0) {
      semanticScope = semanticScope?.enclosing;
      depth--;
    }

    assert(semanticScope != null, "ERROR : Semantic scope is NOT resolved right.");
    return semanticScope!;
  }

  Object? getAt(int depth, String name) {
    final semanticScope = _ancestor(depth);
    return semanticScope._values[name];
  }

  void assignAt(int depth, Token name, Object? value) {
    final semanticScope = _ancestor(depth);
    semanticScope._values[name.lexeme] = value;
  }
}
