import 'dart:ui';

abstract class BaseChartRenderer<T> {
  double maxValue, minValue;

  late double scaleY;

  double topPadding;
  Rect chartRect;
  int fixedLength;

  Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0
    ..color = const Color(0xFFFF0000);

  Paint gridPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5
    ..color = const Color(0xff4c5c74);

  BaseChartRenderer({
    required this.chartRect,
    required this.maxValue,
    required this.minValue,
    required this.topPadding,
    required this.fixedLength,
    required Color gridColor,
  }) {
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }

    scaleY = chartRect.height / (maxValue - minValue);

    gridPaint.color = gridColor;
  }

  double getY(double y) => (maxValue - y) * scaleY + chartRect.top;

  void drawGrid(Canvas canvas, int gridRows, int gridColumns);

  void drawText(Canvas canvas, T data, double x);

  void drawVerticalText(Canvas canvas, style, int gridRows);

  void drawChart(
    T lastPoint,
    T curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  );

  void drawLine(
    double? lastPrice,
    double? curPrice,
    Canvas canvas,
    double lastX,
    double curX,
    Color color,
  ) {
    if (lastPrice == null || curPrice == null) {
      return;
    }

    final double lastY = getY(lastPrice);
    final double curY = getY(curPrice);

    canvas.drawLine(
      Offset(lastX, lastY),
      Offset(curX, curY),
      chartPaint..color = color,
    );
  }
}
