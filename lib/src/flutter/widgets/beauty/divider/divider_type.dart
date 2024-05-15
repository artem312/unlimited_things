import 'package:flutter/widgets.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/dot_style.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/line_parser.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/line_type.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/types/divider_direction.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/types/relative_param.dart';

@immutable
abstract class DividerType {
  final LineType lineType;

  const DividerType({this.lineType = const LineTypeStraight()});

  Paint _transformPaint(Paint parent) => parent;

  void _drawHorizontalDivider(Canvas canvas, double length, Paint paint);

  void _drawVerticalDivider(Canvas canvas, double length, Paint paint);

  void drawDivider(
    Canvas canvas,
    DividerDirection direction,
    Size size,
    Paint paint,
  ) {
    final drawPaint = _transformPaint(paint);
    if (direction == DividerDirection.vertical) {
      canvas.translate(size.width * 0.5, 0);
      _drawVerticalDivider(canvas, size.height, drawPaint);
      canvas.translate(-size.width * 0.5, 0);
    } else {
      canvas.translate(0, size.height * 0.5);
      _drawHorizontalDivider(canvas, size.width, drawPaint);
      canvas.translate(0, -size.height * 0.5);
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DividerType && runtimeType == other.runtimeType && lineType == other.lineType;

  @override
  int get hashCode => lineType.hashCode;
}

class DividerTypeSolid extends DividerType {
  const DividerTypeSolid({super.lineType});

  @override
  Paint _transformPaint(Paint parent) => parent..style = PaintingStyle.fill;

  @override
  void _drawVerticalDivider(Canvas canvas, double length, Paint paint) {
    lineType.drawLine(
      canvas,
      DividerDirection.vertical,
      Offset.zero,
      length,
      paint,
    );
  }

  @override
  void _drawHorizontalDivider(Canvas canvas, double length, Paint paint) {
    lineType.drawLine(
      canvas,
      DividerDirection.horizontal,
      Offset.zero,
      length,
      paint,
    );
  }
}

@immutable
class LineParams {
  final RelativeOrAbsolute<double> gap;
  final RelativeOrAbsolute<double> width;

  const LineParams({
    required this.gap,
    required this.width,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LineParams && other.gap == gap && other.width == width;
  }

  @override
  int get hashCode => gap.hashCode ^ width.hashCode;
}

class DividerTypeDashed extends DividerType {
  final LineParams lineParams;
  final RelativeOrAbsolute<double> startFrom;

  const DividerTypeDashed({
    super.lineType,
    required this.lineParams,
    this.startFrom = AbsoluteDouble.zero,
  });

  @override
  Paint _transformPaint(Paint parent) => parent..style = PaintingStyle.fill;

  LineParser _parseLength(double length) {
    final strokeWidth = lineParams.width.apply(length);
    final gapWidth = lineParams.gap.apply(length);
    return LineParser(
      strokeWidth: strokeWidth,
      gapWidth: gapWidth,
      startFrom: startFrom.apply(length),
      length: length,
    );
  }

  void _drawArray(
    Canvas canvas,
    Paint paint,
    LineParser parser,
    Offset Function(double value) getOffset,
  ) {
    parser.draw(forDash: (offset, length) {
      lineType.drawLine(
        canvas,
        getOffset(1).dx == 0 ? DividerDirection.vertical : DividerDirection.horizontal,
        getOffset(offset),
        length,
        paint,
      );
    });
  }

  @override
  void _drawHorizontalDivider(Canvas canvas, double length, Paint paint) {
    _drawArray(
      canvas,
      paint,
      _parseLength(length),
      (value) => Offset(value, 0),
    );
  }

  @override
  void _drawVerticalDivider(Canvas canvas, double length, Paint paint) {
    _drawArray(
      canvas,
      paint,
      _parseLength(length),
      (value) => Offset(0, value),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DividerTypeDashed &&
          runtimeType == other.runtimeType &&
          lineType == other.lineType &&
          lineParams == other.lineParams &&
          startFrom == other.startFrom;

  @override
  int get hashCode => lineType.hashCode ^ lineParams.hashCode ^ startFrom.hashCode;
}

class DividerTypeDotted extends DividerTypeDashed {
  final List<DividerDot> dots;

  const DividerTypeDotted({
    super.lineType,
    required this.dots,
    required super.lineParams,
    super.startFrom = AbsoluteDouble.zero,
  });

  DividerTypeDotted.singleDot({
    required super.lineParams,
    required DividerDot dot,
  }) : dots = [dot];

  @override
  void _drawArray(
    Canvas canvas,
    Paint paint,
    LineParser parser,
    Offset Function(double value) getOffset,
  ) {
    if (dots.isEmpty) {
      return;
    }
    parser.draw(forGap: (offset, length) {
      final dotLength = length / dots.length;
      var i = 0;
      for (final dot in dots) {
        final dotStrokeWidth = dot.size.apply(dotLength);
        final dotAlignment = (dot.alignment + 1) * 0.5;
        final dotOffset = dotLength * i + dotLength * dotAlignment;
        dot.draw(
          canvas,
          getOffset(offset + dotOffset),
          dotStrokeWidth,
          paint,
        );
        i++;
      }
    });
  }

  @override
  void _drawHorizontalDivider(Canvas canvas, double length, Paint paint) {
    final parsedLength = _parseLength(length);
    super._drawArray(
      canvas,
      paint,
      parsedLength,
      (value) => Offset(value, 0),
    );
    _drawArray(
      canvas,
      paint,
      parsedLength,
      (value) => Offset(value, 0),
    );
  }

  @override
  void _drawVerticalDivider(Canvas canvas, double length, Paint paint) {
    final parsedLength = _parseLength(length);
    super._drawArray(
      canvas,
      paint,
      parsedLength,
      (value) => Offset(0, value),
    );
    _drawArray(
      canvas,
      paint,
      parsedLength,
      (value) => Offset(0, value),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DividerTypeDotted &&
          runtimeType == other.runtimeType &&
          lineType == other.lineType &&
          lineParams == other.lineParams &&
          startFrom == other.startFrom &&
          dots == other.dots;

  @override
  int get hashCode => lineType.hashCode ^ lineParams.hashCode ^ startFrom.hashCode ^ dots.hashCode;
}
