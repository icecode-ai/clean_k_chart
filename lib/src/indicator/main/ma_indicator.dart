import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/indicator/indicator_util.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

/// Simple moving average over the close price, one line per period.
class MAIndicator extends MainIndicator {
  MAIndicator({super.calcParams = const [5, 10, 20, 25, 60]})
    : assert(calcParams.isNotEmpty),
      super(name: 'movingAverage', shortName: 'MA');

  @override
  (double, double) getMaxMinValue(KLineEntity entity, double min, double max) {
    return extendRangeAll(min, max, entity.maValues);
  }

  @override
  void calc(List<KLineEntity> data) {
    if (data.isEmpty) return;
    final sums = List<double>.filled(calcParams.length, 0);
    for (var i = 0; i < data.length; i++) {
      final entity = data[i];
      final values = List<double?>.filled(calcParams.length, null);
      for (var j = 0; j < calcParams.length; j++) {
        final period = calcParams[j];
        if (period <= 0) continue;
        sums[j] += entity.close;
        if (i >= period - 1) {
          if (i >= period) {
            sums[j] -= data[i - period].close;
          }
          values[j] = sums[j] / period;
        }
      }
      entity.maValues = values;
    }
  }
}
