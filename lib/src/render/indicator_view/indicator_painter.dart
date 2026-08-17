import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

typedef GetYFunction = double Function(double y);

/// Rendering counterpart of [Indicator].
///
/// Owns all Canvas/TextSpan drawing logic so indicators stay pure
/// calculation classes.
abstract class IndicatorPainter<T, K extends IndicatorStyle> {
  final Indicator<T, K> indicator;

  IndicatorPainter(this.indicator);

  K get indicatorStyle => indicator.indicatorStyle;

  TextSpan? drawFigure(T entity, int precision, KChartColors chartColors);

  void drawChart(
    T lastPoint,
    T curPoint,
    double lastX,
    double curX,
    GetYFunction getY,
    Canvas canvas,
    KChartColors chartColors,
  );

  TextStyle getTextStyle(Color? color) {
    return TextStyle(fontSize: 10, color: color);
  }

  String formatNumber(double value, int precision) {
    return indicator.formatNumber(value, precision);
  }
}

/// Rendering counterpart of [SecondaryIndicator].
abstract class SecondaryIndicatorPainter<T, K extends IndicatorStyle>
    extends IndicatorPainter<T, K> {
  SecondaryIndicatorPainter(super.indicator);

  void drawVerticalText({
    required Canvas canvas,
    required TextStyle style,
    required double maxValue,
    required double minValue,
    required int fixedLength,
    required Rect chartRect,
  });
}
