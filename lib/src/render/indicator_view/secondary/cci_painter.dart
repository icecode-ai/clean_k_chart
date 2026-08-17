import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/model/entity/macd_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

class CCIPainter extends SecondaryIndicatorPainter<MACDEntity, CCIStyle> {
  late final Paint _linePaint;

  CCIPainter(super.indicator) {
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
    if (entity.cci == null) return null;
    return TextSpan(
      text:
          "CCI(${indicator.calcParams.first}):${formatNumber(entity.cci!, precision)}",
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
            "${NumberUtil.formatFixed((maxValue / jumpValue).round() * jumpValue, 0) ?? ''}",
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    maxTp.layout();
    maxTp.paint(canvas, Offset(chartRect.width - maxTp.width, chartRect.top));

    /// min
    TextPainter minTp = TextPainter(
      text: TextSpan(
        text:
            "${NumberUtil.formatFixed((minValue / jumpValue).round() * jumpValue, 0) ?? ''}",
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    minTp.layout();
    minTp.paint(
      canvas,
      Offset(chartRect.width - minTp.width, chartRect.bottom - minTp.height),
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
    if (curPoint.cci == null || lastPoint.cci == null) return;
    canvas.drawLine(
      Offset(curX, getY(curPoint.cci!)),
      Offset(lastX, getY(lastPoint.cci!)),
      _linePaint..color = indicatorStyle.cciColor,
    );
  }
}
