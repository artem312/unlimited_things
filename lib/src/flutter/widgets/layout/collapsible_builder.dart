import 'package:flutter/material.dart';
import 'package:unlimited_things/src/flutter/widgets/layout/conditional_wrapper_builder.dart';

class CollapsibleBuilder extends StatefulWidget {
  final bool collapsed;
  final bool haveScrollableBody;
  final Widget Function(BuildContext context) builder;
  final Widget Function(BuildContext context, bool collapsed) headerBuilder;
  final CrossAxisAlignment crossAxisAlignment;

  const CollapsibleBuilder({
    super.key,
    this.collapsed = true,
    this.haveScrollableBody = false,
    required this.builder,
    required this.headerBuilder,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  State<CollapsibleBuilder> createState() => _CollapsibleBuilderState();
}

class _CollapsibleBuilderState extends State<CollapsibleBuilder> {
  late bool _collapsed;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.collapsed;
  }

  @override
  Widget build(BuildContext context) => ConditionalWrapperBuilder(
        condition: widget.haveScrollableBody,
        builder: (context, child) => SingleChildScrollView(
          child: child,
        ),
        child: Column(
          crossAxisAlignment: widget.crossAxisAlignment,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => setState(() => _collapsed = !_collapsed),
              child: widget.headerBuilder(context, _collapsed),
            ),
            if (!_collapsed)
              if (widget.haveScrollableBody)
                Expanded(
                  child: widget.builder(context),
                )
              else
                widget.builder(context),
          ],
        ),
      );
}
