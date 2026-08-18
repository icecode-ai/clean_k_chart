/// A user-drawn trend line.
///
/// Anchors are stored as data coordinates — the horizontal position in
/// data space plus the price value — so lines keep pointing at the same
/// bars and prices across zoom, scroll and range changes. [end] is null
/// until the second point is captured.
class TrendLine {
  final TrendLineAnchor start;
  final TrendLineAnchor? end;

  const TrendLine(this.start, this.end);
}

/// One [TrendLine] anchor: data x plus price.
class TrendLineAnchor {
  final double dataX;
  final double price;

  const TrendLineAnchor(this.dataX, this.price);
}
