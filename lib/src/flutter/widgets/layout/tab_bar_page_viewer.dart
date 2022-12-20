import 'package:flutter/material.dart';

typedef TabBuilder = Widget Function(
  BuildContext context,
  String name,
  int index,
);

typedef TabHeaderBuilder = Widget Function(
  BuildContext context,
  String name,
  int index,
  bool selected,
);

class TabBarPageViewer extends StatefulWidget {
  final double aspectRatio;
  final Map<String, TabBuilder> tabsBuilder;
  final TabHeaderBuilder tabHeaderBuilder;
  final TabBarPosition tabBarPosition;
  final VoidCallback? onNewTabPressed;
  final Widget? onNewTabWidget;
  final double tabBarFraction;
  final double tabBarAlignment;
  final double? tabBarItemFraction;

  const TabBarPageViewer({
    super.key,
    required this.aspectRatio,
    required this.tabsBuilder,
    required this.tabHeaderBuilder,
    this.tabBarPosition = TabBarPosition.top,
    this.onNewTabPressed,
    this.onNewTabWidget,
    this.tabBarFraction = 1,
    this.tabBarAlignment = 0,
    this.tabBarItemFraction,
  });

  @override
  State<TabBarPageViewer> createState() => _TabBarPageViewerState();
}

class _TabBarPageViewerState extends State<TabBarPageViewer> {
  var _page = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void didUpdateWidget(covariant TabBarPageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabsBuilder.length != widget.tabsBuilder.length) {
      _pageController.jumpToPage(0);
    }
  }

  void _onPageChanged() {
    final round = _pageController.page!.round();
    if (round != _page) {
      setState(() {
        _page = round;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = widget.tabBarPosition == TabBarPosition.top ||
        widget.tabBarPosition == TabBarPosition.bottom;
    final list = [
      for (final tab in widget.tabsBuilder.entries) ...[
        Expanded(
          child: RotatedBox(
            quarterTurns: isVertical
                ? 0
                : widget.tabBarPosition == TabBarPosition.right
                    ? 1
                    : -1,
            child: GestureDetector(
              onTap: () => _pageController.jumpToPage(
                widget.tabsBuilder.keys.toList().indexOf(tab.key),
              ),
              child: widget.tabHeaderBuilder(
                context,
                tab.key,
                widget.tabsBuilder.keys.toList().indexOf(tab.key),
                _page == widget.tabsBuilder.keys.toList().indexOf(tab.key),
              ),
            ),
          ),
        ),
        if (isVertical)
          const VerticalDivider(
            color: Colors.white,
            width: 1,
          )
        else
          const Divider(
            color: Colors.white,
            height: 1,
          ),
      ],
    ];
    if (list.isNotEmpty) {
      list.removeLast();
    }
    if (widget.onNewTabPressed != null && widget.onNewTabWidget == null) {
      list.add(
        GestureDetector(
          onTap: widget.onNewTabPressed,
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) => Icon(
                Icons.add,
                color: Colors.green,
                size: constraints.maxWidth,
              ),
            ),
          ),
        ),
      );
    }
    if (widget.onNewTabWidget != null) {
      list.add(Expanded(child: widget.onNewTabWidget!));
    }
    var layout = [
      AspectRatio(
        aspectRatio: isVertical ? widget.aspectRatio : 1 / widget.aspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) => FractionallySizedBox(
            widthFactor: isVertical ? 1 : widget.tabBarFraction,
            heightFactor: isVertical ? widget.tabBarFraction : 1,
            child: Flex(
              direction: isVertical ? Axis.horizontal : Axis.vertical,
              children: list,
            ),
          ),
        ),
      ),
      Expanded(
        child: Actions(
          actions: {
            TabChangeIntent: CallbackAction<TabChangeIntent>(
              onInvoke: (intent) {
                if (intent.horizontalDirection == 0 && isVertical) {
                  return null;
                }
                if (intent.verticalDirection == 0 && !isVertical) {
                  return null;
                }
                _pageController.jumpToPage(
                  _page + intent.horizontalDirection + intent.verticalDirection,
                );
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            canRequestFocus: true,
            child: PageView(
              controller: _pageController,
              children: [
                for (final tab in widget.tabsBuilder.entries)
                  tab.value(
                    context,
                    tab.key,
                    widget.tabsBuilder.keys.toList().indexOf(tab.key),
                  ),
              ],
            ),
          ),
        ),
      ),
    ];
    if (widget.tabBarPosition == TabBarPosition.right ||
        widget.tabBarPosition == TabBarPosition.bottom) {
      layout = layout.reversed.toList();
    }
    return Flex(
      direction: isVertical ? Axis.vertical : Axis.horizontal,
      children: layout,
    );
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_onPageChanged)
      ..dispose();
    super.dispose();
  }
}

enum TabBarPosition {
  top,
  bottom,
  left,
  right,
}

@immutable
class TabChangeIntent extends Intent {
  final int horizontalDirection;
  final int verticalDirection;

  const TabChangeIntent({
    this.horizontalDirection = 0,
    this.verticalDirection = 0,
  });
}
