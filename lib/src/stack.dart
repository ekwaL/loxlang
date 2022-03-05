class Stack<T> {
  final List<T> _stack = [];

  bool get isEmpty => _stack.isEmpty;

  void push(T value) {
    _stack.add(value);
  }

  T pop() {
    return _stack.removeLast();
  }
}
