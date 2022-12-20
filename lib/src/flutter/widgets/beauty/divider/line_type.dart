import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/types/divider_direction.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/types/relative_param.dart';

mixin LineType {
  /// The thickness of the divider.
  double? get thickness;

  void drawLine(
    Canvas canvas,
    DividerDirection direction,
    Offset center,
    double width,
    Paint paint,
  );
}

@immutable
abstract class _LineTypePainter with LineType {
  @override
  final double? thickness;

  const _LineTypePainter({this.thickness});

  @override
  void drawLine(
    Canvas canvas,
    DividerDirection direction,
    Offset start,
    double width,
    Paint paint,
  ) {
    final stashThickness = paint.strokeWidth;
    paint.strokeWidth = thickness ?? stashThickness;
    if (direction == DividerDirection.vertical) {
      _drawVerticalLine(canvas, start.dy, width, paint);
    } else {
      _drawHorizontalLine(canvas, start.dx, width, paint);
    }
    paint.strokeWidth = stashThickness;
  }

  void _drawVerticalLine(
    Canvas canvas,
    double start,
    double length,
    Paint paint,
  );

  void _drawHorizontalLine(
    Canvas canvas,
    double start,
    double length,
    Paint paint,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineType &&
          runtimeType == other.runtimeType &&
          thickness == other.thickness;

  @override
  int get hashCode => thickness.hashCode;
}

class LineTypeStraight extends _LineTypePainter {
  const LineTypeStraight({super.thickness});

  @override
  void _drawVerticalLine(
    Canvas canvas,
    double start,
    double length,
    Paint paint,
  ) {
    canvas.drawLine(Offset(0, start), Offset(0, start + length), paint);
  }

  @override
  void _drawHorizontalLine(
    Canvas canvas,
    double start,
    double length,
    Paint paint,
  ) {
    canvas.drawLine(Offset(start, 0), Offset(start + length, 0), paint);
  }
}

//todo implements startFrom
class LineTypeWave extends _LineTypePainter {
  final RelativeOrAbsolute<double> curveWidth;
  final RelativeOrAbsolute<double> curveHeight;
  final RelativeDouble startFrom;

  const LineTypeWave({
    super.thickness,
    this.curveWidth = AbsoluteDouble.zero,
    this.curveHeight = AbsoluteDouble.zero,
    this.startFrom = RelativeDouble.zero,
  });

  @override
  void drawLine(
    Canvas canvas,
    DividerDirection direction,
    Offset start,
    double width,
    Paint paint,
  ) {
    final stashStyle = paint.style;
    paint.style = PaintingStyle.stroke;
    super.drawLine(canvas, direction, start, width, paint);
    paint.style = stashStyle;
  }

  @override
  void _drawHorizontalLine(
    Canvas canvas,
    double start,
    double length,
    Paint paint,
  ) {
    if (this.curveWidth.apply(1) == 0 || this.curveHeight.apply(1) == 0) {
      canvas.drawLine(Offset(start, 0), Offset(start + length, 0), paint);
      return;
    }

    final curveWidth = this.curveWidth.apply(length);
    final curveHeight = this.curveHeight.apply(paint.strokeWidth);
    for (var currentLength = 0.0;
        currentLength < length;
        currentLength += curveWidth) {
      //todo smart cut
      if (currentLength + curveWidth > length * 1.05) {
        break;
      }
      canvas
        ..drawArc(
          Rect.fromCenter(
            center: Offset(start + currentLength + curveWidth * 0.25, 0),
            width: curveWidth * 0.5,
            height: curveHeight,
          ),
          0,
          pi,
          false,
          paint,
        )
        ..drawArc(
          Rect.fromCenter(
            center: Offset(start + currentLength + curveWidth * 0.75, 0),
            width: curveWidth * 0.5,
            height: curveHeight,
          ),
          pi,
          pi,
          false,
          paint,
        );
    }
  }

  @override
  void _drawVerticalLine(
    Canvas canvas,
    double start,
    double length,
    Paint paint,
  ) {
    if (this.curveWidth.apply(1) == 0 || this.curveHeight.apply(1) == 0) {
      canvas.drawLine(Offset(0, start), Offset(0, start + length), paint);
      return;
    }

    final curveWidth = this.curveWidth.apply(length);
    final curveHeight = this.curveHeight.apply(paint.strokeWidth);
    for (var currentLength = 0.0;
        currentLength < length;
        currentLength += curveWidth) {
      //todo smart cut
      if (currentLength + curveWidth > length * 1.05) {
        break;
      }
      canvas
        ..drawArc(
          Rect.fromCenter(
            center: Offset(0, start + currentLength + curveWidth * 0.25),
            width: curveHeight,
            height: curveWidth * 0.5,
          ),
          pi / 2,
          pi,
          false,
          paint,
        )
        ..drawArc(
          Rect.fromCenter(
            center: Offset(0, start + currentLength + curveWidth * 0.75),
            width: curveHeight,
            height: curveWidth * 0.5,
          ),
          -pi / 2,
          pi,
          false,
          paint,
        );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is LineTypeWave &&
          runtimeType == other.runtimeType &&
          curveWidth == other.curveWidth &&
          curveHeight == other.curveHeight &&
          startFrom == other.startFrom;

  @override
  int get hashCode =>
      super.hashCode ^
      curveWidth.hashCode ^
      curveHeight.hashCode ^
      startFrom.hashCode;
}
