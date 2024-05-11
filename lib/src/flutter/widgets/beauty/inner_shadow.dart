// ignore_for_file: library_private_types_in_public_api

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class InnerShadow extends SingleChildRenderObjectWidget {
  const InnerShadow({
    super.key,
    this.shadows = const <Shadow>[],
    super.child,
  });

  final List<Shadow> shadows;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderInnerShadow()..shadows = shadows;

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderInnerShadow renderObject,
  ) {
    renderObject
      ..shadows = shadows
      ..markNeedsPaint();
  }
}

class _RenderInnerShadow extends RenderProxyBox {
  late List<Shadow> shadows;

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }
    final bounds = (offset & size).inflate(1);
    context.canvas.saveLayer(bounds, Paint());
    context.paintChild(child!, offset);
    final shadowPaint = Paint()..blendMode = BlendMode.srcATop;
    for (final shadow in shadows) {
      shadowPaint
        ..imageFilter = ImageFilter.blur(
          sigmaX: shadow is RelativeShadow
              ? shadow.blurRadius * size.width
              : shadow.blurRadius,
          sigmaY: shadow is RelativeShadow
              ? shadow.blurRadius * size.height
              : shadow.blurRadius,
        )
        ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcIn);
      context.canvas.saveLayer(bounds, shadowPaint);
      final invertPaint = Paint()
        ..colorFilter = const ColorFilter.matrix([
          ...[1, 0, 0, 0, 0],
          ...[0, 1, 0, 0, 0],
          ...[0, 0, 1, 0, 0],
          ...[0, 0, 0, -1, 255],
        ]);
      context.canvas.saveLayer(bounds, invertPaint);
      context.canvas.translate(shadow.offset.dx, shadow.offset.dy);
      context.paintChild(child!, offset);
      context.canvas.restore();
      context.canvas.restore();
    }

    context.canvas.restore();
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    if (child != null) {
      visitor(child!);
    }
  }
}

class RelativeShadow extends Shadow {
  const RelativeShadow({
    super.color,
    super.blurRadius,
    super.offset,
  });
}
