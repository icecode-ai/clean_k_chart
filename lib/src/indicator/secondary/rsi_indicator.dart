import 'dart:math';

import 'package:clean_k_chart/src/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/entity/macd_entity.dart';
import 'package:clean_k_chart/src/indicator/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator_template.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:flutter/painting.dart';

class RSIIndicator extends SecondaryIndicator<MACDEntity, RSIStyle> {
  late final Paint _linePaint;

  RSIIndicator({
    super.calcParams = const [14],
    RSIStyle indicatorStyle = const RSIStyle(),
  }) : super(
         name: 'relativeStrengthIndex',
         shortName: 'RSI',
         indicatorStyle: indicatorStyle,
       ) {
    _linePaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = indicatorStyle.lineWidth;
  }

  @override
  (double, double) getMaxMinValue(
    KLineEntity entity,
    double minV,
    double maxV,
  ) {
    if (entity.rsi != null) {
      minV = min(minV, entity.rsi!);
      maxV = max(maxV, entity.rsi!);
    }

    return (minV, maxV);
  }

  @override
  TextSpan? drawFigure(
    MACDEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    if (entity.rsi == null) {
      return null;
    }

    return TextSpan(
      text: "RSI(${calcParams.first}):${formatNumber(entity.rsi!, precision)}",
      style: getTextStyle(indicatorStyle.rsiColor),
    );
  }

  @override
  void drawChart(
    MACDEntity lastPoint,
    MACDEntity curPoint,
    double lastX,
    double curX,
    GetYFunction getY,
    Canvas canvas,
    KChartColors chartColors,
  ) {
    if (curPoint.rsi == null || lastPoint.rsi == null) {
      return;
    }

    canvas.drawLine(
      Offset(curX, getY(curPoint.rsi!)),
      Offset(lastX, getY(lastPoint.rsi!)),
      _linePaint..color = indicatorStyle.rsiColor,
    );
  }

  @override
  void calc(List<KLineEntity> dataList) {
    final int period = calcParams.isNotEmpty ? calcParams.first : 14;

    double avgGain = 0;
    double avgLoss = 0;

    for (int i = 0; i < dataList.length; i++) {
      final KLineEntity entity = dataList[i];

      if (i == 0) {
        entity.rsi = null;
        continue;
      }

      final double change = entity.close - dataList[i - 1].close;
      final double gain = max(change, 0);
      final double loss = max(-change, 0);

      // Wilder smoothing: seed the averages with the SMA of the first
      // `period` changes, then recurse with the standard smoothing factor.
      if (i < period) {
        avgGain += gain;
        avgLoss += loss;
        entity.rsi = null;
        continue;
      }

      if (i == period) {
        avgGain = (avgGain + gain) / period;
        avgLoss = (avgLoss + loss) / period;
      } else {
        avgGain = (avgGain * (period - 1) + gain) / period;
        avgLoss = (avgLoss * (period - 1) + loss) / period;
      }

      double rsi;
      if (avgGain == 0 && avgLoss == 0) {
        rsi = 50;
      } else if (avgLoss == 0) {
        rsi = 100;
      } else {
        rsi = 100 - 100 / (1 + avgGain / avgLoss);
      }

      entity.rsi = rsi.isNaN ? null : rsi;
    }
  }
}
