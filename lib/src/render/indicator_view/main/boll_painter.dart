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
        TextSpan(
          text: 'BOLL:${formatNumber(boll.mid, precision)}  ',
          style: labelStyle(style.bollColor),
        ),
        TextSpan(
          text: 'UB:${formatNumber(boll.up, precision)}  ',
          style: labelStyle(style.ubColor),
        ),
        TextSpan(
          text: 'LB:${formatNumber(boll.dn, precision)}',
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

    canvas.drawLine(
      Offset(curX, getY(curBoll.up)),
      Offset(lastX, getY(lastBoll.up)),
      _linePaint..color = style.ubColor,
    );
    canvas.drawLine(
      Offset(lastX, getY(lastBoll.dn)),
      Offset(curX, getY(curBoll.dn)),
      _linePaint..color = style.lbColor,
    );
    _fillPath
      ..reset()
      ..moveTo(curX, getY(curBoll.up))
      ..lineTo(lastX, getY(lastBoll.up))
      ..lineTo(lastX, getY(lastBoll.dn))
      ..lineTo(curX, getY(curBoll.dn))
      ..close();
    canvas.drawPath(_fillPath, _fillPaint);
    canvas.drawLine(
      Offset(curX, getY(curBoll.mid)),
      Offset(lastX, getY(lastBoll.mid)),
      _linePaint..color = style.bollColor,
    );
  }
}
