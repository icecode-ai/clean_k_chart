import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/render/renderer/base_chart_renderer.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart';
import 'package:flutter/painting.dart';

/// Renders the main candlestick / line panel plus its main-indicator
/// overlays.
class MainRenderer extends BaseChartRenderer {
  final List<IndicatorPainter> indicatorPainters;
  final bool isLine;
  final VerticalTextAlignment verticalTextAlignment;

  static const double _contentPadding = 5.0;
  static const double _lineStrokeWidth = 1.0;

  Rect _contentRect = Rect.zero;

  final Paint _linePaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;
  final Paint _lineFillPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill;
  final Path _linePath = Path();
  final Path _lineFillPath = Path();
  Shader? _lineFillShader;
  Rect _shaderRect = Rect.zero;

  MainRenderer({
    required super.chartStyle,
    required super.chartColors,
    required super.topPadding,
    required this.indicatorPainters,
    required this.isLine,
    required this.verticalTextAlignment,
  }) {
    _linePaint
      ..strokeWidth = _lineStrokeWidth
      ..color = chartColors.kLineColor;
  }

  @override
  void update({
    required Rect rect,
    required double maxValue,
    required double minValue,
    required int fixedLength,
  }) {
    super.update(
      rect: rect,
      maxValue: maxValue,
      minValue: minValue,
      fixedLength: fixedLength,
    );
    _contentRect = Rect.fromLTRB(
      rect.left,
      rect.top + _contentPadding,
      rect.right,
      rect.bottom - _contentPadding,
    );
    scaleY = _contentRect.height / (maxValue - minValue);
  }

  @override
  double getY(double value) => (maxValue - value) * scaleY + _contentRect.top;

  /// Inverse of [getY]: the value displayed at screen y [dy].
  /// Used to capture trend line anchor points at a price.
  double valueFromY(double dy) => maxValue - (dy - _contentRect.top) / scaleY;

  @override
  void drawGrid(Canvas canvas) {
    super.drawGrid(canvas);
    final rows = chartStyle.gridRows > 0 ? chartStyle.gridRows : 1;
    final rowSpace = chartRect.height / rows;
    for (var i = 1; i < rows; i++) {
      final y = chartRect.top + rowSpace * i;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }
  }

  @override
  void drawHeaderLabels(Canvas canvas, KLineEntity data, double x) {
    if (isLine) return;
    var y = chartStyle.indicatorTopMargin;
    for (final painter in indicatorPainters) {
      final span = painter.buildLabel(data, fixedLength, chartColors);
      if (span == null) continue;
      final height = drawHeaderText(
        canvas,
        span,
        Offset(x, y),
        withBackground: true,
      );
      y += height + 2.0;
    }
  }

  @override
  void drawVerticalText(Canvas canvas, TextStyle textStyle) {
    final rows = chartStyle.gridRows > 0 ? chartStyle.gridRows : 1;
    final rowSpace = chartRect.height / rows;
    for (var i = 0; i <= rows; i++) {
      final value = (rows - i) * rowSpace / scaleY + minValue;
      labelPainter
        ..text = TextSpan(text: formatAxisValue(value), style: textStyle)
        ..layout();
      final offsetX = switch (verticalTextAlignment) {
        VerticalTextAlignment.left => chartStyle.space,
        VerticalTextAlignment.right =>
          chartRect.width - labelPainter.width - chartStyle.space,
      };
      final y = i == 0
          ? topPadding
          : rowSpace * i - labelPainter.height + topPadding;
      labelPainter.paint(canvas, Offset(offsetX, y));
    }
  }

  @override
  void drawChart(
    KLineEntity lastPoint,
    KLineEntity curPoint,
    double lastX,
    double curX,
    Canvas canvas, {
    double scaleX = 1,
  }) {
    if (isLine) {
      _drawPolyline(
        lastPoint.close,
        curPoint.close,
        canvas,
        lastX,
        curX,
        scaleX,
      );
    } else {
      _drawCandle(curPoint, canvas, curX);
      for (final painter in indicatorPainters) {
        painter.drawChart(
          lastPoint,
          curPoint,
          lastX,
          curX,
          getY,
          canvas,
          chartColors,
        );
      }
    }
  }

  void _drawPolyline(
    double lastPrice,
    double curPrice,
    Canvas canvas,
    double lastX,
    double curX,
    double scaleX,
  ) {
    if (lastX == curX) lastX = 0; // fill from the left edge at the start
    _linePath.moveTo(lastX, getY(lastPrice));
    _linePath.cubicTo(
      (lastX + curX) / 2,
      getY(lastPrice),
      (lastX + curX) / 2,
      getY(curPrice),
      curX,
      getY(curPrice),
    );

    if (_lineFillShader == null || _shaderRect != chartRect) {
      _lineFillShader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: chartColors.kLineFillColors,
      ).createShader(chartRect);
      _shaderRect = chartRect;
      _lineFillPaint.shader = _lineFillShader;
    }

    _lineFillPath.moveTo(lastX, chartRect.bottom);
    _lineFillPath.lineTo(lastX, getY(lastPrice));
    _lineFillPath.cubicTo(
      (lastX + curX) / 2,
      getY(lastPrice),
      (lastX + curX) / 2,
      getY(curPrice),
      curX,
      getY(curPrice),
    );
    _lineFillPath.lineTo(curX, chartRect.bottom);
    _lineFillPath.close();

    canvas.drawPath(_lineFillPath, _lineFillPaint);
    _lineFillPath.reset();

    canvas.drawPath(
      _linePath,
      _linePaint..strokeWidth = (_lineStrokeWidth / scaleX).clamp(0.1, 1.0),
    );
    _linePath.reset();
  }

  void _drawCandle(KLineEntity curPoint, Canvas canvas, double curX) {
    final high = getY(curPoint.high);
    final low = getY(curPoint.low);
    var open = getY(curPoint.open);
    var close = getY(curPoint.close);
    final r = chartStyle.candleWidth / 2;
    final lineR = chartStyle.candleLineWidth / 2;
    if (open >= close) {
      if (open - close < chartStyle.candleLineWidth) {
        open = close + chartStyle.candleLineWidth;
      }
      chartPaint.color = chartColors.upColor;
    } else {
      if (close - open < chartStyle.candleLineWidth) {
        open = close - chartStyle.candleLineWidth;
      }
      chartPaint.color = chartColors.dnColor;
    }
    canvas.drawRect(Rect.fromLTRB(curX - r, close, curX + r, open), chartPaint);
    canvas.drawRect(
      Rect.fromLTRB(curX - lineR, high, curX + lineR, low),
      chartPaint,
    );
  }
}
