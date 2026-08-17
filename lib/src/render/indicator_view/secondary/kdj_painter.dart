import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/model/entity/macd_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

class KDJPainter extends SecondaryIndicatorPainter<MACDEntity, KDJStyle> {
  late final Paint _linePaint;

  KDJPainter(super.indicator) {
    _linePaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = indicatorStyle.lineWidth;
  }

  @override
  TextSpan? drawFigure(
    MACDEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    return TextSpan(
      children: [
        TextSpan(
          text: "KDJ(9,1,3) ",
          style: getTextStyle(chartColors.defaultTextColor),
        ),
        if (entity.k != null && entity.k != 0)
          TextSpan(
            text: "K:${formatNumber(entity.k!, precision)}  ",
            style: getTextStyle(indicatorStyle.kColor),
          ),
        if (entity.d != null && entity.d != 0)
          TextSpan(
            text: "D:${formatNumber(entity.d!, precision)}  ",
            style: getTextStyle(indicatorStyle.dColor),
          ),
        if (entity.j != null && entity.j != 0)
          TextSpan(
            text: "J:${formatNumber(entity.j!, precision)}",
            style: getTextStyle(indicatorStyle.jColor),
          ),
      ],
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
    List<int> rangeValue = [80, 20];
    final spaceRange = maxValue - minValue;

    for (int i = 0; i < rangeValue.length; ++i) {
      final value = rangeValue[i];
      if (value < minValue || value > maxValue) continue;
      TextPainter tp = TextPainter(
        text: TextSpan(text: value.toString(), style: style),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      final ratio = (value - minValue) / spaceRange;
      final x = chartRect.width - tp.width;
      final y = chartRect.bottom - ratio * chartRect.height - tp.height / 2;
      tp.paint(
        canvas,
        Offset(x, y.clamp(chartRect.top, chartRect.bottom - tp.height)),
      );
    }
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
    if (curPoint.k != null || lastPoint.k != null) {
      canvas.drawLine(
        Offset(curX, getY(curPoint.k!)),
        Offset(lastX, getY(lastPoint.k!)),
        _linePaint..color = indicatorStyle.kColor,
      );
    }
    if (curPoint.d != null || lastPoint.d != null) {
      canvas.drawLine(
        Offset(curX, getY(curPoint.d!)),
        Offset(lastX, getY(lastPoint.d!)),
        _linePaint..color = indicatorStyle.dColor,
      );
    }
    if (curPoint.j != null || lastPoint.j != null) {
      canvas.drawLine(
        Offset(curX, getY(curPoint.j!)),
        Offset(lastX, getY(lastPoint.j!)),
        _linePaint..color = indicatorStyle.jColor,
      );
    }
  }
}
