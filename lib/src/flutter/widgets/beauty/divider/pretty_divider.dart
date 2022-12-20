
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/divider_style.dart';
import 'package:unlimited_things/src/flutter/widgets/beauty/divider/types/divider_direction.dart';

export 'package:unlimited_things/src/flutter/widgets/beauty/divider/divider_style.dart';
export 'package:unlimited_things/src/flutter/widgets/beauty/divider/divider_type.dart';
export 'package:unlimited_things/src/flutter/widgets/beauty/divider/types/divider_direction.dart';
export 'package:unlimited_things/src/flutter/widgets/beauty/divider/types/relative_param.dart';

class PrettyDivider extends SingleChildRenderObjectWidget {
  final DividerStyle style;
  final double? size;

  PrettyDivider({
    super.key,
    this.size,
    this.style = const DividerStyleSolid(color: Colors.black),
  }) : super(child: CustomPaint(painter: style));

  double get _thickness => size ?? style.thickness;

  @override
  RenderObject createRenderObject(BuildContext context) => RenderConstrainedBox(
        additionalConstraints: BoxConstraints.tightFor(
          width: style.direction == DividerDirection.horizontal
              ? double.infinity
              : _thickness,
          height: style.direction == DividerDirection.vertical
              ? double.infinity
              : _thickness,
        ),
      );

  void _updateRenderObject(RenderConstrainedBox renderObject) {
    renderObject
      ..additionalConstraints = BoxConstraints.tightFor(
        width: style.direction == DividerDirection.horizontal
            ? double.infinity
            : _thickness,
        height: style.direction == DividerDirection.vertical
            ? double.infinity
            : _thickness,
      )
      ..markNeedsLayout();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderConstrainedBox renderObject,
  ) {
    _updateRenderObject(renderObject);
  }
}

