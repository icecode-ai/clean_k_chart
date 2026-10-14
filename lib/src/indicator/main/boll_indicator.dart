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

  BOLLIndicator({BOLLStyle indicatorStyle = const BOLLStyle()})
    : super(
        name: 'bollingerBands',
        shortName: 'BOLL',
        calcParams: const [20, 2],
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

  @override
  void calc(List<KLineEntity> dataList) {
    final int n = calcParams[0];
    final int k = calcParams[1];

    _calcBOLLMA(n, dataList);

    for (int i = 0; i < dataList.length; i++) {
      final KLineEntity entity = dataList[i];

      if (i >= n) {
        double md = 0;

        for (int j = i - n + 1; j <= i; j++) {
          double c = dataList[j].close;
          double m = entity.boll!.bollMa!;
          double value = c - m;
          md += value * value;
        }

        md = md / (n - 1);
        md = sqrt(md);

        entity.boll!.mid = entity.boll!.bollMa!;
        entity.boll!.up = entity.boll!.mid! + k * md;
        entity.boll!.dn = entity.boll!.mid! - k * md;
      }
    }
  }

  void _calcBOLLMA(int day, List<KLineEntity> dataList) {
    double ma = 0;

    for (int i = 0; i < dataList.length; i++) {
      final KLineEntity entity = dataList[i];

      ma += entity.close;
      entity.boll = BollEntity();

      if (i == day - 1) {
        entity.boll!.bollMa = ma / day;
      } else if (i >= day) {
        ma -= dataList[i - day].close;
        entity.boll!.bollMa = ma / day;
      } else {
        entity.boll!.bollMa = null;
      }
    }
  }
}
