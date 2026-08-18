import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

/// Painter for [MACDIndicator]: DIF/DEA lines plus the histogram.
class MACDPainter extends SecondaryIndicatorPainter {
  final MACDStyle style;

  final Paint _linePaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high;
  final Paint _rectPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0;

  MACDPainter(super.indicator, {MACDStyle style = const MACDStyle()})
    : style = style {
    _linePaint.strokeWidth = style.lineWidth;
  }

  @override
  TextSpan? buildLabel(
    KLineEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    return TextSpan(
      children: [
        TextSpan(
          text: 'MACD(${indicator.calcParams.join(',')}) ',
          style: labelStyle(chartColors.defaultTextColor),
        ),
        if (entity.macd != null)
          TextSpan(
            text: 'MACD:${formatNumber(entity.macd!, precision)}  ',
            style: labelStyle(style.macdColor),
          ),
        if (entity.dif != null)
          TextSpan(
            text: 'DIF:${formatNumber(entity.dif!, precision)}  ',
            style: labelStyle(style.difColor),
          ),
        if (entity.dea != null)
          TextSpan(
            text: 'DEA:${formatNumber(entity.dea!, precision)}',
            style: labelStyle(style.deaColor),
          ),
      ],
    );
  }

  @override
  void drawChart(
    KLineEntity lastPoint,
    KLineEntity curPoint,
    double lastX,
    double curX,
    ValueY getY,
    Canvas canvas,
    KChartColors chartColors,
  ) {
    final macd = curPoint.macd;
    if (macd != null) {
      final r = style.macdWidth / 2;
      final zeroY = getY(0);
      final macdY = getY(macd);
      final lastMacd = lastPoint.macd;
      _rectPaint.style = lastMacd == null || lastMacd <= macd
          ? PaintingStyle.stroke
          : PaintingStyle.fill;
      if (macd > 0) {
        canvas.drawRect(
          Rect.fromLTRB(curX - r, macdY, curX + r, zeroY),
          _rectPaint..color = style.upColor,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTRB(curX - r, zeroY, curX + r, macdY),
          _rectPaint..color = style.dnColor,
        );
      }
    }
    if (lastPoint.dif != null && curPoint.dif != null) {
      canvas.drawLine(
        Offset(curX, getY(curPoint.dif!)),
        Offset(lastX, getY(lastPoint.dif!)),
        _linePaint..color = style.difColor,
      );
    }
    if (lastPoint.dea != null && curPoint.dea != null) {
      canvas.drawLine(
        Offset(curX, getY(curPoint.dea!)),
        Offset(lastX, getY(lastPoint.dea!)),
        _linePaint..color = style.deaColor,
      );
    }
  }
}
