import 'package:flutter/painting.dart';

/// Shared render helpers used by both panel renderers and indicator
/// painters — single copies instead of parallel implementations.

/// Draws a value line segment, skipping null warm-up values on either
/// end.
void drawValueLine(
  Canvas canvas,
  double? lastValue,
  double? curValue,
  double lastX,
  double curX,
  double Function(double value) getY,
  Paint paint,
  Color color,
) {
  if (lastValue == null || curValue == null) return;
  canvas.drawLine(
    Offset(lastX, getY(lastValue)),
    Offset(curX, getY(curValue)),
    paint..color = color,
  );
}

/// The common label text style (10px in the given [color]).
TextStyle axisLabelStyle(Color color) => TextStyle(fontSize: 10, color: color);
