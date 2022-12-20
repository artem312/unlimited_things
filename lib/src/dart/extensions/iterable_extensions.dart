import 'dart:async';

extension IterableFirstWhere on Iterable {
  T? firstWhereOrNull<T>(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }

  Future<T> firstWhereAsync<T>(
    Future<bool> Function(T element) test, {
    FutureOr<T> Function()? orElse,
  }) async {
    for (final element in this) {
      if (await test(element)) {
        return element;
      }
    }
    if (orElse != null) {
      return await orElse();
    }
    throw StateError('No element');
  }
}
