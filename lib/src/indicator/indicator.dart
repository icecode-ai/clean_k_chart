import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

/// Pure calculation contract for chart indicators.
///
/// Implementations must not depend on Flutter rendering — painting logic
/// lives in the matching [IndicatorPainter] under render/view/.
abstract class Indicator {
  final String name;

  final String shortName;

  /// Calculation periods; meaning depends on the concrete indicator.
  /// Copied into an unmodifiable list on construction.
  final List<int> calcParams;

  Indicator({
    required this.name,
    required this.shortName,
    required List<int> calcParams,
  }) : calcParams = List.unmodifiable(calcParams);

  /// Extends the running (min, max) range with this indicator's value
  /// on [entity]. Returns the updated record (min, max).
  (double, double) getMaxMinValue(KLineEntity entity, double min, double max);

  /// Computes this indicator over [data], writing results into the
  /// entities' indicator value slots. Must tolerate an empty list.
  void calc(List<KLineEntity> data);

  @override
  String toString() => shortName;
}

/// Indicator drawn over the main (candlestick) chart, e.g. MA, EMA, BOLL, SAR.
abstract class MainIndicator extends Indicator {
  MainIndicator({
    required super.name,
    required super.shortName,
    required super.calcParams,
  });
}

/// Indicator drawn in its own panel below the main chart,
/// e.g. MACD, KDJ, RSI, WR, CCI.
abstract class SecondaryIndicator extends Indicator {
  SecondaryIndicator({
    required super.name,
    required super.shortName,
    required super.calcParams,
  });
}
