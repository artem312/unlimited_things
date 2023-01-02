Object? toJsonRemoveNull(dynamic value) {
  final result = value?.toJson();
  if (result is Map) {
    return result..removeWhere((key, value) => value == null);
  }
  return result;
}
