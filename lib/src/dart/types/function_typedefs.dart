import 'dart:async';

//callbacks
typedef VoidCallback = void Function();
typedef BoolCallback = bool Function();
typedef IntCallback = int Function();
typedef DoubleCallback = double Function();

//async callbacks
typedef AsyncVoidCallback = FutureOr<void> Function();
typedef AsyncBoolCallback = FutureOr<bool> Function();
typedef AsyncIntCallback = FutureOr<int> Function();
typedef AsyncDoubleCallback = FutureOr<double> Function();

//consumers
typedef VoidConsumer = VoidCallback;
typedef DoubleConsumer = void Function(double value);
typedef DoubleConsumer2 = void Function(double value1, double value2);
