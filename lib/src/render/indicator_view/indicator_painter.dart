import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

/// Converts a data value to a screen y coordinate.
typedef ValueY = double Function(double value);

/// Rendering counterpart of [Indicator].
///
/// Owns all Canvas/TextSpan drawing logic so indicators stay pure
/// calculation classes. Instances are long-lived; [Paint]s are allocated
/// once in the constructor.
abstract class IndicatorPainter {
  final Indicator indicator;

  IndicatorPainter(this.indicator);

  /// Builds the header label span for [entity]; null hides the label.
  TextSpan? buildLabel(
    KLineEntity entity,
    int precision,
    KChartColors chartColors,
  );

  /// Draws one data step (from [lastPoint] to [curPoint]).
  void drawChart(
    KLineEntity lastPoint,
    KLineEntity curPoint,
    double lastX,
    double curX,
    ValueY getY,
    Canvas canvas,
    KChartColors chartColors,
  );

  TextStyle labelStyle(Color color) => TextStyle(fontSize: 10, color: color);

  /// First calc param for single-param labels; `--` when the indicator
  /// was constructed with an empty param list (never throws in paint).
  String get primaryParam =>
      indicator.calcParams.isEmpty ? '--' : '${indicator.calcParams.first}';

  String formatNumber(double value, int precision) =>
      NumberUtil.format(value, precision) ?? '--';
}

/// Rendering counterpart of [SecondaryIndicator] — adds the vertical axis
/// label hook used by [SecondaryRenderer].
abstract class SecondaryIndicatorPainter extends IndicatorPainter {
  SecondaryIndicatorPainter(super.indicator);

  /// Reused painter for axis labels — never reallocated.
  final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);

  /// Max / min labels at the top-right and bottom-right of the panel.
  /// Override to draw custom reference levels (e.g. KDJ's 80/20).
  void drawVerticalText({
    required Canvas canvas,
    required TextStyle style,
    required double maxValue,
    required double minValue,
    required int fixedLength,
    required Rect chartRect,
  }) {
    _paintEdgeLabel(
      canvas,
      style,
      NumberUtil.formatFixed(maxValue, fixedLength) ?? '',
      chartRect,
      atTop: true,
    );
    _paintEdgeLabel(
      canvas,
      style,
      NumberUtil.formatFixed(minValue, fixedLength) ?? '',
      chartRect,
      atTop: false,
    );
  }

  void _paintEdgeLabel(
    Canvas canvas,
    TextStyle style,
    String text,
    Rect chartRect, {
    required bool atTop,
  }) {
    textPainter
      ..text = TextSpan(text: text, style: style)
      ..layout();
    final dx = chartRect.width - textPainter.width;
    final dy = atTop ? chartRect.top : chartRect.bottom - textPainter.height;
    textPainter.paint(canvas, Offset(dx, dy));
  }

  /// Single-line helper for one-value indicators (RSI / WR / CCI …).
  void drawSingleLine(
    double? lastValue,
    double? curValue,
    double lastX,
    double curX,
    ValueY getY,
    Canvas canvas,
    Paint paint,
    Color color,
  ) {
    if (lastValue == null || curValue == null) return;
    canvas.drawLine(
      Offset(lastX, getY(lastValue)),
      Offset(curX, getY(curValue)),
      paint..color = color,
    );
  }
}
