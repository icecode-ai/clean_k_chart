import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

/// Painter for [KDJIndicator]: K/D/J lines with 80/20 reference levels.
class KDJPainter extends SecondaryIndicatorPainter {
  final KDJStyle style;

  final Paint _linePaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high;

  KDJPainter(super.indicator, {KDJStyle style = const KDJStyle()})
    : style = style {
    _linePaint.strokeWidth = style.lineWidth;
  }

  @override
  TextSpan? buildLabel(
    KLineEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    return TextSpan(
      children: [
        TextSpan(
          text: 'KDJ(${indicator.calcParams.join(',')}) ',
          style: labelStyle(chartColors.defaultTextColor),
        ),
        if (entity.k != null && entity.k != 0)
          TextSpan(
            text: 'K:${formatNumber(entity.k!, precision)}  ',
            style: labelStyle(style.kColor),
          ),
        if (entity.d != null && entity.d != 0)
          TextSpan(
            text: 'D:${formatNumber(entity.d!, precision)}  ',
            style: labelStyle(style.dColor),
          ),
        if (entity.j != null && entity.j != 0)
          TextSpan(
            text: 'J:${formatNumber(entity.j!, precision)}',
            style: labelStyle(style.jColor),
          ),
      ],
    );
  }

  @override
  void drawVerticalText({
    required Canvas canvas,
    required TextStyle style,
    required double maxValue,
    required double minValue,
    required int fixedLength,
    required Rect chartRect,
  }) {
    const levels = [80, 20];
    final spaceRange = maxValue - minValue;
    for (final value in levels) {
      if (value < minValue || value > maxValue) continue;
      textPainter
        ..text = TextSpan(text: value.toString(), style: style)
        ..layout();
      final ratio = (value - minValue) / spaceRange;
      final x = chartRect.width - textPainter.width;
      final y =
          chartRect.bottom - ratio * chartRect.height - textPainter.height / 2;
      textPainter.paint(
        canvas,
        Offset(
          x,
          y.clamp(chartRect.top, chartRect.bottom - textPainter.height),
        ),
      );
    }
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
    // Both endpoints must be present — the old `||` check crashed when
    // exactly one side was still in warm-up.
    if (lastPoint.k != null && curPoint.k != null) {
      canvas.drawLine(
        Offset(curX, getY(curPoint.k!)),
        Offset(lastX, getY(lastPoint.k!)),
        _linePaint..color = style.kColor,
      );
    }
    if (lastPoint.d != null && curPoint.d != null) {
      canvas.drawLine(
        Offset(curX, getY(curPoint.d!)),
        Offset(lastX, getY(lastPoint.d!)),
        _linePaint..color = style.dColor,
      );
    }
    if (lastPoint.j != null && curPoint.j != null) {
      canvas.drawLine(
        Offset(curX, getY(curPoint.j!)),
        Offset(lastX, getY(lastPoint.j!)),
        _linePaint..color = style.jColor,
      );
    }
  }
}
