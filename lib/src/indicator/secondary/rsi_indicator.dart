import 'dart:math' as math;

import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/indicator/indicator_util.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

/// Relative strength index.
///
/// Params: `[period]` (defaults to `[14]`).
///
/// `RSI = WilderEMA(MAX(close − prevClose, 0)) /
/// WilderEMA(|close − prevClose|) × 100`, where
/// `WilderEMA_t = (x_t + (period − 1) · WilderEMA_{t−1}) / period`.
/// Values are null for the first `period − 1` bars (warm-up).
class RSIIndicator extends SecondaryIndicator {
  RSIIndicator({super.calcParams = const [14]})
    : assert(calcParams.isNotEmpty),
      super(name: 'relativeStrengthIndex', shortName: 'RSI');

  @override
  (double, double) getMaxMinValue(KLineEntity entity, double min, double max) {
    return extendRange(min, max, entity.rsi);
  }

  @override
  void calc(List<KLineEntity> data) {
    final period = calcParams.first;
    double? rsi;
    var rsiABSEma = 0.0;
    var rsiMaxEma = 0.0;

    for (var i = 0; i < data.length; i++) {
      final entity = data[i];
      if (i == 0) {
        rsi = 0;
        rsiABSEma = 0;
        rsiMaxEma = 0;
      } else {
        final diff = entity.close - data[i - 1].close;
        final rMax = math.max(0.0, diff);
        final rAbs = diff.abs();
        rsiMaxEma = (rMax + (period - 1) * rsiMaxEma) / period;
        rsiABSEma = (rAbs + (period - 1) * rsiABSEma) / period;
        rsi = rsiMaxEma / rsiABSEma * 100;
      }
      if (i < period - 1) rsi = null;
      if (rsi != null && rsi.isNaN) rsi = null;
      entity.rsi = rsi;
    }
  }
}
