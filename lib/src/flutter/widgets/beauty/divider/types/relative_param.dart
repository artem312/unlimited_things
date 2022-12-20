import 'package:flutter/cupertino.dart';

@immutable
abstract class RelativeOrAbsolute<T> {
  const RelativeOrAbsolute();

  T apply(T base);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelativeOrAbsolute && runtimeType == other.runtimeType) ||
      super == other;

  @override
  int get hashCode => runtimeType.hashCode;
}

class AbsoluteDouble extends RelativeOrAbsolute<double> {
  static const zero = AbsoluteDouble(0);
  final double value;

  const AbsoluteDouble(this.value);

  @override
  double apply(double base) => value;

  @override
  bool operator ==(Object other) =>
      (other is AbsoluteDouble && other.value == value) ||
      (other is double && other == value);

  @override
  int get hashCode => value.hashCode;
}

class RelativeDouble extends RelativeOrAbsolute<double> {
  static const zero = RelativeDouble(0);
  final double value;

  const RelativeDouble(this.value);

  @override
  double apply(double base) => base * value;

  @override
  bool operator ==(Object other) =>
      (other is RelativeDouble && other.value == value) ||
      (other is double && other == value);

  @override
  int get hashCode => value.hashCode;
}

extension DoubleExtension on double {
  AbsoluteDouble get absolute => AbsoluteDouble(this);

  RelativeDouble get relative => RelativeDouble(this);
}
