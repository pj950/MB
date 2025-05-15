import 'dart:io';
import 'package:flutter/material.dart';

class ThreeBoxWidget extends StatelessWidget {
  final String imagePath;
  final String name;
  final VoidCallback onTap;

  const ThreeBoxWidget({
    super.key,
    required this.imagePath,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateX(0.05)
          ..rotateY(-0.2),
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: File(imagePath).existsSync()
                  ? FileImage(File(imagePath))
                  : const AssetImage('assets/images/box_default.png')
                      as ImageProvider,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 12, offset: Offset(4, 6)),
            ],
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(6),
              color: Colors.black45,
              child: Text(
                name,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
