import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:unlimited_things/src/dart/types/function_typedefs.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/types/divider_direction.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/types/relative_param.dart';

@immutable
abstract class DotTransformer {
  const DotTransformer();

  void transformDot(Canvas canvas, Offset center, VoidConsumer supplier);
}

class DotTransformerNone extends DotTransformer {
  const DotTransformerNone();

  @override
  void transformDot(Canvas canvas, Offset center, VoidConsumer supplier) {
    supplier();
  }
}

class LinkedDotTransformer extends DotTransformer {
  final DotTransformer first;
  final DotTransformer? second;

  const LinkedDotTransformer(this.first, this.second);

  factory LinkedDotTransformer.fromList(List<DotTransformer> transformers) {
    if (transformers.isEmpty) {
      return const LinkedDotTransformer(
        DotTransformerNone(),
        null,
      );
    }
    if (transformers.length == 1) {
      return LinkedDotTransformer(
        transformers.first,
        null,
      );
    }
    return LinkedDotTransformer(
      transformers.first,
      LinkedDotTransformer.fromList(transformers.sublist(1)),
    );
  }

  @override
  void transformDot(Canvas canvas, Offset center, VoidConsumer supplier) {
    first.transformDot(canvas, center, () {
      if (second != null) {
        second!.transformDot(canvas, center, supplier);
      } else {
        supplier();
      }
    });
  }
}

class DotRotationTransformer extends DotTransformer {
  /// The angle in radians to rotate the dots by.
  final double? angle;

  const DotRotationTransformer(this.angle);

  const DotRotationTransformer.fromDegrees(double degrees)
      : this(degrees * pi / 180);

  @override
  void transformDot(Canvas canvas, Offset center, VoidConsumer supplier) {
    assert(angle?.isFinite ?? true, 'Angle must be finite');
    if (angle == null || angle == 0) {
      supplier();
      return;
    }
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(angle!)
      ..translate(-center.dx, -center.dy);
    supplier();
    canvas.restore();
  }
}

class DotScaleTransformer extends DotTransformer {
  /// The scale to apply to the dots by x axis.
  final double? scaleX;

  /// The scale to apply to the dots by y axis.
  final double? scaleY;

  const DotScaleTransformer({
    this.scaleX,
    this.scaleY,
  });

  const DotScaleTransformer.fromScale(double scale)
      : this(scaleX: scale, scaleY: scale);

  @override
  void transformDot(Canvas canvas, Offset center, VoidConsumer supplier) {
    assert(scaleX?.isFinite ?? true, 'ScaleX must be finite');
    assert(scaleY?.isFinite ?? true, 'ScaleY must be finite');
    if ((scaleX == null || scaleX == 1) && (scaleY == null || scaleY == 1)) {
      supplier();
      return;
    }
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(scaleX ?? 1, scaleY ?? 1)
      ..translate(-center.dx, -center.dy);
    supplier();
    canvas.restore();
  }
}

class DotMirrorTransformer extends DotTransformer {
  /// Whether to mirror the dots by x axis.
  final bool mirrorX;

  /// Whether to mirror the dots by y axis.
  final bool mirrorY;

  const DotMirrorTransformer({
    this.mirrorX = false,
    this.mirrorY = false,
  });

  @override
  void transformDot(Canvas canvas, Offset center, VoidConsumer supplier) {
    if (!mirrorX && !mirrorY) {
      supplier();
      return;
    }
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..scale(mirrorX ? -1 : 1, mirrorY ? -1 : 1)
      ..translate(-center.dx, -center.dy);
    supplier();
    canvas.restore();
  }
}

@immutable
abstract class _DotStylePainter with DividerDot {
  @override
  final RelativeOrAbsolute<double> size;

  @override
  final double alignment;

  @override
  final double? thickness;

  @override
  final double scale;
  @override
  final DotTransformer? transformer;

  const _DotStylePainter._({
    required this.size,
    required this.thickness,
    this.alignment = 0,
    this.scale = 1,
    required this.transformer,
  }) : assert(scale >= 0);

  void _innerDraw(Canvas canvas, Offset center, double width, Paint paint);

  @override
  void draw(Canvas canvas, Offset center, double width, Paint paint) {
    final stashThickness = paint.strokeWidth;
    if (thickness != null) {
      paint.strokeWidth = thickness!;
    }
    if (transformer != null) {
      transformer!.transformDot(canvas, center, () {
        _innerDraw(canvas, center, width, paint);
      });
    } else {
      _innerDraw(canvas, center, width, paint);
    }
    paint.strokeWidth = stashThickness;
  }
}

mixin DividerDot {
  /// size of the dot. For circular dots it is the diameter.
  RelativeOrAbsolute<double> get size;

  /// You can adjust dot position if dot free space.
  double get alignment;

  /// if not null dot have own thickness
  double? get thickness;

  /// scale of the dot
  double get scale;

  /// render transformer of the dot
  DotTransformer? get transformer;

  void draw(Canvas canvas, Offset center, double width, Paint paint);
}

class CircleDot extends _DotStylePainter {
  const CircleDot({
    required super.size,
    super.thickness,
    super.alignment,
    super.scale,
    super.transformer,
  }) : super._();

  @override
  void _innerDraw(Canvas canvas, Offset center, double width, Paint paint) {
    canvas.drawCircle(center, width * 0.5 * scale, paint);
  }
}

class OvalDot extends _DotStylePainter {
  const OvalDot({
    required super.size,
    required super.thickness,
    super.alignment,
    super.scale,
    super.transformer,
  }) : super._();

  @override
  void _innerDraw(Canvas canvas, Offset center, double width, Paint paint) {
    final rect = Rect.fromCircle(center: center, radius: width * 0.5 * scale);
    paint.style = PaintingStyle.stroke;
    canvas.drawOval(rect, paint);
  }
}

class DashedOvalDot extends _DotStylePainter {
  final double dashAngle;
  final double gapAngle;

  const DashedOvalDot({
    required this.gapAngle,
    required this.dashAngle,
    required super.size,
    required super.thickness,
    super.alignment,
    super.scale,
    super.transformer,
  }) : super._();

  const DashedOvalDot.fromDegree({
    required double dashDegree,
    required double gapDegree,
    required super.size,
    super.thickness,
    super.alignment,
    super.scale,
    super.transformer,
  })  : dashAngle = dashDegree * pi / 180,
        gapAngle = gapDegree * pi / 180,
        super._();

  @override
  void _innerDraw(Canvas canvas, Offset center, double width, Paint paint) {
    final rect = Rect.fromCircle(center: center, radius: width * 0.5 * scale);
    paint.style = PaintingStyle.stroke;
    var currentAngle = 0.0;
    while (currentAngle < pi * 2) {
      canvas.drawArc(rect, currentAngle, dashAngle, false, paint);
      currentAngle += dashAngle + gapAngle;
    }
  }
}

class SquareDot extends _DotStylePainter {
  const SquareDot({
    required super.size,
    super.thickness,
    super.alignment,
    super.scale,
    super.transformer,
  }) : super._();

  @override
  void _innerDraw(Canvas canvas, Offset center, double width, Paint paint) {
    final halfSize = width * 0.5 * scale;

    canvas.drawRect(
      Rect.fromCenter(center: center, width: halfSize, height: halfSize),
      paint,
    );
  }
}

class DiamondDot extends _DotStylePainter {
  const DiamondDot({
    required super.size,
    super.thickness,
    super.alignment,
    super.scale,
    super.transformer,
  }) : super._();

  @override
  void _innerDraw(Canvas canvas, Offset center, double width, Paint paint) {
    final halfSize = width * 0.5 * scale;
    final path = Path()
      ..moveTo(center.dx, center.dy - halfSize)
      ..lineTo(center.dx + halfSize, center.dy)
      ..lineTo(center.dx, center.dy + halfSize)
      ..lineTo(center.dx - halfSize, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }
}

class LineDot extends _DotStylePainter {
  final DividerDirection direction;

  const LineDot({
    this.direction = DividerDirection.horizontal,
    required super.size,
    super.thickness,
    super.alignment,
    required super.scale,
    super.transformer,
  }) : super._();

  @override
  void _innerDraw(Canvas canvas, Offset center, double width, Paint paint) {
    final halfSize = width * 0.5 * scale;
    if (direction == DividerDirection.horizontal) {
      canvas.drawLine(
        Offset(center.dx - halfSize, center.dy),
        Offset(center.dx + halfSize, center.dy),
        paint,
      );
    } else {
      canvas.drawLine(
        Offset(center.dx, center.dy - halfSize),
        Offset(center.dx, center.dy + halfSize),
        paint,
      );
    }
  }
}

class SlashDot extends _DotStylePainter {
  const SlashDot({
    required super.size,
    super.thickness,
    super.alignment,
    super.scale,
    super.transformer,
  }) : super._();

  @override
  void _innerDraw(Canvas canvas, Offset center, double width, Paint paint) {
    final halfSize = width * 0.5 * scale;
    canvas.drawLine(
      Offset(center.dx - halfSize, center.dy - halfSize),
      Offset(center.dx + halfSize, center.dy + halfSize),
      paint,
    );
  }
}

class BackSlashDot extends _DotStylePainter {
  const BackSlashDot({
    required super.size,
    super.thickness,
    super.alignment,
    super.scale,
    super.transformer,
  }) : super._();

  @override
  void _innerDraw(Canvas canvas, Offset center, double width, Paint paint) {
    final halfSize = width * 0.5 * scale;
    canvas.drawLine(
      Offset(center.dx - halfSize, center.dy + halfSize),
      Offset(center.dx + halfSize, center.dy - halfSize),
      paint,
    );
  }
}

abstract class CustomDot extends _DotStylePainter {
  const CustomDot({
    required super.size,
    super.thickness,
    super.alignment,
    super.scale,
    super.transformer,
  }) : super._();

  @override
  void _innerDraw(Canvas canvas, Offset center, double width, Paint paint) {
    //copy paint
    final forCustomDraw = Paint()
      ..color = paint.color
      ..shader = paint.shader
      ..style = paint.style
      ..strokeWidth = paint.strokeWidth
      ..strokeCap = paint.strokeCap
      ..strokeJoin = paint.strokeJoin
      ..strokeMiterLimit = paint.strokeMiterLimit
      ..maskFilter = paint.maskFilter
      ..filterQuality = paint.filterQuality
      ..colorFilter = paint.colorFilter
      ..blendMode = paint.blendMode
      ..isAntiAlias = paint.isAntiAlias
      ..invertColors = paint.invertColors
      ..imageFilter = paint.imageFilter
      ..color = paint.color;
    canvas.save();
    customDraw(canvas, center, width, forCustomDraw);
    canvas.restore();
  }

  void customDraw(Canvas canvas, Offset center, double width, Paint paint);
}
