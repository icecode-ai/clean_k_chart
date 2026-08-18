import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/indicator/indicator_util.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

/// MACD.
///
/// Params: `[short, long, signal]` (defaults to `[12, 26, 9]`).
///
/// - DIFF = EMA(short) − EMA(long)
/// - DEA = EMA(signal) of DIFF
/// - MACD = (DIFF − DEA) × 2
class MACDIndicator extends SecondaryIndicator {
  MACDIndicator({super.calcParams = const [12, 26, 9]})
    : assert(calcParams.length >= 3),
      super(name: 'movingAverageConvergenceDivergence', shortName: 'MACD');

  @override
  (double, double) getMaxMinValue(KLineEntity entity, double min, double max) {
    var result = extendRange(min, max, entity.macd);
    result = extendRange(result.$1, result.$2, entity.dea);
    result = extendRange(result.$1, result.$2, entity.dif);
    return result;
  }

  @override
  void calc(List<KLineEntity> data) {
    final short = calcParams[0];
    final long = calcParams[1];
    final signal = calcParams[2];
    final maxPeriod = short > long ? short : long;

    var closeSum = 0.0;
    var emaShort = 0.0;
    var emaLong = 0.0;
    var difSum = 0.0;
    var dea = 0.0;

    for (var i = 0; i < data.length; i++) {
      final entity = data[i];
      entity.dif = null;
      entity.dea = null;
      entity.macd = null;

      final close = entity.close;
      closeSum += close;
      if (i >= short - 1) {
        emaShort = i > short - 1
            ? emaSmooth(close, emaShort, short)
            : closeSum / short;
      }
      if (i >= long - 1) {
        emaLong = i > long - 1
            ? emaSmooth(close, emaLong, long)
            : closeSum / long;
      }
      if (i >= maxPeriod - 1) {
        final dif = emaShort - emaLong;
        entity.dif = dif;
        difSum += dif;
        final deaStart = maxPeriod + signal - 2;
        if (i >= deaStart) {
          dea = i > deaStart ? emaSmooth(dif, dea, signal) : difSum / signal;
          entity.macd = (dif - dea) * 2;
          entity.dea = dea;
        }
      }
    }
  }
}
