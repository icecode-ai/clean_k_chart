import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/model/entity/macd_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

class MACDPainter extends SecondaryIndicatorPainter<MACDEntity, MACDStyle> {
  late final Paint _linePaint;
  late final Paint _rectPaint;

  MACDPainter(super.indicator) {
    _linePaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = indicatorStyle.lineWidth;

    _rectPaint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..strokeWidth = indicatorStyle.strokeWidth;
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
          text: "MACD(12,26,9) ",
          style: getTextStyle(chartColors.defaultTextColor),
        ),
        if (entity.macd != null && entity.macd != 0)
          TextSpan(
            text: "MACD:${formatNumber(entity.macd!, precision)}  ",
            style: getTextStyle(indicatorStyle.macdColor),
          ),
        if (entity.dif != null && entity.dif != 0)
          TextSpan(
            text: "DIF:${formatNumber(entity.dif!, precision)}  ",
            style: getTextStyle(indicatorStyle.difColor),
          ),
        if (entity.dea != null && entity.dea != 0)
          TextSpan(
            text: "DEA:${formatNumber(entity.dea!, precision)}",
            style: getTextStyle(indicatorStyle.deaColor),
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
    final prevMacd = lastPoint.macd;
    final macd = curPoint.macd;
    if (curPoint.macd != null) {
      final macdWidth = indicatorStyle.macdWidth;
      double r = macdWidth / 2;
      double zeroy = getY(0);
      double macdY = getY(macd!);
      _rectPaint.style = (prevMacd == null || prevMacd <= macd)
          ? PaintingStyle.stroke
          : PaintingStyle.fill;
      if (macd > 0) {
        canvas.drawRect(
          Rect.fromLTRB(curX - r, macdY, curX + r, zeroy),
          _rectPaint..color = indicatorStyle.upColor,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTRB(curX - r, zeroy, curX + r, macdY),
          _rectPaint..color = indicatorStyle.dnColor,
        );
      }
    }
    if (lastPoint.dif != null && lastPoint.dif != 0 && curPoint.dif != null) {
      canvas.drawLine(
        Offset(curX, getY(curPoint.dif!)),
        Offset(lastX, getY(lastPoint.dif!)),
        _linePaint..color = indicatorStyle.difColor,
      );
    }
    if (lastPoint.dea != null && lastPoint.dea != 0 && curPoint.dea != null) {
      canvas.drawLine(
        Offset(curX, getY(curPoint.dea!)),
        Offset(lastX, getY(lastPoint.dea!)),
        _linePaint..color = indicatorStyle.deaColor,
      );
    }
  }
}
