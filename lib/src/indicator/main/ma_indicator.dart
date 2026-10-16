import 'dart:math';

import 'package:clean_k_chart/src/entity/candle_entity.dart';
import 'package:clean_k_chart/src/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/indicator/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator_template.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:flutter/painting.dart';

class MAIndicator extends MainIndicator<CandleEntity, MAStyle> {
  late final Paint _linePaint;

  MAIndicator({
    super.calcParams = const [5, 10, 20, 25, 60],
    MAStyle indicatorStyle = const MAStyle(),
  }) : super(
         name: 'movingAverage',
         shortName: 'MA',
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
    if (entity.maValueList?.isEmpty ?? true) {
      return (minV, maxV);
    }

    double minValue = minV;
    double maxValue = maxV;

    for (double value in entity.maValueList!) {
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
    if (entity.maValueList?.isEmpty ?? true) {
      return null;
    }

    final List<InlineSpan> result = [];

    for (int i = 0; i < entity.maValueList!.length; i++) {
      if (entity.maValueList![i] != 0) {
        result.add(
          TextSpan(
            text:
                "MA${calcParams[i]}:${formatNumber(entity.maValueList![i], precision)}  ",
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
    if (curPoint.maValueList == null ||
        lastPoint.maValueList == null ||
        curPoint.maValueList!.length != lastPoint.maValueList!.length) {
      return;
    }

    for (int i = 0; i < curPoint.maValueList!.length; i++) {
      final double lastValue = lastPoint.maValueList![i];
      final double curValue = curPoint.maValueList![i];

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
    final List<double> ma = List<double>.filled(calcParams.length, 0);

    if (dataList.isNotEmpty) {
      for (int i = 0; i < dataList.length; i++) {
        final KLineEntity entity = dataList[i];
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
