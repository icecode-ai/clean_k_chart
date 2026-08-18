import 'dart:ui' show Offset;

/// A user-drawn trend line.
///
/// [start] and [end] store the screen x captured at creation time together
/// with the price value in `dy`, so the line keeps pointing at the same
/// price when the chart is rescaled. [end] is null until the second point
/// is captured.
class TrendLine {
  final Offset start;
  final Offset? end;

  const TrendLine(this.start, this.end);
}
