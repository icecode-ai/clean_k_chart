import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

/// Painter for [SARIndicator]: dots below/above the candles, colored by
/// trend direction.
class SARPainter extends IndicatorPainter {
  final SARStyle style;

  final Paint _dotPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..style = PaintingStyle.stroke;

  SARPainter(super.indicator, {SARStyle style = const SARStyle()})
    : style = style {
    _dotPaint.strokeWidth = style.strokeWidth;
  }

  @override
  TextSpan? buildLabel(
    KLineEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    final value = entity.sar;
    if (value == null) return null;
    return TextSpan(
      text: 'SAR: ${formatNumber(value, precision)}',
      style: labelStyle(style.sarColor),
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
    final sar = curPoint.sar;
    if (sar == null) return;
    final halfHL = (curPoint.high + curPoint.low) / 2;
    final Color color;
    if (sar == halfHL) {
      color = chartColors.defaultTextColor;
    } else if (sar < halfHL) {
      color = chartColors.upColor;
    } else {
      color = chartColors.dnColor;
    }
    canvas.drawCircle(
      Offset(curX, getY(sar)),
      style.radius,
      _dotPaint..color = color,
    );
  }
}
