import 'dart:math' as math;

import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/model/entity/boll_entity.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

/// Bollinger bands.
///
/// Params: `[n, k]` — `n` is the MA window, `k` the standard-deviation
/// multiplier (defaults to `[20, 2]`).
class BOLLIndicator extends MainIndicator {
  BOLLIndicator({super.calcParams = const [20, 2]})
    : assert(calcParams.length >= 2),
      super(name: 'bollingerBands', shortName: 'BOLL');

  @override
  (double, double) getMaxMinValue(KLineEntity entity, double min, double max) {
    final boll = entity.boll;
    if (boll == null) return (min, max);
    var result = (min, max);
    if (boll.dn != null) {
      result = (math.min(result.$1, boll.dn!), result.$2);
    }
    if (boll.up != null) {
      result = (result.$1, math.max(result.$2, boll.up!));
    }
    return result;
  }

  @override
  void calc(List<KLineEntity> data) {
    final n = calcParams[0];
    final k = calcParams[1];
    if (n <= 1) return;

    // Sliding-window MA of the close price.
    final ma = List<double?>.filled(data.length, null);
    var sum = 0.0;
    for (var i = 0; i < data.length; i++) {
      sum += data[i].close;
      if (i >= n - 1) {
        if (i >= n) {
          sum -= data[i - n].close;
        }
        ma[i] = sum / n;
      }
    }

    for (var i = 0; i < data.length; i++) {
      final entity = data[i];
      final mid = ma[i];
      if (mid == null) {
        entity.boll = null;
        continue;
      }
      var squaredDiff = 0.0;
      for (var j = i - n + 1; j <= i; j++) {
        final diff = data[j].close - mid;
        squaredDiff += diff * diff;
      }
      final md = math.sqrt(squaredDiff / (n - 1));
      entity.boll = BollValue(mid: mid, up: mid + k * md, dn: mid - k * md);
    }
  }
}
