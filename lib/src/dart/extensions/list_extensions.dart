extension SeparatedList on Iterable {
  List<T> separated<T>(T Function(int index) separator) {
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(elementAt(i) as T);
      if (i != length - 1) {
        result.add(separator(i));
      }
    }
    return result;
  }
}
