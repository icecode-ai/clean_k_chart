/// Owns the horizontal window (scale / scroll) over the K-line data and
/// converts between screen x coordinates and data indexes.
///
/// One instance per chart, held by the widget state and shared with the
/// painter — replaces the former static/global scroll state so multiple
/// charts no longer clobber each other.
class ChartViewport {
  /// Horizontal zoom factor (candle width multiplier).
  double scaleX;

  /// Horizontal scroll offset in screen pixels, clamped to
  /// `0 .. maxScrollX`.
  double scrollX;

  /// Screen width of the chart, set at layout time.
  double width;

  /// Number of data points.
  int itemCount;

  /// Horizontal distance between two data points.
  double pointWidth;

  /// Extra right-hand padding reserved in the data area.
  double frontPadding;

  ChartViewport({
    this.scaleX = 0.5,
    this.scrollX = 0,
    this.width = 0,
    this.itemCount = 0,
    required this.pointWidth,
    this.frontPadding = 0,
  });

  /// Total width the data occupies in data coordinates.
  double get dataLength => itemCount * pointWidth;

  double getX(int index) => index * pointWidth + pointWidth / 2;

  /// Left-most translate offset; never positive (data starts at x = 0).
  double get minTranslateX {
    final x = -dataLength + width / scaleX - pointWidth / 2 - frontPadding;
    return x >= 0 ? 0.0 : x;
  }

  /// Upper bound for [scrollX].
  double get maxScrollX => minTranslateX.abs();

  double get translateX => scrollX + minTranslateX;

  /// Converts a screen x to a data x.
  double xToDataX(double x) => -translateX + x / scaleX;

  /// Converts a data x back to screen x.
  double dataXToX(double dataX) => (dataX + translateX) * scaleX;

  /// Index of the data point closest to data x [dataX], clamped to the
  /// data range.
  ///
  /// Points sit on a uniform grid (`x = i * pointWidth + pointWidth / 2`),
  /// so the nearest index is direct rounding — this replaced a recursive
  /// binary search that ran on every lookup.
  int indexOfDataX(double dataX) {
    if (itemCount == 0 || pointWidth <= 0) return 0;
    final raw = dataX / pointWidth - 0.5;
    if (!raw.isFinite) return dataX <= 0 ? 0 : itemCount - 1;
    return raw.round().clamp(0, itemCount - 1);
  }

  /// First visible index.
  int get startIndex => indexOfDataX(xToDataX(0));

  /// Last visible index.
  int get stopIndex => indexOfDataX(xToDataX(width));

  /// Index of the data point under screen x [x], clamped to the
  /// visible window.
  int selectedIndex(double x) {
    var index = indexOfDataX(xToDataX(x));
    if (index < startIndex) index = startIndex;
    if (index > stopIndex) index = stopIndex;
    return index;
  }
}
