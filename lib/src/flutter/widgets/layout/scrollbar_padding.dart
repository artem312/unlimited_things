import 'package:flutter/material.dart';

class ScrollbarPadding extends StatelessWidget {
  final Widget child;
  final double scale;

  const ScrollbarPadding({
    super.key,
    required this.child,
    this.scale = 2,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          right: (Theme.of(context).scrollbarTheme.thickness?.resolve({
                    MaterialState.hovered,
                    MaterialState.focused,
                    MaterialState.pressed,
                  }) ??
                  8) *
              scale,
        ),
        child: child,
      );
}
