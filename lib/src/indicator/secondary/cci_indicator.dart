import 'dart:math';

import 'package:clean_k_chart/src/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/entity/macd_entity.dart';
import 'package:clean_k_chart/src/indicator/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator_template.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

class CCIIndicator extends SecondaryIndicator<MACDEntity, CCIStyle> {
  late final Paint _linePaint;

  CCIIndicator({
    super.calcParams = const [20],
    CCIStyle indicatorStyle = const CCIStyle(),
  }) : super(
         name: 'commodityChannelIndex',
         shortName: 'CCI',
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
    if (entity.cci != null) {
      minV = min(minV, entity.cci!);
      maxV = max(maxV, entity.cci!);
    }

    return (minV, maxV);
  }

  @override
  TextSpan? drawFigure(
    MACDEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    if (entity.cci == null) {
      return null;
    }

    return TextSpan(
      text: "CCI(${calcParams.first}):${formatNumber(entity.cci!, precision)}",
      style: getTextStyle(indicatorStyle.cciColor),
    );
  }

  @override
  void drawVerticalText({
    required Canvas canvas,
    required TextStyle style,
    required double maxValue,
    required double minValue,
    required int fixedLength,
    required Rect chartRect,
  }) {
    double jumpStep = maxValue - minValue;

    late int jumpValue;
    if (jumpStep >= 100) {
      jumpValue = 100;
    } else if (jumpStep >= 10) {
      jumpValue = 10;
    } else {
      jumpValue = 1;
    }

    /// max
    TextPainter maxTp = TextPainter(
      text: TextSpan(
        text:
            NumberUtil.formatFixed(
              (maxValue / jumpValue).round() * jumpValue,
              0,
            ) ??
            '',
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    maxTp.layout();
    maxTp.paint(canvas, Offset(chartRect.width - maxTp.width, chartRect.top));
    maxTp.dispose();

    /// min
    TextPainter minTp = TextPainter(
      text: TextSpan(
        text:
            NumberUtil.formatFixed(
              (minValue / jumpValue).round() * jumpValue,
              0,
            ) ??
            '',
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    minTp.layout();
    minTp.paint(
      canvas,
      Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height),
    );
    minTp.dispose();
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
    if (curPoint.cci == null || lastPoint.cci == null) {
      return;
    }

    canvas.drawLine(
      Offset(curX, getY(curPoint.cci!)),
      Offset(lastX, getY(lastPoint.cci!)),
      _linePaint..color = indicatorStyle.cciColor,
    );
  }

  @override
  void calc(List<KLineEntity> dataList) {
    final int periods = calcParams.isNotEmpty ? calcParams.first : 90;
    final int warmUpEnd = periods - 1;

    double tpSum = 0;

    final List<double> tpList = <double>[];

    for (int i = 0; i < dataList.length; i++) {
      final kline = dataList[i];
      kline.cci = null;

      final double tp = (kline.high + kline.low + kline.close) / 3;

      tpSum += tp;
      tpList.add(tp);

      if (i >= warmUpEnd) {
        final double maTp = tpSum / periods;

        // Mean absolute deviation over the current window.
        double absDeviationSum = 0;
        for (int j = i - warmUpEnd; j <= i; j++) {
          absDeviationSum += (tpList[j] - maTp).abs();
        }
        final double md = absDeviationSum / periods;

        kline.cci = md != 0 ? ((tp - maTp) / md) / 0.015 : 0;

        tpSum -= tpList[i - warmUpEnd];
      }
    }
  }
}
