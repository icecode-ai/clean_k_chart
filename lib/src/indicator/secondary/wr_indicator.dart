import 'dart:math';

import 'package:clean_k_chart/src/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/entity/macd_entity.dart';
import 'package:clean_k_chart/src/indicator/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator_template.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:flutter/painting.dart';

class WRIndicator extends SecondaryIndicator<MACDEntity, WRStyle> {
  late final Paint _linePaint;

  WRIndicator({
    super.calcParams = const [14],
    WRStyle indicatorStyle = const WRStyle(),
  }) : super(
         name: 'williamsRate',
         shortName: 'WR',
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
    return (-100, 0);
  }

  @override
  TextSpan? drawFigure(
    MACDEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    if (entity.r == null) {
      return null;
    }

    return TextSpan(
      text: "WR(${calcParams.first}):${formatNumber(entity.r!, precision)}",
      style: getTextStyle(indicatorStyle.wrColor),
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
    if (curPoint.r == null || lastPoint.r == null) {
      return;
    }

    canvas.drawLine(
      Offset(curX, getY(curPoint.r!)),
      Offset(lastX, getY(lastPoint.r!)),
      _linePaint..color = indicatorStyle.wrColor,
    );
  }

  @override
  void calc(List<KLineEntity> dataList) {
    final int period = calcParams.isNotEmpty ? calcParams.first : 14;

    for (int i = 0; i < dataList.length; i++) {
      final KLineEntity entity = dataList[i];

      // Warm-up: not enough data for a full window.
      if (i < period - 1) {
        entity.r = null;
        continue;
      }

      double maxHigh = -double.infinity;
      double minLow = double.infinity;

      for (int index = i - period + 1; index <= i; index++) {
        maxHigh = max(maxHigh, dataList[index].high);
        minLow = min(minLow, dataList[index].low);
      }

      final double range = maxHigh - minLow;
      entity.r = range == 0
          ? null
          : -100 * (maxHigh - dataList[i].close) / range;
    }
  }
}
