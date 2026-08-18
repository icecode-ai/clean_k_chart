import 'dart:math' as math;
import 'dart:ui';

/// Draws a dashed line on [canvas], building the dash segments into the
/// reusable [path] to avoid per-segment allocations.
///
/// Both orientations are accepted in either direction (begin/end are
/// normalized). Falls back to a solid line when the line is neither
/// perfectly horizontal nor vertical.
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
  if (begin.dx == end.dx) {
    final top = math.min(begin.dy, end.dy);
    final bottom = math.max(begin.dy, end.dy);
    var y = top;
    while (y < bottom) {
      final segmentEnd = math.min(y + width, bottom);
      path
        ..moveTo(begin.dx, y)
        ..lineTo(begin.dx, segmentEnd);
      y += space + width;
    }
  } else if (begin.dy == end.dy) {
    final left = math.min(begin.dx, end.dx);
    final right = math.max(begin.dx, end.dx);
    var x = left;
    while (x < right) {
      final segmentEnd = math.min(x + width, right);
      path
        ..moveTo(x, begin.dy)
        ..lineTo(segmentEnd, begin.dy);
      x += space + width;
    }
  } else {
    canvas.drawLine(begin, end, paint);
    return;
  }
  canvas.drawPath(path, paint);
}
