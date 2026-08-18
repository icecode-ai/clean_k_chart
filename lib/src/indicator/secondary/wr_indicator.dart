import 'dart:math' as math;

import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

/// Williams %R.
///
/// Params: `[period]` (defaults to `[14]`).
///
/// `WR = −100 × (highestHigh − close) / (highestHigh − lowestLow)`
/// over the last [period] bars; values are in [-100, 0].
class WRIndicator extends SecondaryIndicator {
  WRIndicator({super.calcParams = const [14]})
    : assert(calcParams.isNotEmpty),
      super(name: 'williamsR', shortName: 'WR');

  @override
  (double, double) getMaxMinValue(KLineEntity entity, double min, double max) {
    return (-100, 0);
  }

  @override
  void calc(List<KLineEntity> data) {
    final period = calcParams.first;
    for (var i = 0; i < data.length; i++) {
      final entity = data[i];
      if (i < period - 1) {
        entity.wr = null;
        continue;
      }
      var highest = -double.infinity;
      var lowest = double.infinity;
      for (var j = i - period + 1; j <= i; j++) {
        highest = math.max(highest, data[j].high);
        lowest = math.min(lowest, data[j].low);
      }
      final wr = -100 * (highest - entity.close) / (highest - lowest);
      entity.wr = wr.isNaN ? null : wr;
    }
  }
}
