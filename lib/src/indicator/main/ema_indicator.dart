import 'dart:math';

import 'package:clean_k_chart/src/entity/candle_entity.dart';
import 'package:clean_k_chart/src/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/indicator/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator_template.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:flutter/painting.dart';

class EMAIndicator extends MainIndicator<CandleEntity, MAStyle> {
  late final Paint _linePaint;

  EMAIndicator({
    super.calcParams = const [5, 10, 30, 60],
    MAStyle indicatorStyle = const MAStyle(),
  }) : super(
         name: 'exponentialMovingAverage',
         shortName: 'EMA',
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
    if (entity.emaValueList?.isEmpty ?? true) {
      return (minV, maxV);
    }

    double minValue = minV;
    double maxValue = maxV;

    for (double value in entity.emaValueList!) {
      if (value == 0) {
        continue;
      }

      minValue = min(value, minValue);
      maxValue = max(value, maxValue);
    }

    return (minValue, maxValue);
  }

  @override
  TextSpan? drawFigure(
    CandleEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    if (entity.emaValueList?.isEmpty ?? true) {
      return null;
    }

    final List<InlineSpan> result = [];

    for (int i = 0; i < entity.emaValueList!.length; i++) {
      if (entity.emaValueList![i] != 0) {
        result.add(
          TextSpan(
            text:
                "EMA${calcParams[i]}:${formatNumber(entity.emaValueList![i], precision)}  ",
            style: TextStyle(fontSize: 10, color: indicatorStyle.getMAColor(i)),
          ),
        );
      }
    }

    return TextSpan(children: result);
  }

  @override
  void drawChart(
    CandleEntity lastPoint,
    CandleEntity curPoint,
    double lastX,
    double curX,
    GetYFunction getY,
    Canvas canvas,
    KChartColors chartColors,
  ) {
    if (curPoint.emaValueList == null ||
        lastPoint.emaValueList == null ||
        curPoint.emaValueList!.length != lastPoint.emaValueList!.length) {
      return;
    }

    for (int i = 0; i < curPoint.emaValueList!.length; i++) {
      final double lastValue = lastPoint.emaValueList![i];
      final double curValue = curPoint.emaValueList![i];

      // 0 is the warm-up sentinel: skip the segment when either side is missing.
      if (lastValue == 0 || curValue == 0) {
        continue;
      }

      canvas.drawLine(
        Offset(curX, getY(curValue)),
        Offset(lastX, getY(lastValue)),
        _linePaint..color = indicatorStyle.getMAColor(i),
      );
    }
  }

  @override
  void calc(List<KLineEntity> dataList) {
    final List<double> emaValues = List<double>.filled(calcParams.length, 0);

    for (int i = 0; i < dataList.length; i++) {
      final KLineEntity entity = dataList[i];
      final List<double> ema = List<double>.filled(calcParams.length, 0);

      for (int j = 0; j < calcParams.length; ++j) {
        final p = calcParams[j];
        final double multiplier = 2 / (p + 1);

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
