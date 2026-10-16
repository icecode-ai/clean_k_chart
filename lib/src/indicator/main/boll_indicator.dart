import 'dart:math';

import 'package:clean_k_chart/src/entity/boll_entity.dart';
import 'package:clean_k_chart/src/entity/candle_entity.dart';
import 'package:clean_k_chart/src/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/indicator/indicator_style.dart';
import 'package:clean_k_chart/src/indicator/indicator_template.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:flutter/painting.dart';

class BOLLIndicator extends MainIndicator<CandleEntity, BOLLStyle> {
  late final Paint _linePaint;
  late final Paint _fillPaint;

  BOLLIndicator({
    super.calcParams = const [20, 2],
    BOLLStyle indicatorStyle = const BOLLStyle(),
  }) : super(
         name: 'bollingerBands',
         shortName: 'BOLL',
         indicatorStyle: indicatorStyle,
       ) {
    _linePaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = indicatorStyle.lineWidth;

    _fillPaint = Paint()..color = indicatorStyle.fillColor;
  }

  @override
  (double, double) getMaxMinValue(
    KLineEntity entity,
    double minV,
    double maxV,
  ) {
    if (entity.boll == null) {
      return (minV, maxV);
    }

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
  TextSpan? drawFigure(
    CandleEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    if (entity.boll == null) {
      return null;
    }

    final BollEntity value = entity.boll!;

    return TextSpan(
      children: [
        if (value.mid != null && value.mid != 0)
          TextSpan(
            text: "BOLL:${formatNumber(value.mid!, precision)}  ",
            style: TextStyle(fontSize: 10, color: indicatorStyle.bollColor),
          ),
        if (value.up != null && value.up != 0)
          TextSpan(
            text: "UB:${formatNumber(value.up!, precision)}  ",
            style: TextStyle(fontSize: 10, color: indicatorStyle.ubColor),
          ),
        if (value.dn != null && value.dn != 0)
          TextSpan(
            text: "LB:${formatNumber(value.dn!, precision)}",
            style: TextStyle(fontSize: 10, color: indicatorStyle.lbColor),
          ),
      ],
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
    if (lastPoint.boll == null || curPoint.boll == null) {
      return;
    }

    final List<Offset> positions = [];

    if (curPoint.boll!.up != null && lastPoint.boll!.up != null) {
      positions.add(Offset(curX, getY(curPoint.boll!.up!)));
      positions.add(Offset(lastX, getY(lastPoint.boll!.up!)));

      /// UB
      canvas.drawLine(
        positions[0],
        positions[1],
        _linePaint..color = indicatorStyle.ubColor,
      );
    }

    if (curPoint.boll!.dn != null && lastPoint.boll!.dn != null) {
      positions.add(Offset(lastX, getY(lastPoint.boll!.dn!)));
      positions.add(Offset(curX, getY(curPoint.boll!.dn!)));

      /// LB
      canvas.drawLine(
        positions[2],
        positions[3],
        _linePaint..color = indicatorStyle.lbColor,
      );
    }

    if (positions.length == 4) {
      final Path fillPath = Path()
        ..moveTo(positions[0].dx, positions[0].dy)
        ..lineTo(positions[1].dx, positions[1].dy)
        ..lineTo(positions[2].dx, positions[2].dy)
        ..lineTo(positions[3].dx, positions[3].dy)
        ..close();

      canvas.drawPath(fillPath, _fillPaint);
    }

    if (curPoint.boll!.mid != null && lastPoint.boll!.mid != null) {
      /// BOLL
      canvas.drawLine(
        Offset(curX, getY(curPoint.boll!.mid!)),
        Offset(lastX, getY(lastPoint.boll!.mid!)),
        _linePaint..color = indicatorStyle.bollColor,
      );
    }
  }

  /// Params: [period, deviation] e.g. [20, 2] means a 20-period SMA with the
  /// bands placed `2` population standard deviations from it.
  @override
  void calc(List<KLineEntity> dataList) {
    final int n = calcParams.isNotEmpty ? calcParams[0] : 20;
    final double k = (calcParams.length > 1 ? calcParams[1] : 2).toDouble();

    if (n <= 0 || dataList.isEmpty) {
      return;
    }

    double closeSum = 0;
    double closeSquareSum = 0;

    for (int i = 0; i < dataList.length; i++) {
      final double close = dataList[i].close;
      closeSum += close;
      closeSquareSum += close * close;

      if (i < n - 1) {
        continue;
      }

      if (i >= n) {
        final double ago = dataList[i - n].close;
        closeSum -= ago;
        closeSquareSum -= ago * ago;
      }

      final double ma = closeSum / n;

      // Population standard deviation of the closes in the window. The rolling
      // sums keep this O(n) overall; clamp against tiny negative values caused
      // by floating point cancellation.
      final double variance = closeSquareSum / n - ma * ma;
      final double md = variance > 0 ? sqrt(variance) : 0;

      final boll = dataList[i].boll = BollEntity();
      boll.bollMa = ma;
      boll.mid = ma;
      boll.up = ma + k * md;
      boll.dn = ma - k * md;
    }
  }
}
