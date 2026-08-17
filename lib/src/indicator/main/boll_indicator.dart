import 'dart:math';

import 'package:clean_k_chart/src/model/entity/boll_entity.dart';
import 'package:clean_k_chart/src/model/entity/candle_entity.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator.dart';

class BOLLIndicator extends MainIndicator<CandleEntity, BOLLStyle> {
  BOLLIndicator({super.indicatorStyle = const BOLLStyle()})
    : super(
        name: 'bollingerBands',
        shortName: 'BOLL',
        calcParams: const [20, 2],
      );

  @override
  (double, double) getMaxMinValue(
    KLineEntity entity,
    double minV,
    double maxV,
  ) {
    if (entity.boll == null) return (minV, maxV);
    double minValue = minV;
    if (entity.boll!.dn != null) {
      minValue = min(minValue, entity.boll!.dn!);
    }
    double maxValue = maxV;
    if (entity.boll!.up != null) {
      maxValue = max(maxValue, entity.boll!.up!);
    }
    return (minValue, maxValue);
  }

  @override
  void calc(List<KLineEntity> dataList) {
    int n = calcParams[0];
    int k = calcParams[1];
    _calcBOLLMA(n, dataList);
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      if (i >= n) {
        double md = 0;
        for (int j = i - n + 1; j <= i; j++) {
          double c = dataList[j].close;
          double m = entity.boll!.BOLLMA!;
          double value = c - m;
          md += value * value;
        }
        md = md / (n - 1);
        md = sqrt(md);
        entity.boll!.mid = entity.boll!.BOLLMA!;
        entity.boll!.up = entity.boll!.mid! + k * md;
        entity.boll!.dn = entity.boll!.mid! - k * md;
      }
    }
  }

  void _calcBOLLMA(int day, List<KLineEntity> dataList) {
    double ma = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      ma += entity.close;
      entity.boll = Boll();
      if (i == day - 1) {
        entity.boll!.BOLLMA = ma / day;
      } else if (i >= day) {
        ma -= dataList[i - day].close;
        entity.boll!.BOLLMA = ma / day;
      } else {
        entity.boll!.BOLLMA = null;
      }
    }
  }
}
