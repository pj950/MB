import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/db_service.dart';

class DraggableItemWidget extends StatefulWidget {
  final Offset initialPosition;
  final Widget child;
  final void Function(Offset offset)? onPositionChanged;

  const DraggableItemWidget({
    super.key,
    required this.initialPosition,
    required this.child,
    this.onPositionChanged,
  });

  @override
  State<DraggableItemWidget> createState() => _DraggableItemWidgetState();
}

class _DraggableItemWidgetState extends State<DraggableItemWidget> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        onPanEnd: (_) {
          widget.onPositionChanged?.call(_position);
        },
        child: widget.child,
      ),
    );
  }
}
