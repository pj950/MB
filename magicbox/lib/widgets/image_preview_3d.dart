// _ImagePreview3D 旋转预览组件
import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview3D extends StatefulWidget {
  final String path;
  const ImagePreview3D({super.key, required this.path});

  @override
  State<ImagePreview3D> createState() => _ImagePreview3DState();
}

class _ImagePreview3DState extends State<ImagePreview3D> {
  double _rotationY = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _rotationY += details.delta.dx * 0.01;
          });
        },
        child: InteractiveViewer(
          child: Center(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_rotationY),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(widget.path),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
