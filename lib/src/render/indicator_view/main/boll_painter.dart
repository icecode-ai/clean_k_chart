import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/model/entity/boll_entity.dart';
import 'package:clean_k_chart/src/model/entity/candle_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

class BOLLPainter extends IndicatorPainter<CandleEntity, BOLLStyle> {
  late final Paint _linePaint;
  late final Paint _fillPaint;

  BOLLPainter(super.indicator) {
    _linePaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = indicatorStyle.lineWidth;

    _fillPaint = Paint()..color = indicatorStyle.fillColor;
  }

  @override
  TextSpan? drawFigure(
    CandleEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    if (entity.boll == null) return null;
    Boll value = entity.boll!;
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
    if (lastPoint.boll == null || curPoint.boll == null) return;
    final List<Offset> _positionLi = [];

    if (curPoint.boll!.up != null && lastPoint.boll!.up != null) {
      _positionLi.add(Offset(curX, getY(curPoint.boll!.up!))); //0
      _positionLi.add(Offset(lastX, getY(lastPoint.boll!.up!))); //1
      /// UB
      canvas.drawLine(
        _positionLi[0],
        _positionLi[1],
        _linePaint..color = indicatorStyle.ubColor,
      );
    }

    if (curPoint.boll!.dn != null && lastPoint.boll!.dn != null) {
      _positionLi.add(Offset(lastX, getY(lastPoint.boll!.dn!))); //2
      _positionLi.add(Offset(curX, getY(curPoint.boll!.dn!))); //3

      /// LB
      canvas.drawLine(
        _positionLi[2],
        _positionLi[3],
        _linePaint..color = indicatorStyle.lbColor,
      );
    }

    if (_positionLi.length == 4) {
      Path _fillPath = Path()
        ..moveTo(_positionLi[0].dx, _positionLi[0].dy)
        ..lineTo(_positionLi[1].dx, _positionLi[1].dy)
        ..lineTo(_positionLi[2].dx, _positionLi[2].dy)
        ..lineTo(_positionLi[3].dx, _positionLi[3].dy)
        ..close();

      canvas.drawPath(_fillPath, _fillPaint);
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
}
