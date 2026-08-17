import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/model/entity/candle_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

class EMAPainter extends IndicatorPainter<CandleEntity, MAStyle> {
  late final Paint _linePaint;

  EMAPainter(super.indicator) {
    _linePaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = indicatorStyle.lineWidth;
  }

  @override
  TextSpan? drawFigure(
    CandleEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    List<InlineSpan> result = [];
    if (entity.emaValueList?.isEmpty ?? true) return null;
    for (int i = 0; i < (entity.emaValueList!.length); i++) {
      if (entity.emaValueList?[i] != 0) {
        var item = TextSpan(
          text:
              "EMA${indicator.calcParams[i]}:${formatNumber(entity.emaValueList![i], precision)}  ",
          style: TextStyle(fontSize: 10, color: indicatorStyle.getMAColor(i)),
        );
        result.add(item);
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
      if (lastPoint.emaValueList?[i] != 0) {
        canvas.drawLine(
          Offset(curX, getY(curPoint.emaValueList![i])),
          Offset(lastX, getY(lastPoint.emaValueList![i])),
          _linePaint..color = indicatorStyle.getMAColor(i),
        );
      }
    }
  }
}
