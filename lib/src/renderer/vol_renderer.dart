import 'package:clean_k_chart/src/entity/volume_entity.dart';
import 'package:clean_k_chart/src/extension/num_ext.dart';
import 'package:clean_k_chart/src/renderer/base_chart_renderer.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

class VolRenderer extends BaseChartRenderer<VolumeEntity> {
  late double mVolWidth;
  final KChartStyle chartStyle;
  final KChartColors chartColors;

  VolRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    int fixedLength,
    this.chartStyle,
    this.chartColors,
  ) : super(
        chartRect: mainRect,
        maxValue: maxValue,
        minValue: minValue,
        topPadding: topPadding,
        fixedLength: fixedLength,
        gridColor: chartColors.gridColor,
      ) {
    mVolWidth = chartStyle.volWidth;
  }

  @override
  void drawChart(
    VolumeEntity lastPoint,
    VolumeEntity curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    final double r = mVolWidth / 2;
    final double top = getVolY(curPoint.vol);
    final double bottom = chartRect.bottom;

    if (curPoint.vol != 0) {
      canvas.drawRect(
        Rect.fromLTRB(curX - r, top, curX + r, bottom),
        chartPaint
          ..color = curPoint.close > curPoint.open
              ? chartColors.volUpColor
              : chartColors.volDnColor,
      );
    }

    if (lastPoint.ma5Volume != 0) {
      drawLine(
        lastPoint.ma5Volume,
        curPoint.ma5Volume,
        canvas,
        lastX,
        curX,
        chartColors.ma5Color,
      );
    }

    if (lastPoint.ma10Volume != 0) {
      drawLine(
        lastPoint.ma10Volume,
        curPoint.ma10Volume,
        canvas,
        lastX,
        curX,
        chartColors.ma10Color,
      );
    }
  }

  double getVolY(double value) =>
      (maxValue - value) * (chartRect.height / maxValue) + chartRect.top;

  @override
  void drawText(Canvas canvas, VolumeEntity data, double x) {
    final TextSpan span = TextSpan(
      children: [
        TextSpan(
          text: "VOL:${NumberUtil.formatCompact(data.vol)}   ",
          style: getTextStyle(chartColors.volColor),
        ),
        if (data.ma5Volume.notNullOrZero)
          TextSpan(
            text: "MA5:${NumberUtil.formatCompact(data.ma5Volume!)}   ",
            style: getTextStyle(chartColors.ma5Color),
          ),
        if (data.ma10Volume.notNullOrZero)
          TextSpan(
            text: "MA10:${NumberUtil.formatCompact(data.ma10Volume!)}   ",
            style: getTextStyle(chartColors.ma10Color),
          ),
      ],
    );

    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(x, chartRect.top - topPadding + chartStyle.indicatorTopMargin),
    );
    tp.dispose();
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    final TextSpan span = TextSpan(
      text: NumberUtil.formatCompact(maxValue),
      style: textStyle,
    );

    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        chartRect.width - tp.width - chartStyle.space,
        chartRect.top - topPadding + chartStyle.indicatorTopMargin,
      ),
    );
    tp.dispose();
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(
      Offset(0, chartRect.bottom),
      Offset(chartRect.width, chartRect.bottom),
      gridPaint,
    );

    final double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      // vol垂直线
      canvas.drawLine(
        Offset(columnSpace * i, chartRect.top - topPadding),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
    }
  }

  TextStyle getTextStyle(Color color) {
    return TextStyle(fontSize: 10.0, color: color);
  }
}
