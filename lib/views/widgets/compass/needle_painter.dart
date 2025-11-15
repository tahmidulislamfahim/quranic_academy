import 'package:flutter/material.dart';

class NeedlePainter extends CustomPainter {
  final bool isDark;
  NeedlePainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Main needle
    final needlePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.redAccent.shade400, Colors.redAccent.shade200],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..style = PaintingStyle.fill;

    final double length = size.width * 0.38;
    final Path p = Path();
    p.moveTo(center.dx, center.dy - length);
    p.lineTo(center.dx - 12, center.dy + 20);
    p.lineTo(center.dx + 12, center.dy + 20);
    p.close();
    canvas.drawShadow(p, Colors.black, 4.0, false);
    canvas.drawPath(p, needlePaint);

    // Tail
    final tailPaint = Paint()
      ..color = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final Path tail = Path();
    tail.moveTo(center.dx - 6, center.dy + 22);
    tail.lineTo(center.dx + 6, center.dy + 22);
    tail.lineTo(center.dx, center.dy + 48);
    tail.close();
    canvas.drawPath(tail, tailPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
