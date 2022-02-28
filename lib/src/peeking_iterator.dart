class PeekingIterable<T> extends Iterable<T> {
  final Iterable<T> _iterable;

  const PeekingIterable(this._iterable);

  @override
  PeekingIterator<T> get iterator => _PeekingIterator(_iterable.iterator);
}

abstract class PeekingIterator<T> extends Iterator<T> {
  T? peek();
}

class _PeekingIterator<T> implements PeekingIterator<T> {
  final Iterator<T> _iterator;

  bool _hasPeeked = false;
  bool _hasNext = true;
  T? _current;

  _PeekingIterator(this._iterator);

  @override
  T get current => _current as T;

  @override
  bool moveNext() {
    if (!_hasPeeked) {
      _hasNext = _iterator.moveNext();
    }
    _current = _iterator.current;
    _hasPeeked = false;

    return _hasNext;
  }

  @override
  T? peek() {
    if (!_hasPeeked) {
      // _current = _iterator.current;
      _hasNext = _iterator.moveNext();
      _hasPeeked = true;
    }

    return _hasNext ? _iterator.current : null;
  }
}
