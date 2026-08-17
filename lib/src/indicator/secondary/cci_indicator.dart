import 'dart:math';

import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/model/entity/macd_entity.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator.dart';

class CCIIndicator extends SecondaryIndicator<MACDEntity, CCIStyle> {
  CCIIndicator({super.indicatorStyle = const CCIStyle()})
    : super(
        name: 'commodityChannelIndex',
        shortName: 'CCI',
        calcParams: const [90],
      );

  @override
  (double, double) getMaxMinValue(
    KLineEntity entity,
    double minV,
    double maxV,
  ) {
    if (entity.cci != null) {
      minV = min(minV, entity.cci!);
      maxV = max(maxV, entity.cci!);
    }
    return (minV, maxV);
  }

  @override
  void calc(List<KLineEntity> dataList) {
    final periods = calcParams.first;
    final p = periods - 1;
    double tpSum = 0;
    final tpList = [];
    for (int i = 0; i < dataList.length; i++) {
      final kline = dataList[i];
      kline.cci = null;
      final tp = (kline.high + kline.low + kline.close) / 3;
      tpSum += tp;
      tpList.add(tp);
      if (i >= p) {
        final maTp = tpSum / periods;
        final sliceTpList = tpList.sublist(i - p, i + 1);
        final sum = sliceTpList.fold(0.0, (s, tp) {
          s += (tp - maTp).abs();
          return s;
        });
        final md = sum / periods;
        kline.cci = md != 0 ? ((tp - maTp) / md / 0.015) : 0;
        final agoTp =
            (dataList[i - p].high +
                dataList[i - p].low +
                dataList[i - p].close) /
            3;
        tpSum -= agoTp;
      }
    }
  }
}
