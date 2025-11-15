import 'dart:math' as math;
import 'package:flutter/material.dart';

class CompassDialPainter extends CustomPainter {
  final bool isDark;
  CompassDialPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Background gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [Colors.black87, Colors.black54]
            : [Colors.white, Colors.blue.shade50],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Outer ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = isDark ? Colors.white24 : Colors.grey.shade300;
    canvas.drawCircle(center, radius, ringPaint);

    // Ticks
    for (int i = 0; i < 360; i += 3) {
      final double a = i * math.pi / 180 - math.pi / 2;
      final bool isMajor = i % 30 == 0;
      final bool isMedium = i % 10 == 0 && !isMajor;
      final double outer = radius;
      final double inner =
          radius -
          (isMajor
              ? 18
              : isMedium
              ? 12
              : 6);
      final Paint tickPaint = Paint()
        ..strokeWidth = isMajor ? 2.2 : (isMedium ? 1.6 : 1.0)
        ..color = isDark
            ? Colors.white70.withOpacity(isMajor ? 0.9 : 0.5)
            : Colors.black54.withOpacity(isMajor ? 0.9 : 0.5)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(
          center.dx + outer * math.cos(a),
          center.dy + outer * math.sin(a),
        ),
        Offset(
          center.dx + inner * math.cos(a),
          center.dy + inner * math.sin(a),
        ),
        tickPaint,
      );
    }

    // Cardinal letters N E S W
    final cardStyle = TextStyle(
      color: isDark ? Colors.white : Colors.black87,
      fontSize: 22,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(blurRadius: 3, color: Colors.black26, offset: Offset(1, 1)),
      ],
    );

    // Place cardinals explicitly so West appears at the top
    final double r = radius - 60;
    final topPos = Offset(center.dx, center.dy - r);
    final rightPos = Offset(center.dx + r, center.dy);
    final bottomPos = Offset(center.dx, center.dy + r);
    final leftPos = Offset(center.dx - r, center.dy);

    final tpW = TextPainter(
      text: TextSpan(text: 'W', style: cardStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tpW.paint(
      canvas,
      Offset(topPos.dx - tpW.width / 2, topPos.dy - tpW.height / 2),
    );

    final tpN = TextPainter(
      text: TextSpan(text: 'N', style: cardStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tpN.paint(
      canvas,
      Offset(rightPos.dx - tpN.width / 2, rightPos.dy - tpN.height / 2),
    );

    final tpE = TextPainter(
      text: TextSpan(text: 'E', style: cardStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tpE.paint(
      canvas,
      Offset(bottomPos.dx - tpE.width / 2, bottomPos.dy - tpE.height / 2),
    );

    final tpS = TextPainter(
      text: TextSpan(text: 'S', style: cardStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tpS.paint(
      canvas,
      Offset(leftPos.dx - tpS.width / 2, leftPos.dy - tpS.height / 2),
    );

    // Inner ring
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = isDark ? Colors.white12 : Colors.grey.shade200;
    canvas.drawCircle(center, radius - 72, innerPaint);

    // Center crosshair
    final crossPaint = Paint()
      ..strokeWidth = 1.6
      ..color = isDark ? Colors.white60 : Colors.black54;
    canvas.drawLine(
      Offset(center.dx - 12, center.dy),
      Offset(center.dx + 12, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 12),
      Offset(center.dx, center.dy + 12),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
