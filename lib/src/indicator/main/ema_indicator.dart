import 'dart:math';

import 'package:clean_k_chart/src/model/entity/candle_entity.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator.dart';

class EMAIndicator extends MainIndicator<CandleEntity, MAStyle> {
  EMAIndicator({
    super.calcParams = const [5, 10, 30, 60],
    super.indicatorStyle = const MAStyle(),
  }) : super(name: 'exponentialMovingAverage', shortName: 'EMA');

  @override
  (double, double) getMaxMinValue(
    KLineEntity entity,
    double minV,
    double maxV,
  ) {
    if (entity.emaValueList?.isEmpty ?? true) return (minV, maxV);
    double minValue = minV;
    double maxValue = maxV;
    for (double value in entity.emaValueList!) {
      if (value == 0) continue;
      minValue = min(value, minValue);
      maxValue = max(value, maxValue);
    }
    return (minValue, maxValue);
  }

  @override
  void calc(List<KLineEntity> dataList) {
    /// Formula:
    ///   Multiplier = 2 / (period + 1)
    ///   EMA = (Closing Price - Previous EMA) * Multiplier + Previous EMA
    List<double> emaValues = List<double>.filled(calcParams.length, 0);
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      List<double> ema = List<double>.filled(calcParams.length, 0);
      for (int j = 0; j < calcParams.length; ++j) {
        final p = calcParams[j];
        double multiplier = 2 / (p + 1);
        if (i == 0) {
          emaValues[j] = entity.close;
        } else {
          emaValues[j] =
              (entity.close - emaValues[j]) * multiplier + emaValues[j];
        }
        ema[j] = emaValues[j];
      }

      entity.emaValueList = ema;
    }
  }
}
