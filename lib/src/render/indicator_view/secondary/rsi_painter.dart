import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/model/entity/macd_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

class RSIPainter extends SecondaryIndicatorPainter<MACDEntity, RSIStyle> {
  late final Paint _linePaint;

  RSIPainter(super.indicator) {
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
    if (entity.rsi == null) return null;
    return TextSpan(
      text: "RSI(14):${formatNumber(entity.rsi!, precision)}",
      style: getTextStyle(indicatorStyle.rsiColor),
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
    TextPainter maxTp = TextPainter(
      text: TextSpan(
        text: "${NumberUtil.formatFixed(maxValue, fixedLength) ?? ''}",
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    maxTp.layout();
    TextPainter minTp = TextPainter(
      text: TextSpan(
        text: "${NumberUtil.formatFixed(minValue, fixedLength) ?? ''}",
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    minTp.layout();

    maxTp.paint(canvas, Offset(chartRect.width - maxTp.width, chartRect.top));
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
    if (curPoint.rsi == null || lastPoint.rsi == null) return;
    canvas.drawLine(
      Offset(curX, getY(curPoint.rsi!)),
      Offset(lastX, getY(lastPoint.rsi!)),
      _linePaint..color = indicatorStyle.rsiColor,
    );
  }
}
