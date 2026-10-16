import 'package:clean_k_chart/src/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

typedef GetYFunction = double Function(double y);

abstract class IndicatorTemplate<T, K> {
  final String name;

  final String shortName;

  final List<int> calcParams;

  final K indicatorStyle;

  IndicatorTemplate({
    required this.name,
    required this.shortName,
    required this.calcParams,
    required this.indicatorStyle,
  });

  /// record.$1 : min value
  /// record.$2: max value
  (double, double) getMaxMinValue(KLineEntity entity, double minV, double maxV);

  TextSpan? drawFigure(T value, int precision, KChartColors chartColors);

  void drawChart(
    T lastPoint,
    T curPoint,
    double lastX,
    double curX,
    GetYFunction getY,
    Canvas canvas,
    KChartColors chartColors,
  );

  void calc(List<KLineEntity> dataList);

  /// text format
  TextStyle getTextStyle(Color? color) {
    return TextStyle(fontSize: 10, color: color);
  }

  String formatNumber(double value, int precision) {
    return NumberUtil.format(value, precision) ?? '--';
  }
}

abstract class MainIndicator<T, K> extends IndicatorTemplate<T, K> {
  MainIndicator({
    required super.name,
    required super.shortName,
    required super.calcParams,
    required super.indicatorStyle,
  });
}

abstract class SecondaryIndicator<T, K> extends IndicatorTemplate<T, K> {
  SecondaryIndicator({
    required super.name,
    required super.shortName,
    required super.calcParams,
    required super.indicatorStyle,
  });

  /// Draws the maximum and minimum value labels at the top right and bottom
  /// right of [chartRect]. Subclasses with special labeling needs (KDJ, CCI)
  /// override this.
  void drawVerticalText({
    required Canvas canvas,
    required TextStyle style,
    required double maxValue,
    required double minValue,
    required int fixedLength,
    required Rect chartRect,
  }) {
    final TextPainter maxTp = TextPainter(
      text: TextSpan(
        text: NumberUtil.formatFixed(maxValue, fixedLength) ?? '',
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    maxTp.layout();
    maxTp.paint(canvas, Offset(chartRect.width - maxTp.width, chartRect.top));
    maxTp.dispose();

    final TextPainter minTp = TextPainter(
      text: TextSpan(
        text: NumberUtil.formatFixed(minValue, fixedLength) ?? '',
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    minTp.layout();
    minTp.paint(
      canvas,
      Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height),
    );
    minTp.dispose();
  }
}
