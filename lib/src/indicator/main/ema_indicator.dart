import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/indicator/indicator_util.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

/// Exponential moving average over the close price, one line per period.
///
/// Formula: `EMA = (close − previous EMA) · 2 / (period + 1) + previous EMA`,
/// seeded with the first close price.
class EMAIndicator extends MainIndicator {
  EMAIndicator({super.calcParams = const [5, 10, 30, 60]})
    : assert(calcParams.isNotEmpty),
      super(name: 'exponentialMovingAverage', shortName: 'EMA');

  @override
  (double, double) getMaxMinValue(KLineEntity entity, double min, double max) {
    return extendRangeAll(min, max, entity.emaValues);
  }

  @override
  void calc(List<KLineEntity> data) {
    final smoothed = List<double>.filled(calcParams.length, 0);
    for (var i = 0; i < data.length; i++) {
      final entity = data[i];
      final values = List<double>.filled(calcParams.length, 0);
      for (var j = 0; j < calcParams.length; j++) {
        final period = calcParams[j];
        if (period <= 0) continue;
        if (i == 0) {
          smoothed[j] = entity.close;
        } else {
          smoothed[j] = emaSmooth(entity.close, smoothed[j], period);
        }
        values[j] = smoothed[j];
      }
      entity.emaValues = values;
    }
  }
}
