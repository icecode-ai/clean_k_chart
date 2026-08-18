import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

/// Painter for [CCIIndicator].
class CCIPainter extends SecondaryIndicatorPainter {
  final CCIStyle style;

  final Paint _linePaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high;

  CCIPainter(super.indicator, {CCIStyle style = const CCIStyle()})
    : style = style {
    _linePaint.strokeWidth = style.lineWidth;
  }

  @override
  TextSpan? buildLabel(
    KLineEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    final cci = entity.cci;
    if (cci == null) return null;
    return TextSpan(
      text: 'CCI($primaryParam):${formatNumber(cci, precision)}',
      style: labelStyle(style.cciColor),
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
    // CCI values are wide — round labels to a coarse step.
    final jumpStep = maxValue - minValue;
    final jumpValue = jumpStep >= 100 ? 100 : (jumpStep >= 10 ? 10 : 1);
    _paintRounded(canvas, style, maxValue, jumpValue, chartRect, atTop: true);
    _paintRounded(canvas, style, minValue, jumpValue, chartRect, atTop: false);
  }

  void _paintRounded(
    Canvas canvas,
    TextStyle style,
    double value,
    int jumpValue,
    Rect chartRect, {
    required bool atTop,
  }) {
    final rounded = (value / jumpValue).round() * jumpValue;
    textPainter
      ..text = TextSpan(
        text: NumberUtil.formatFixed(rounded, 0) ?? '',
        style: style,
      )
      ..layout();
    textPainter.paint(
      canvas,
      Offset(
        chartRect.width - textPainter.width,
        atTop ? chartRect.top : chartRect.bottom - textPainter.height,
      ),
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
      lastPoint.cci,
      curPoint.cci,
      lastX,
      curX,
      getY,
      canvas,
      _linePaint,
      style.cciColor,
    );
  }
}
