import 'dart:math' as math;

import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/indicator/indicator_util.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

/// Stochastic oscillator KDJ.
///
/// Params: `[n, kPeriod, dPeriod]` (defaults to `[9, 3, 3]`): `n` is the
/// look-back window for RSV, `kPeriod`/`dPeriod` the K/D smoothing periods.
class KDJIndicator extends SecondaryIndicator {
  KDJIndicator({super.calcParams = const [9, 3, 3]})
    : assert(calcParams.length >= 3),
      super(name: 'stochasticOscillator', shortName: 'KDJ');

  @override
  (double, double) getMaxMinValue(KLineEntity entity, double min, double max) {
    var result = extendRange(min, max, entity.k);
    result = extendRange(result.$1, result.$2, entity.d);
    result = extendRange(result.$1, result.$2, entity.j);
    return result;
  }

  @override
  void calc(List<KLineEntity> data) {
    if (data.isEmpty) return;
    final n = calcParams[0];
    final kPeriod = calcParams[1];
    final dPeriod = calcParams[2];

    var preK = 50.0;
    var preD = 50.0;
    data.first
      ..k = preK
      ..d = preD
      ..j = 50.0;

    for (var i = 1; i < data.length; i++) {
      final entity = data[i];
      var low = entity.low;
      var high = entity.high;
      for (var j = math.max(0, i - n + 1); j < i; j++) {
        low = math.min(low, data[j].low);
        high = math.max(high, data[j].high);
      }
      var rsv = (entity.close - low) * 100.0 / (high - low);
      if (rsv.isNaN) rsv = 0;
      final k = ((kPeriod - 1) * preK + rsv) / kPeriod;
      final d = ((dPeriod - 1) * preD + k) / dPeriod;
      final j = 3 * k - 2 * d;
      preK = k;
      preD = d;
      entity
        ..k = k
        ..d = d
        ..j = j;
    }
  }
}
