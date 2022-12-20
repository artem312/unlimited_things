import 'dart:async';

import 'package:flutter/material.dart';

class ConditionalWrapperBuilder extends StatelessWidget {
  final FutureOr<bool> condition;
  final Widget child;
  final Widget Function(BuildContext context, Widget child) builder;

  const ConditionalWrapperBuilder({
    super.key,
    required this.condition,
    required this.child,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: Future.value(condition),
        builder: (context, snapshot) => snapshot.hasData
            ? (snapshot.data! ? builder(context, child) : child)
            : const SizedBox(),
      );
}
