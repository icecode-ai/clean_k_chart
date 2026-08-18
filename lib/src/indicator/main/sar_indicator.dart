import 'dart:math' as math;

import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/indicator/indicator_util.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

/// Parabolic SAR (stop and reverse).
///
/// Params: `[afStart, afStep, afMax]` in percent (defaults to
/// `[2, 2, 20]`, i.e. 0.02 / 0.02 / 0.2).
class SARIndicator extends MainIndicator {
  SARIndicator({super.calcParams = const [2, 2, 20]})
    : assert(calcParams.length >= 3),
      super(name: 'stopAndReverse', shortName: 'SAR');

  @override
  (double, double) getMaxMinValue(KLineEntity entity, double min, double max) {
    return extendRange(min, max, entity.sar);
  }

  @override
  void calc(List<KLineEntity> data) {
    final startAf = calcParams[0] / 100;
    final step = calcParams[1] / 100;
    final maxAf = calcParams[2] / 100;

    // Acceleration factor.
    var af = startAf;
    // Extreme point of the current trend; null until first observed.
    double? ep;
    // false: downtrend, true: uptrend.
    var isIncreasing = false;
    var sar = 0.0;

    for (var i = 0; i < data.length; i++) {
      final preSar = sar;
      final high = data[i].high;
      final low = data[i].low;

      if (isIncreasing) {
        if (ep == null || ep < high) {
          ep = high;
          af = math.min(af + step, maxAf);
        }
        sar = preSar + af * (ep - preSar);
        final lowMin = math.min(data[math.max(1, i) - 1].low, low);
        if (sar > low) {
          // Trend reversed to down.
          sar = ep;
          af = startAf;
          ep = null;
          isIncreasing = false;
        } else if (sar > lowMin) {
          sar = lowMin;
        }
      } else {
        if (ep == null || ep > low) {
          ep = low;
          af = math.min(af + step, maxAf);
        }
        sar = preSar + af * (ep - preSar);
        final highMax = math.max(data[math.max(1, i) - 1].high, high);
        if (sar < high) {
          // Trend reversed to up.
          sar = ep;
          af = startAf;
          ep = null;
          isIncreasing = true;
        } else if (sar < highMax) {
          sar = highMax;
        }
      }

      data[i].sar = sar;
    }
  }
}
