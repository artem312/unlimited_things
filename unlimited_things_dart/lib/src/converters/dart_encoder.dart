import 'dart:convert';

class DartEncoder extends JsonEncoder {
  const DartEncoder([Object? Function(dynamic object)? toEncodable])
      : super(toEncodable);

  const DartEncoder.withIndent(
    String indent, [
    Object? Function(dynamic object)? toEncodable,
  ]) : super.withIndent(indent, toEncodable);

  @override
  String convert(dynamic object) {
    var result = super.convert(object).replaceAll('"', "'");
    if (object is Map || object is List) {
      final indexOfComma = result.lastIndexOf("'");
      if (indexOfComma != -1) {
        result =
            '${result.substring(0, indexOfComma + 1)},${result.substring(indexOfComma + 1)}';
      }
    }
    return result;
  }
}
