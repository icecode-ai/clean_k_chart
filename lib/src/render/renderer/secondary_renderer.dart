import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/render/renderer/base_chart_renderer.dart';
import 'package:flutter/painting.dart';

/// Renders one secondary indicator panel (MACD / KDJ / RSI / WR / CCI).
class SecondaryRenderer extends BaseChartRenderer {
  final SecondaryIndicator indicator;
  final SecondaryIndicatorPainter painter;

  SecondaryRenderer({
    required super.chartStyle,
    required super.chartColors,
    required super.topPadding,
    required this.indicator,
    required this.painter,
  });

  @override
  void drawChart(
    KLineEntity lastPoint,
    KLineEntity curPoint,
    double lastX,
    double curX,
    Canvas canvas, {
    double scaleX = 1,
  }) {
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

  @override
  void drawHeaderLabels(Canvas canvas, KLineEntity data, double x) {
    final span = painter.buildLabel(data, fixedLength, chartColors);
    if (span == null) return;
    drawHeaderText(canvas, span, Offset(x, headerY));
  }

  @override
  void drawVerticalText(Canvas canvas, TextStyle textStyle) {
    painter.drawVerticalText(
      canvas: canvas,
      style: textStyle,
      maxValue: maxValue,
      minValue: minValue,
      fixedLength: fixedLength,
      chartRect: Rect.fromLTRB(
        chartRect.left,
        headerY,
        chartRect.right - chartStyle.space,
        chartRect.bottom,
      ),
    );
  }
}
