import 'dart:convert';

import 'static/remove_null_from_encodable.dart';


class JsonEncoderWithoutNull extends JsonEncoder {
  const JsonEncoderWithoutNull() : super(toJsonRemoveNull);

  const JsonEncoderWithoutNull.withIndent(String indent)
      : super.withIndent(indent, toJsonRemoveNull);
}
