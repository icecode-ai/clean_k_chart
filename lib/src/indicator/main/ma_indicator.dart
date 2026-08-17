import 'dart:math';

import 'package:clean_k_chart/src/model/entity/candle_entity.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator.dart';

class MAIndicator extends MainIndicator<CandleEntity, MAStyle> {
  MAIndicator({
    super.calcParams = const [5, 10, 20, 25, 60],
    super.indicatorStyle = const MAStyle(),
  }) : super(name: 'movingAverage', shortName: 'MA');

  @override
  (double, double) getMaxMinValue(
    KLineEntity entity,
    double minV,
    double maxV,
  ) {
    if (entity.maValueList?.isEmpty ?? true) return (minV, maxV);
    double minValue = minV;
    double maxValue = maxV;
    for (double value in entity.maValueList!) {
      if (value == 0) continue;
      minValue = min(value, minValue);
      maxValue = max(value, maxValue);
    }
    return (minValue, maxValue);
  }

  @override
  void calc(List<KLineEntity> dataList) {
    List<double> ma = List<double>.filled(calcParams.length, 0);
    if (dataList.isNotEmpty) {
      for (int i = 0; i < dataList.length; i++) {
        KLineEntity entity = dataList[i];
        final closePrice = entity.close;
        entity.maValueList = List<double>.filled(calcParams.length, 0);

        for (int j = 0; j < calcParams.length; j++) {
          ma[j] += closePrice;
          if (i == calcParams[j] - 1) {
            entity.maValueList?[j] = ma[j] / calcParams[j];
          } else if (i >= calcParams[j]) {
            ma[j] -= dataList[i - calcParams[j]].close;
            entity.maValueList?[j] = ma[j] / calcParams[j];
          }
        }
      }
    }
  }
}
