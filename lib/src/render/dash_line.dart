import 'dart:math' as math;
import 'dart:ui';

/// Draws a dashed line on [canvas], building the dash segments into the
/// reusable [path] to avoid per-segment allocations.
///
/// Falls back to a solid diagonal line when the line is neither perfectly
/// horizontal nor vertical.
void drawDashedLine(
  Canvas canvas,
  Offset begin,
  Offset end,
  Paint paint,
  Path path, {
  double space = 3.0,
  double width = 4.0,
}) {
  path.reset();
  if (begin.dx == end.dx && begin.dy != end.dy) {
    var y = begin.dy;
    while (y < end.dy) {
      final segmentEnd = math.min(y + width, end.dy);
      path
        ..moveTo(begin.dx, y)
        ..lineTo(begin.dx, segmentEnd);
      y += space + width;
    }
  } else if (begin.dy == end.dy && begin.dx != end.dx) {
    var x = begin.dx;
    while (x < end.dx) {
      final segmentEnd = math.min(x + width, end.dx);
      path
        ..moveTo(x, begin.dy)
        ..lineTo(segmentEnd, begin.dy);
      x += space + width;
    }
  } else {
    return;
  }
  canvas.drawPath(path, paint);
}
