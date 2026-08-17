import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';

/// Pure calculation contract for chart indicators.
///
/// Implementations must not depend on Flutter rendering — drawing logic
/// lives in the matching [IndicatorPainter] under render/indicator_view/.
abstract class Indicator<T, K extends IndicatorStyle> {
  final String name;

  final String shortName;

  final List<int> calcParams;

  final K indicatorStyle;

  Indicator({
    required this.name,
    required this.shortName,
    required this.calcParams,
    required this.indicatorStyle,
  });

  /// record.$1 : min value
  /// record.$2: max value
  (double, double) getMaxMinValue(KLineEntity entity, double minV, double maxV);

  void calc(List<KLineEntity> dataList);

  String formatNumber(double value, int precision) {
    return NumberUtil.format(value, precision) ?? '--';
  }
}

/// Indicator drawn over the main (candlestick) chart, e.g. MA, EMA, BOLL, SAR.
abstract class MainIndicator<T, K extends IndicatorStyle>
    extends Indicator<T, K> {
  MainIndicator({
    required super.name,
    required super.shortName,
    required super.calcParams,
    required super.indicatorStyle,
  });
}

/// Indicator drawn in its own panel below the main chart,
/// e.g. MACD, KDJ, RSI, WR, CCI.
abstract class SecondaryIndicator<T, K extends IndicatorStyle>
    extends Indicator<T, K> {
  SecondaryIndicator({
    required super.name,
    required super.shortName,
    required super.calcParams,
    required super.indicatorStyle,
  });
}
