import 'dart:convert';

class DartEncoder extends JsonEncoder {
  const DartEncoder([super.toEncodable]);

  const DartEncoder.withIndent(
    String super.indent, [
    super.toEncodable,
  ]) : super.withIndent();

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
