import 'dart:math';

import 'package:clean_k_chart/src/entity/candle_entity.dart';
import 'package:clean_k_chart/src/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/indicator/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator_template.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:flutter/painting.dart';

class SARIndicator extends MainIndicator<CandleEntity, SARStyle> {
  late final Paint _dotPaint;

  SARIndicator({SARStyle indicatorStyle = const SARStyle()})
    : super(
        name: 'stopAndReverse',
        shortName: 'SAR',
        calcParams: const [2, 2, 20],
        indicatorStyle: indicatorStyle,
      ) {
    _dotPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..style = PaintingStyle.stroke
      ..strokeWidth = indicatorStyle.strokeWidth;
  }

  @override
  (double, double) getMaxMinValue(
    KLineEntity entity,
    double minV,
    double maxV,
  ) {
    if (entity.sar == null) {
      return (minV, maxV);
    }

    return (min(entity.sar!, minV), max(entity.sar!, maxV));
  }

  @override
  TextSpan? drawFigure(
    CandleEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    final double? value = entity.sar;
    if (value == null) {
      return null;
    }

    return TextSpan(
      text: "SAR: ${formatNumber(value, precision)}",
      style: TextStyle(fontSize: 10, color: indicatorStyle.sarColor),
    );
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
    final sar = curPoint.sar;
    if (sar == null) {
      return;
    }

    // SAR below price acts as support (uptrend), above price as resistance.
    late final Color color;
    if (sar < curPoint.close) {
      color = chartColors.upColor;
    } else if (sar > curPoint.close) {
      color = chartColors.dnColor;
    } else {
      color = chartColors.defaultTextColor;
    }

    canvas.drawCircle(
      Offset(curX, getY(sar)),
      indicatorStyle.radius,
      _dotPaint..color = color,
    );
  }

  /// Params are expressed in percent: [startAf, stepAf, maxAf] as 2/2/20 means
  /// 0.02 / 0.02 / 0.20.
  @override
  void calc(List<KLineEntity> dataList) {
    final double startAf = _percentParam(0, 2);
    final double stepAf = _percentParam(1, 2);
    final double maxAf = _percentParam(2, 20);

    if (dataList.isEmpty) {
      return;
    }

    // Seed the trend direction with the first two closes.
    bool isIncreasing =
        dataList.length < 2 || dataList[1].close >= dataList[0].close;

    // Acceleration factor.
    double af = startAf;
    // Extreme point of the current trend.
    double? ep;
    double sar = isIncreasing ? dataList.first.low : dataList.first.high;

    for (int i = 0; i < dataList.length; ++i) {
      final double high = dataList[i].high;
      final double low = dataList[i].low;

      if (i == 0) {
        ep = isIncreasing ? high : low;
      } else {
        sar = sar + af * (ep! - sar);

        if (isIncreasing) {
          // SAR must not rise above the lows of the previous two periods.
          final double priorLow = _lowestLow(dataList, i);
          if (sar > priorLow) {
            sar = priorLow;
          }

          if (low < sar) {
            // Trend reversed: prior extreme point becomes the new SAR.
            isIncreasing = false;
            sar = ep;
            ep = low;
            af = startAf;
          } else if (high > ep) {
            ep = high;
            af = min(af + stepAf, maxAf);
          }
        } else {
          // SAR must not fall below the highs of the previous two periods.
          final double priorHigh = _highestHigh(dataList, i);
          if (sar < priorHigh) {
            sar = priorHigh;
          }

          if (high > sar) {
            // Trend reversed: prior extreme point becomes the new SAR.
            isIncreasing = true;
            sar = ep;
            ep = high;
            af = startAf;
          } else if (low < ep) {
            ep = low;
            af = min(af + stepAf, maxAf);
          }
        }
      }

      dataList[i].sar = sar;
    }
  }

  double _percentParam(int index, int fallback) {
    final int raw = calcParams.length > index ? calcParams[index] : fallback;
    return raw / 100;
  }

  double _lowestLow(List<KLineEntity> dataList, int i) {
    final int start = max(0, i - 2);
    double result = dataList[start].low;
    for (int j = start + 1; j < i; j++) {
      result = min(result, dataList[j].low);
    }
    return result;
  }

  double _highestHigh(List<KLineEntity> dataList, int i) {
    final int start = max(0, i - 2);

    double result = dataList[start].high;
    for (int j = start + 1; j < i; j++) {
      result = max(result, dataList[j].high);
    }

    return result;
  }
}
