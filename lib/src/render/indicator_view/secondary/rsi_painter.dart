import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

/// Painter for [RSIIndicator].
class RSIPainter extends SecondaryIndicatorPainter {
  final RSIStyle style;

  final Paint _linePaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high;

  RSIPainter(super.indicator, {RSIStyle style = const RSIStyle()})
    : style = style {
    _linePaint.strokeWidth = style.lineWidth;
  }

  @override
  TextSpan? buildLabel(
    KLineEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    final rsi = entity.rsi;
    if (rsi == null) return null;
    return TextSpan(
      text:
          'RSI(${indicator.calcParams.first}):${formatNumber(rsi, precision)}',
      style: labelStyle(style.rsiColor),
    );
  }

  @override
  void drawChart(
    KLineEntity lastPoint,
    KLineEntity curPoint,
    double lastX,
    double curX,
    ValueY getY,
    Canvas canvas,
    KChartColors chartColors,
  ) {
    drawSingleLine(
      lastPoint.rsi,
      curPoint.rsi,
      lastX,
      curX,
      getY,
      canvas,
      _linePaint,
      style.rsiColor,
    );
  }
}
