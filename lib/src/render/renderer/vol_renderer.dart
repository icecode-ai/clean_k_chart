import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/render_util.dart';
import 'package:clean_k_chart/src/render/renderer/base_chart_renderer.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

/// Renders the volume panel with MA5/MA10 volume lines.
class VolRenderer extends BaseChartRenderer {
  VolRenderer({
    required super.chartStyle,
    required super.chartColors,
    required super.topPadding,
  });

  @override
  void drawChart(
    KLineEntity lastPoint,
    KLineEntity curPoint,
    double lastX,
    double curX,
    Canvas canvas, {
    double scaleX = 1,
  }) {
    if (maxValue <= 0) return; // all-zero volume window
    final r = chartStyle.volWidth / 2;
    if (curPoint.vol != 0) {
      canvas.drawRect(
        Rect.fromLTRB(
          curX - r,
          getVolY(curPoint.vol),
          curX + r,
          chartRect.bottom,
        ),
        chartPaint
          ..color = curPoint.close > curPoint.open
              ? chartColors.volUpColor
              : chartColors.volDnColor,
      );
    }
    drawValueLine(
      canvas,
      lastPoint.ma5Volume,
      curPoint.ma5Volume,
      lastX,
      curX,
      getY,
      chartPaint,
      chartColors.ma5Color,
    );
    drawValueLine(
      canvas,
      lastPoint.ma10Volume,
      curPoint.ma10Volume,
      lastX,
      curX,
      getY,
      chartPaint,
      chartColors.ma10Color,
    );
  }

  /// Volume bars are anchored to the zero baseline rather than the
  /// min/max range, so they keep their proportions.
  double getVolY(double value) =>
      (maxValue - value) * (chartRect.height / maxValue) + chartRect.top;

  @override
  void drawHeaderLabels(Canvas canvas, KLineEntity data, double x) {
    final spans = <InlineSpan>[
      TextSpan(
        text: 'VOL:${NumberUtil.formatCompact(data.vol)}   ',
        style: axisLabelStyle(chartColors.volColor),
      ),
      if (data.ma5Volume != null)
        TextSpan(
          text: 'MA5:${NumberUtil.formatCompact(data.ma5Volume!)}   ',
          style: axisLabelStyle(chartColors.ma5Color),
        ),
      if (data.ma10Volume != null)
        TextSpan(
          text: 'MA10:${NumberUtil.formatCompact(data.ma10Volume!)}   ',
          style: axisLabelStyle(chartColors.ma10Color),
        ),
    ];
    drawHeaderText(canvas, TextSpan(children: spans), Offset(x, headerY));
  }

  @override
  void drawVerticalText(Canvas canvas, TextStyle textStyle) {
    final text = NumberUtil.formatCompact(maxValue);
    labelPainter
      ..text = TextSpan(text: text, style: textStyle)
      ..layout();
    labelPainter.paint(
      canvas,
      Offset(chartRect.width - labelPainter.width - chartStyle.space, headerY),
    );
  }
}
