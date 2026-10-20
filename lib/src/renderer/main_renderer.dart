import 'package:clean_k_chart/src/entity/candle_entity.dart';
import 'package:clean_k_chart/src/indicator/indicator_template.dart';
import 'package:clean_k_chart/src/renderer/base_chart_renderer.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

enum VerticalTextAlignment { left, right }

class MainRenderer extends BaseChartRenderer<CandleEntity> {
  late double mCandleWidth;
  late double mCandleLineWidth;

  List<MainIndicator> indicatorLi;
  bool isLine;

  late Rect _contentRect;
  final double _contentPadding = 5.0;
  final KChartStyle chartStyle;
  final KChartColors chartColors;
  final double mLineStrokeWidth = 1.0;
  double scaleX;
  late Paint mLinePaint;
  final VerticalTextAlignment verticalTextAlignment;
  final double mBottomPadding;

  MainRenderer(
    Rect mainRect,
    double maxValue,
    double minValue,
    double topPadding,
    this.indicatorLi,
    this.isLine,
    int fixedLength,
    this.chartStyle,
    this.chartColors,
    this.scaleX,
    this.verticalTextAlignment,
    this.mBottomPadding,
  ) : super(
        chartRect: mainRect,
        maxValue: maxValue,
        minValue: minValue,
        topPadding: topPadding,
        fixedLength: fixedLength,
        gridColor: chartColors.gridColor,
      ) {
    mCandleWidth = chartStyle.candleWidth;
    mCandleLineWidth = chartStyle.candleLineWidth;

    mLinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = mLineStrokeWidth
      ..color = chartColors.kLineColor;

    _contentRect = Rect.fromLTRB(
      chartRect.left,
      chartRect.top + _contentPadding,
      chartRect.right,
      chartRect.bottom - _contentPadding,
    );

    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }

    scaleY = _contentRect.height / (maxValue - minValue);
  }

  @override
  void drawText(Canvas canvas, CandleEntity data, double x) {
    if (isLine == true) {
      return;
    }

    double y = chartStyle.indicatorTopMargin;
    for (int i = 0; i < indicatorLi.length; ++i) {
      final TextSpan? span = indicatorLi[i].drawFigure(
        data,
        fixedLength,
        chartColors,
      );
      if (span == null) {
        continue;
      }

      final TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      tp.layout(maxWidth: chartRect.width - chartStyle.space);

      final double textHeight = tp.height;
      final Offset offset = Offset(x, y);

      canvas.drawRect(
        Rect.fromLTRB(
          offset.dx - 2,
          offset.dy - 2,
          tp.width + offset.dx + 2,
          tp.height + offset.dy + 2,
        ),
        Paint()..color = chartColors.bgColor.withAlpha(80),
      );

      tp.paint(canvas, offset);
      tp.dispose();

      // update y
      y = y + textHeight + 2.0;
    }
  }

  @override
  void drawChart(
    CandleEntity lastPoint,
    CandleEntity curPoint,
    double lastX,
    double curX,
    Size size,
    Canvas canvas,
  ) {
    if (isLine) {
      drawPolyline(lastPoint.close, curPoint.close, canvas, lastX, curX);
    } else {
      drawCandle(curPoint, canvas, curX);

      // draw chart main state
      for (int i = 0; i < indicatorLi.length; ++i) {
        indicatorLi[i].drawChart(
          lastPoint,
          curPoint,
          lastX,
          curX,
          getY,
          canvas,
          chartColors,
        );
      }
    }
  }

  Shader? mLineFillShader;
  Path? mLinePath, mLineFillPath;
  Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  void drawPolyline(
    double lastPrice,
    double curPrice,
    Canvas canvas,
    double lastX,
    double curX,
  ) {
    // drawLine(lastPrice + 100, curPrice + 100, canvas, lastX, curX, ChartColors.kLineColor);
    mLinePath ??= Path();

    if (lastX == curX) {
      lastX = 0;
    }

    mLinePath!.moveTo(lastX, getY(lastPrice));

    mLinePath!.cubicTo(
      (lastX + curX) / 2,
      getY(lastPrice),
      (lastX + curX) / 2,
      getY(curPrice),
      curX,
      getY(curPrice),
    );

    mLineFillShader ??=
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: chartColors.kLineFillColors,
        ).createShader(
          Rect.fromLTRB(
            chartRect.left,
            chartRect.top,
            chartRect.right,
            chartRect.bottom,
          ),
        );

    mLineFillPaint.shader = mLineFillShader;

    mLineFillPath ??= Path();
    mLineFillPath!.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath!.lineTo(lastX, getY(lastPrice));
    mLineFillPath!.cubicTo(
      (lastX + curX) / 2,
      getY(lastPrice),
      (lastX + curX) / 2,
      getY(curPrice),
      curX,
      getY(curPrice),
    );
    mLineFillPath!.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath!.close();

    canvas.drawPath(mLineFillPath!, mLineFillPaint);

    mLineFillPath!.reset();

    canvas.drawPath(
      mLinePath!,
      mLinePaint..strokeWidth = (mLineStrokeWidth / scaleX).clamp(0.1, 1.0),
    );

    mLinePath!.reset();
  }

  void drawCandle(CandleEntity curPoint, Canvas canvas, double curX) {
    final double high = getY(curPoint.high);
    final double low = getY(curPoint.low);
    final double close = getY(curPoint.close);

    double open = getY(curPoint.open);
    double r = mCandleWidth / 2;
    double lineR = mCandleLineWidth / 2;

    if (open >= close) {
      if (open - close < mCandleLineWidth) {
        open = close + mCandleLineWidth;
      }

      chartPaint.color = chartColors.upColor;

      canvas.drawRect(
        Rect.fromLTRB(curX - r, close, curX + r, open),
        chartPaint,
      );

      canvas.drawRect(
        Rect.fromLTRB(curX - lineR, high, curX + lineR, low),
        chartPaint,
      );
    } else if (close > open) {
      if (close - open < mCandleLineWidth) {
        open = close - mCandleLineWidth;
      }

      chartPaint.color = chartColors.dnColor;

      canvas.drawRect(
        Rect.fromLTRB(curX - r, open, curX + r, close),
        chartPaint,
      );

      canvas.drawRect(
        Rect.fromLTRB(curX - lineR, high, curX + lineR, low),
        chartPaint,
      );
    }
  }

  @override
  void drawVerticalText(Canvas canvas, textStyle, int gridRows) {
    final double rowSpace = chartRect.height / gridRows;

    for (var i = 0; i <= gridRows; ++i) {
      final double value = (gridRows - i) * rowSpace / scaleY + minValue;

      final TextSpan span = TextSpan(
        text: NumberUtil.formatFixed(value, fixedLength) ?? '',
        style: textStyle,
      );

      final TextPainter tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      double offsetX;
      switch (verticalTextAlignment) {
        case VerticalTextAlignment.left:
          offsetX = chartStyle.space;
          break;
        case VerticalTextAlignment.right:
          offsetX = chartRect.width - tp.width - chartStyle.space;
          break;
      }

      if (i == 0) {
        tp.paint(canvas, Offset(offsetX, topPadding));
      } else {
        tp.paint(
          canvas,
          Offset(offsetX, rowSpace * i - tp.height + topPadding),
        );
      }

      tp.dispose();
    }
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    // final int gridRows = 4, gridColumns = 4;
    final double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(
        Offset(0, rowSpace * i + topPadding),
        Offset(chartRect.width, rowSpace * i + topPadding),
        gridPaint,
      );
    }

    final double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(
        Offset(columnSpace * i, 0),
        Offset(columnSpace * i, chartRect.bottom),
        gridPaint,
      );
    }

    // draw top grid
    canvas.drawLine(const Offset(0, 0), Offset(chartRect.width, 0), gridPaint);

    // draw bottom grid
    canvas.drawLine(
      Offset(0, chartRect.bottom + mBottomPadding),
      Offset(chartRect.width, chartRect.bottom + mBottomPadding),
      gridPaint,
    );
  }

  @override
  double getY(double y) {
    return (maxValue - y) * scaleY + _contentRect.top;
  }
}
