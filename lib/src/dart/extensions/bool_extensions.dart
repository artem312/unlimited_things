import 'dart:async';

import 'package:unlimited_things/src/dart/types/function_typedefs.dart';

extension ConditionalResultExtension on bool {
  ConditionalResult<T, T, T> conditionalResult<T>(T trueValue, T falseValue) =>
      ConditionalResult(condition: this, trueResult: trueValue, falseResult: falseValue);
}

class ConditionalResult<Type, True, False> {
  final bool condition;
  final True trueResult;
  final False falseResult;

  ConditionalResult({
    required this.condition,
    required this.trueResult,
    required this.falseResult,
  });

  Type get result => (condition ? trueResult : falseResult) as Type;

  True get left => trueResult;

  False get right => falseResult;
}

extension RepeatedCkeckActionExtension on BoolCallback {
  FutureOr<bool> check(Iterable<AsyncVoidCallback> onTrueFunctions) =>
      RepeatedCheck(check: this, onTrueFunctions: onTrueFunctions).check;
}

class RepeatedCheck {
  final BoolCallback _check;
  final Iterable<AsyncVoidCallback> onTrueFunctions;

  const RepeatedCheck({
    required BoolCallback check,
    required this.onTrueFunctions,
  }) : _check = check;

  FutureOr<bool> get check async {
    for (final function in onTrueFunctions) {
      if (!_check()) {
        return false;
      }
      await function();
    }
    return _check();
  }
}
