import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

/// Painter for [WRIndicator].
class WRPainter extends SecondaryIndicatorPainter {
  final WRStyle style;

  final Paint _linePaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high;

  WRPainter(super.indicator, {WRStyle style = const WRStyle()})
    : style = style {
    _linePaint.strokeWidth = style.lineWidth;
  }

  @override
  TextSpan? buildLabel(
    KLineEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    final wr = entity.wr;
    if (wr == null) return null;
    return TextSpan(
      text: 'WR($primaryParam):${formatNumber(wr, precision)}',
      style: labelStyle(style.wrColor),
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
      lastPoint.wr,
      curPoint.wr,
      lastX,
      curX,
      getY,
      canvas,
      _linePaint,
      style.wrColor,
    );
  }
}
