import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/model/entity/candle_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

class SARPainter extends IndicatorPainter<CandleEntity, SARStyle> {
  late final Paint _dotPaint;

  SARPainter(super.indicator) {
    _dotPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..style = PaintingStyle.stroke
      ..strokeWidth = indicatorStyle.strokeWidth;
  }

  @override
  TextSpan? drawFigure(
    CandleEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    double? value = entity.sar;
    if (value == null) return null;
    return TextSpan(
      text: "SAR: ${formatNumber(value, precision)}",
      style: TextStyle(fontSize: 10, color: indicatorStyle.sarColor),
    );
  }

  @override
  void drawChart(
    CandleEntity lastPoint,
    CandleEntity curPoint,
    double lastX,
    double curX,
    GetYFunction getY,
    Canvas canvas,
    KChartColors chartColors,
  ) {
    final sar = curPoint.sar;
    if (sar == null) return;
    final halfHL = (curPoint.high + curPoint.low) / 2;
    late final color;
    if (sar == halfHL) {
      color = chartColors.defaultTextColor;
    } else if (sar < halfHL) {
      color = chartColors.upColor;
    } else {
      color = chartColors.dnColor;
    }
    canvas.drawCircle(
      Offset(curX, getY(sar)),
      indicatorStyle.radius,
      _dotPaint..color = color,
    );
  }
}
