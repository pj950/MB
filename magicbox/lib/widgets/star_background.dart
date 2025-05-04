import 'package:flutter/material.dart';

class StarFieldBackground extends StatefulWidget {
  const StarFieldBackground({super.key});

  @override
  State<StarFieldBackground> createState() => _StarFieldBackgroundState();
}

class _StarFieldBackgroundState extends State<StarFieldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _StarPainter(_controller.value),
        );
      },
    );
  }
}

class _StarPainter extends CustomPainter {
  final double progress;
  _StarPainter(this.progress);

  final List<Offset> _stars = List.generate(
    100,
    (_) => Offset(
      1000 * (0.5 + 0.5 * (1 - (2 * (0.5 - 0.5 * 2).abs()))),
      1000 * (0.5 + 0.5 * (1 - (2 * (0.5 - 0.5 * 2).abs()))),
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final baseHue = (progress * 360) % 360;
    final color = HSLColor.fromAHSL(1.0, baseHue, 1.0, 0.8).toColor();
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.fill;

    for (final star in _stars) {
      final dx = (star.dx + progress * 200) % size.width;
      final dy = (star.dy + progress * 100) % size.height;
      canvas.drawCircle(Offset(dx, dy), 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => true;
}
