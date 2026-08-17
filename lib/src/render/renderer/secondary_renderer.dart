import 'package:clean_k_chart/src/model/entity/macd_entity.dart';
import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter_factory.dart';
import 'package:clean_k_chart/src/render/renderer/base_chart_renderer.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart';
import 'package:flutter/material.dart';

class SecondaryRenderer extends BaseChartRenderer<MACDEntity> {
  SecondaryIndicator indicator;
  late final SecondaryIndicatorPainter indicatorPainter;
  final KChartStyle chartStyle;
  final KChartColors chartColors;

  SecondaryRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    this.indicator,
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
    indicatorPainter =
        IndicatorPainterFactory.create(indicator) as SecondaryIndicatorPainter;
  }

  @override
  void drawChart(
    MACDEntity lastPoint,
    MACDEntity curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    indicatorPainter.drawChart(
      lastPoint,
      curPoint,
      lastX,
      curX,
      getY,
      canvas,
      chartColors,
    );
  }

  @override
  void drawText(Canvas canvas, MACDEntity data, double x) {
    TextSpan? span = indicatorPainter.drawFigure(
      data,
      fixedLength,
      chartColors,
    );
    if (span == null) return;
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
      canvas,
      Offset(x, chartRect.top - topPadding + chartStyle.indicatorTopMargin),
    );
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    indicatorPainter.drawVerticalText(
      canvas: canvas,
      style: textStyle,
      maxValue: maxValue,
      minValue: minValue,
      fixedLength: fixedLength,
      chartRect: Rect.fromLTRB(
        chartRect.left,
        chartRect.top - topPadding + chartStyle.indicatorTopMargin,
        chartRect.right - chartStyle.space,
        chartRect.bottom,
      ),
    );
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    // canvas.drawLine(Offset(0, chartRect.top), Offset(chartRect.width, chartRect.top), gridPaint); //hidden line
    canvas.drawLine(
      Offset(0, chartRect.bottom),
      Offset(chartRect.width, chartRect.bottom),
      gridPaint,
    );
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //mSecondaryRect垂直线
      canvas.drawLine(
        Offset(columnSpace * i, chartRect.top - topPadding),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
    }
  }
}
