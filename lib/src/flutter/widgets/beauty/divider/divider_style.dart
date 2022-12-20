import 'package:flutter/widgets.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/divider_type.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/types/divider_direction.dart';

@immutable
abstract class DividerStyle extends CustomPainter {
  final DividerDirection direction;
  final double thickness;
  final DividerType type;

  const DividerStyle({
    this.type = const DividerTypeSolid(),
    this.direction = DividerDirection.horizontal,
    this.thickness = 1,
  });

  @override
  bool shouldRepaint(DividerStyle oldDelegate) =>
      oldDelegate.direction != direction ||
      oldDelegate.thickness != thickness ||
      oldDelegate.type != type;

  void drawDivider(Canvas canvas, Size size, Paint paint) {
    paint.strokeWidth = thickness;
    type.drawDivider(canvas, direction, size, paint);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DividerStyle &&
          runtimeType == other.runtimeType &&
          direction == other.direction &&
          thickness == other.thickness &&
          type == other.type;

  @override
  int get hashCode => direction.hashCode ^ thickness.hashCode ^ type.hashCode;
}

class DividerStyleSolid extends DividerStyle {
  final Color color;

  const DividerStyleSolid({
    super.direction,
    super.thickness,
    super.type,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    drawDivider(canvas, size, paint);
  }

  @override
  bool shouldRepaint(DividerStyleSolid oldDelegate) =>
      super.shouldRepaint(oldDelegate) || oldDelegate.color != color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is DividerStyleSolid &&
          runtimeType == other.runtimeType &&
          color == other.color;

  @override
  int get hashCode => super.hashCode ^ color.hashCode;
}

class DividerStyleGradient extends DividerStyle {
  final Gradient gradient;

  const DividerStyleGradient({
    super.direction,
    super.thickness,
    super.type,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    drawDivider(canvas, size, paint);
  }

  @override
  bool shouldRepaint(DividerStyleGradient oldDelegate) =>
      super.shouldRepaint(oldDelegate) || oldDelegate.gradient != gradient;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is DividerStyleGradient &&
          runtimeType == other.runtimeType &&
          gradient == other.gradient;

  @override
  int get hashCode => super.hashCode ^ gradient.hashCode;
}
