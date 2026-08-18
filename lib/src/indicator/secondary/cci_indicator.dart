import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/indicator/indicator_util.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

/// Commodity channel index.
///
/// Params: `[period]` (defaults to `[90]`).
class CCIIndicator extends SecondaryIndicator {
  CCIIndicator({super.calcParams = const [90]})
    : assert(calcParams.isNotEmpty),
      super(name: 'commodityChannelIndex', shortName: 'CCI');

  @override
  (double, double) getMaxMinValue(KLineEntity entity, double min, double max) {
    return extendRange(min, max, entity.cci);
  }

  @override
  void calc(List<KLineEntity> data) {
    final period = calcParams.first;
    final p = period - 1;
    var tpSum = 0.0;
    final tpList = <double>[];

    for (var i = 0; i < data.length; i++) {
      final entity = data[i];
      entity.cci = null;
      final tp = (entity.high + entity.low + entity.close) / 3;
      tpSum += tp;
      tpList.add(tp);
      if (i >= p) {
        final maTp = tpSum / period;
        var sum = 0.0;
        for (var j = i - p; j <= i; j++) {
          sum += (tpList[j] - maTp).abs();
        }
        final md = sum / period;
        entity.cci = md != 0 ? (tp - maTp) / md / 0.015 : 0;
        final agoEntity = data[i - p];
        tpSum -= (agoEntity.high + agoEntity.low + agoEntity.close) / 3;
      }
    }
  }
}
