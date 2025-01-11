import 'package:flutter/material.dart';

class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T extends Object> extends State<Dock<T>> {
  late List<T> _items;
  int? _hoveredIndex;
  int? _dragTargetIndex;
  final GlobalKey _dockKey = GlobalKey();
  double _itemWidth = 64.0;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateItemWidth();
    });
  }

  void _updateItemWidth() {
    final RenderBox? renderBox = _dockKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && _items.isNotEmpty) {
      setState(() {
        _itemWidth = renderBox.size.width / _items.length;
      });
    }
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
  }

  double _getScale(int index) {
    if (_hoveredIndex == null) return 1.0;

    final distance = (index - _hoveredIndex!).abs();
    if (distance == 0) return 1.5;
    if (distance == 1) return 1.3;
    if (distance == 2) return 1.1;
    return 1.0;
  }

  Widget _buildDragTarget(int index, Widget child) {
    return SizedBox(
      height: 64, // Fixed height for drag target
      child: DragTarget<T>(
        onWillAccept: (data) {
          setState(() => _dragTargetIndex = index);
          return true;
        },
        onLeave: (data) {
          setState(() => _dragTargetIndex = null);
        },
        onAcceptWithDetails: (data) {
          final oldIndex = _items.indexOf(data.data);
          onReorder(oldIndex, index);
          setState(() => _dragTargetIndex = null);
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (_dragTargetIndex == index)
                Container(
                  width: _itemWidth,
                  height: 64,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.only(
                  left: _dragTargetIndex == index ? _itemWidth : 0,
                ),
                child: child,
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _dockKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(8),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            return MouseRegion(
              onEnter: (_) => setState(() => _hoveredIndex = index),
              onExit: (_) => setState(() => _hoveredIndex = null),
              child: Draggable<T>(
                data: _items[index],
                feedback: Material(
                  color: Colors.transparent,
                  child: Transform.scale(
                    scale: 1.2,
                    child: widget.builder(_items[index]),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: Transform.scale(
                    scale: _getScale(index),
                    child: widget.builder(_items[index]),
                  ),
                ),
                child: _buildDragTarget(
                  index,
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(
                      begin: 1.0,
                      end: _getScale(index),
                    ),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: widget.builder(_items[index]),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
