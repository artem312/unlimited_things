// ignore_for_file: library_private_types_in_public_api

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

//todo: make inner fade
class InnerFade extends SingleChildRenderObjectWidget {
  final double blur;
  final Offset offset;
  final bool relative;

  const InnerFade({
    super.key,
    this.blur = 10,
    this.offset = Offset.zero,
    super.child,
  })  : relative = false,
        assert(blur >= 0, 'blur must be greater than or equal to 0');

  const InnerFade.relative({
    super.key,
    this.blur = 1,
    this.offset = Offset.zero,
    super.child,
  })  : relative = true,
        assert(blur >= 0, 'blur must be greater than or equal to 0');

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = _RenderInnerFade();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderInnerFade renderObject,
  ) {
    renderObject
      ..blur = blur
      ..dx = offset.dx
      ..dy = offset.dy
      ..relative = relative;
  }
}

class _RenderInnerFade extends RenderProxyBox {
  late bool relative;
  late double blur;
  late double dx;
  late double dy;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }

    final rectOuter = offset & size;
    final rectInner = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width - dx,
      size.height - dy,
    );
    final canvas = context.canvas..saveLayer(rectOuter, Paint());
    context.paintChild(child!, offset);
    final blurX = relative ? blur * size.width : blur;
    final blurY = relative ? blur * size.height : blur;
    final shadowPaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..imageFilter = ImageFilter.blur(sigmaX: blurX, sigmaY: blurY)
      ..colorFilter = const ColorFilter.mode(Colors.black, BlendMode.srcOut);

    canvas
      ..saveLayer(rectOuter, shadowPaint)
      ..saveLayer(rectInner, Paint())
      ..translate(dx, dy);
    context.paintChild(child!, offset);
    context.canvas
      ..restore()
      ..restore()
      ..restore();
  }
}
