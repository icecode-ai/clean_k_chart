import 'dart:math';

import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/model/entity/macd_entity.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator.dart';

/**
 * MACD：参数快线移动平均、慢线移动平均、移动平均，
 * 默认参数值12、26、9。
 * 公式：⒈首先分别计算出收盘价12日指数平滑移动平均线与26日指数平滑移动平均线，分别记为EMA(12）与EMA(26）。
 * ⒉求这两条指数平滑移动平均线的差，即：DIFF = EMA(SHORT) － EMA(LONG)。
 * ⒊再计算DIFF的M日的平均的指数平滑移动平均线，记为DEA。
 * ⒋最后用DIFF减DEA，得MACD。MACD通常绘制成围绕零轴线波动的柱形图。MACD柱状大于0涨颜色，小于0跌颜色。
 */
class MACDIndicator extends SecondaryIndicator<MACDEntity, MACDStyle> {
  MACDIndicator({super.indicatorStyle = const MACDStyle()})
    : super(
        name: 'movingAverageConvergenceDivergence',
        shortName: 'MACD',
        calcParams: const [12, 26, 9],
      );

  @override
  (double, double) getMaxMinValue(
    KLineEntity entity,
    double minV,
    double maxV,
  ) {
    if (entity.macd != null) {
      minV = min(minV, entity.macd!);
      maxV = max(maxV, entity.macd!);
    }
    if (entity.dea != null) {
      minV = min(minV, entity.dea!);
      maxV = max(maxV, entity.dea!);
    }
    if (entity.dif != null) {
      minV = min(minV, entity.dif!);
      maxV = max(maxV, entity.dif!);
    }
    return (minV, maxV);
  }

  @override
  void calc(List<KLineEntity> dataList) {
    final params = calcParams;
    double closeSum = 0;
    double emaShort = 0;
    double emaLong = 0;
    double dif = 0;
    double difSum = 0;
    double dea = 0;
    final maxPeriod = max(params[0], params[1]);

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final close = entity.close;
      closeSum += close;
      if (i >= params[0] - 1) {
        if (i > params[0] - 1) {
          emaShort = (2 * close + (params[0] - 1) * emaShort) / (params[0] + 1);
        } else {
          emaShort = closeSum / params[0];
        }
      }

      if (i >= params[1] - 1) {
        if (i > params[1] - 1) {
          emaLong = (2 * close + (params[1] - 1) * emaLong) / (params[1] + 1);
        } else {
          emaLong = closeSum / params[1];
        }
      }
      if (i >= maxPeriod - 1) {
        dif = emaShort - emaLong;
        entity.dif = dif;
        difSum += dif;
        if (i >= maxPeriod + params[2] - 2) {
          if (i > maxPeriod + params[2] - 2) {
            dea = (dif * 2 + dea * (params[2] - 1)) / (params[2] + 1);
          } else {
            dea = difSum / params[2];
          }
          entity.macd = (dif - dea) * 2;
          entity.dea = dea;
        }
      }
    }
  }
}
