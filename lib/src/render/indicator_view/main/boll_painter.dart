import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

/// Painter for [BOLLIndicator]: upper / lower / mid lines with a fill
/// between the bands.
class BOLLPainter extends IndicatorPainter {
  final BOLLStyle style;

  final Paint _linePaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high;
  final Paint _fillPaint = Paint()..isAntiAlias = true;
  final Path _fillPath = Path();

  BOLLPainter(super.indicator, {BOLLStyle style = const BOLLStyle()})
    : style = style {
    _linePaint.strokeWidth = style.lineWidth;
    _fillPaint.color = style.fillColor;
  }

  @override
  TextSpan? buildLabel(
    KLineEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    final boll = entity.boll;
    if (boll == null) return null;
    return TextSpan(
      children: [
        if (boll.mid != null && boll.mid != 0)
          TextSpan(
            text: 'BOLL:${formatNumber(boll.mid!, precision)}  ',
            style: labelStyle(style.bollColor),
          ),
        if (boll.up != null && boll.up != 0)
          TextSpan(
            text: 'UB:${formatNumber(boll.up!, precision)}  ',
            style: labelStyle(style.ubColor),
          ),
        if (boll.dn != null && boll.dn != 0)
          TextSpan(
            text: 'LB:${formatNumber(boll.dn!, precision)}',
            style: labelStyle(style.lbColor),
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
    final lastBoll = lastPoint.boll;
    final curBoll = curPoint.boll;
    if (lastBoll == null || curBoll == null) return;

    final curUp = curBoll.up;
    final lastUp = lastBoll.up;
    final curDn = curBoll.dn;
    final lastDn = lastBoll.dn;

    if (curUp != null && lastUp != null) {
      canvas.drawLine(
        Offset(curX, getY(curUp)),
        Offset(lastX, getY(lastUp)),
        _linePaint..color = style.ubColor,
      );
    }
    if (curDn != null && lastDn != null) {
      canvas.drawLine(
        Offset(lastX, getY(lastDn)),
        Offset(curX, getY(curDn)),
        _linePaint..color = style.lbColor,
      );
    }
    if (curUp != null && lastUp != null && curDn != null && lastDn != null) {
      _fillPath
        ..reset()
        ..moveTo(curX, getY(curUp))
        ..lineTo(lastX, getY(lastUp))
        ..lineTo(lastX, getY(lastDn))
        ..lineTo(curX, getY(curDn))
        ..close();
      canvas.drawPath(_fillPath, _fillPaint);
    }
    final curMid = curBoll.mid;
    final lastMid = lastBoll.mid;
    if (curMid != null && lastMid != null) {
      canvas.drawLine(
        Offset(curX, getY(curMid)),
        Offset(lastX, getY(lastMid)),
        _linePaint..color = style.bollColor,
      );
    }
  }
}
