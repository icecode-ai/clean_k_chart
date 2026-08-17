import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/model/entity/candle_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

class MAPainter extends IndicatorPainter<CandleEntity, MAStyle> {
  late final Paint _linePaint;

  MAPainter(super.indicator) {
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
    if (entity.maValueList?.isEmpty ?? true) return null;
    for (int i = 0; i < (entity.maValueList!.length); i++) {
      if (entity.maValueList?[i] != 0) {
        var item = TextSpan(
          text:
              "MA${indicator.calcParams[i]}:${formatNumber(entity.maValueList![i], precision)}  ",
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
    if (curPoint.maValueList == null ||
        lastPoint.maValueList == null ||
        curPoint.maValueList!.length != lastPoint.maValueList!.length) {
      return;
    }
    for (int i = 0; i < curPoint.maValueList!.length; i++) {
      if (lastPoint.maValueList?[i] != 0) {
        canvas.drawLine(
          Offset(curX, getY(curPoint.maValueList![i])),
          Offset(lastX, getY(lastPoint.maValueList![i])),
          _linePaint..color = indicatorStyle.getMAColor(i),
        );
      }
    }
  }
}
