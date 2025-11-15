import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:quranic_academy/views/widgets/compass/compass_dial_painter.dart';
import 'package:quranic_academy/views/widgets/compass/needle_painter.dart';
import 'package:get/get.dart';

class QiblaCompass extends StatefulWidget {
  final double qiblaDegrees;
  const QiblaCompass({super.key, required this.qiblaDegrees});

  @override
  State<QiblaCompass> createState() => _QiblaCompassState();
}

class _QiblaCompassState extends State<QiblaCompass> {
  bool _notified = false;
  static const double _alignThreshold = 3.0; // degrees tolerance
  static const double _resetThreshold = 6.0; // degrees to reset notification

  String _cardinalFor(double deg) {
    final d = (deg % 360 + 360) % 360;
    if (d >= 337.5 || d < 22.5) return 'N';
    if (d >= 22.5 && d < 67.5) return 'NE';
    if (d >= 67.5 && d < 112.5) return 'E';
    if (d >= 112.5 && d < 157.5) return 'SE';
    if (d >= 157.5 && d < 202.5) return 'S';
    if (d >= 202.5 && d < 247.5) return 'SW';
    if (d >= 247.5 && d < 292.5) return 'W';
    return 'NW';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<double?>(
      stream: FlutterCompass.events?.map((e) => e.heading),
      builder: (context, snapshot) {
        final heading = snapshot.data;
        final qiblaDegrees = widget.qiblaDegrees;
        final angleDegrees = (heading == null)
            ? qiblaDegrees
            : (qiblaDegrees - heading);
        final angleRad = angleDegrees * math.pi / 180;
        _cardinalFor(qiblaDegrees);

        // Alignment detection: compute smallest angular difference
        if (heading != null) {
          double diff = (qiblaDegrees - heading) % 360;
          if (diff > 180) diff -= 360;
          diff = diff.abs();

          if (diff <= _alignThreshold && !_notified) {
            _notified = true;
            // show snackbar once when aligned
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              Get.snackbar(
                'Qibla aligned',
                'Direction found',
                duration: const Duration(seconds: 2),
              );
            });
          } else if (diff > _resetThreshold && _notified) {
            // reset when moved away to allow next notification
            _notified = false;
          }
        }

        return Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double size;
              if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
                size = math.min(constraints.maxWidth, constraints.maxHeight);
              } else if (constraints.hasBoundedHeight) {
                size = constraints.maxHeight;
              } else if (constraints.hasBoundedWidth) {
                size = math.min(constraints.maxWidth, 300.0);
              } else {
                size = 300.0;
              }
              size = math.min(size, 300.0);

              return SizedBox(
                width: size,
                height: size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dial with gradient
                    CustomPaint(
                      size: Size.square(size),
                      painter: CompassDialPainter(isDark: isDark),
                    ),

                    // Top heading icon & text (position scaled to size)

                    // Needle
                    Transform.rotate(
                      angle: angleRad,
                      child: SizedBox(
                        width: size * 0.72,
                        height: size * 0.72,
                        child: Center(
                          child: CustomPaint(
                            painter: NeedlePainter(isDark: isDark),
                            size: Size.square(size * 0.72),
                          ),
                        ),
                      ),
                    ),

                    // Center glowing hub
                    Container(
                      width: math.max(10.0, size * 0.055),
                      height: math.max(10.0, size * 0.055),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.redAccent.shade400,
                            Colors.redAccent.shade200,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.5),
                            blurRadius: math.max(4.0, size * 0.03),
                            spreadRadius: math.max(0.5, size * 0.005),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
