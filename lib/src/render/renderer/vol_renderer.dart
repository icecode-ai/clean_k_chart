import 'package:clean_k_chart/src/model/entity/volume_entity.dart';
import 'package:clean_k_chart/src/utils/extension/num_ext.dart';
import 'package:clean_k_chart/src/render/renderer/base_chart_renderer.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/material.dart';

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
    mVolWidth = this.chartStyle.volWidth;
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
    double r = mVolWidth / 2;
    double top = getVolY(curPoint.vol);
    double bottom = chartRect.bottom;
    if (curPoint.vol != 0) {
      canvas.drawRect(
        Rect.fromLTRB(curX - r, top, curX + r, bottom),
        chartPaint
          ..color = curPoint.close > curPoint.open
              ? this.chartColors.volUpColor
              : this.chartColors.volDnColor,
      );
    }

    if (lastPoint.MA5Volume != 0) {
      drawLine(
        lastPoint.MA5Volume,
        curPoint.MA5Volume,
        canvas,
        lastX,
        curX,
        this.chartColors.ma5Color,
      );
    }

    if (lastPoint.MA10Volume != 0) {
      drawLine(
        lastPoint.MA10Volume,
        curPoint.MA10Volume,
        canvas,
        lastX,
        curX,
        this.chartColors.ma10Color,
      );
    }
  }

  double getVolY(double value) =>
      (maxValue - value) * (chartRect.height / maxValue) + chartRect.top;

  @override
  void drawText(Canvas canvas, VolumeEntity data, double x) {
    TextSpan span = TextSpan(
      children: [
        TextSpan(
          text: "VOL:${NumberUtil.formatCompact(data.vol)}   ",
          style: getTextStyle(this.chartColors.volColor),
        ),
        if (data.MA5Volume.notNullOrZero)
          TextSpan(
            text: "MA5:${NumberUtil.formatCompact(data.MA5Volume!)}   ",
            style: getTextStyle(this.chartColors.ma5Color),
          ),
        if (data.MA10Volume.notNullOrZero)
          TextSpan(
            text: "MA10:${NumberUtil.formatCompact(data.MA10Volume!)}   ",
            style: getTextStyle(this.chartColors.ma10Color),
          ),
      ],
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
      canvas,
      Offset(x, chartRect.top - topPadding + chartStyle.indicatorTopMargin),
    );
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    TextSpan span = TextSpan(
      text: "${NumberUtil.formatCompact(maxValue)}",
      style: textStyle,
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        chartRect.width - tp.width - chartStyle.space,
        chartRect.top - topPadding + chartStyle.indicatorTopMargin,
      ),
    );
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(
      Offset(0, chartRect.bottom),
      Offset(chartRect.width, chartRect.bottom),
      gridPaint,
    );
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //vol垂直线
      canvas.drawLine(
        Offset(columnSpace * i, chartRect.top - topPadding),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
    }
  }
}
