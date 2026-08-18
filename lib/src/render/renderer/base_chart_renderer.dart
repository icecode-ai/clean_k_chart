import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

/// Base for the per-panel renderers (main / volume / secondary).
///
/// Instances are long-lived: [update] re-targets the rect and value range
/// each frame instead of reallocating renderers, so [Paint]s and the
/// label [TextPainter] are allocated only once.
abstract class BaseChartRenderer {
  final KChartStyle chartStyle;
  final KChartColors chartColors;

  /// Space reserved above the panel for its header label.
  final double topPadding;

  final Paint chartPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 1.0;
  final Paint gridPaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high
    ..strokeWidth = 0.5;
  final Paint _headerBgPaint = Paint();

  /// Reused painter for header / axis labels — never reallocated.
  final TextPainter labelPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  late Rect chartRect;
  double maxValue = 0;
  double minValue = 0;
  double scaleY = 1;
  int fixedLength = 2;

  BaseChartRenderer({
    required this.chartStyle,
    required this.chartColors,
    required this.topPadding,
  }) {
    gridPaint.color = chartColors.gridColor;
    _headerBgPaint.color = chartColors.bgColor.withAlpha(80);
  }

  /// Re-targets layout and value range.
  ///
  /// Flat ranges are padded symmetrically so `scaleY` stays finite
  /// (all-zero data used to produce an infinite scale).
  void update({
    required Rect rect,
    required double maxValue,
    required double minValue,
    required int fixedLength,
  }) {
    chartRect = rect;
    this.fixedLength = fixedLength;
    if (maxValue == minValue) {
      final pad = maxValue == 0 ? 1.0 : maxValue.abs() * 0.5;
      maxValue += pad;
      minValue -= pad;
    }
    this.maxValue = maxValue;
    this.minValue = minValue;
    scaleY = rect.height / (maxValue - minValue);
  }

  double getY(double value) => (maxValue - value) * scaleY + chartRect.top;

  /// Y coordinate of the panel header label.
  double get headerY =>
      chartRect.top - topPadding + chartStyle.indicatorTopMargin;

  /// Draws the panel grid: vertical column lines plus top/bottom borders.
  /// Subclasses override to add horizontal row lines.
  void drawGrid(Canvas canvas) {
    final columns = chartStyle.gridColumns;
    final columnSpace = chartRect.width / columns;
    for (var i = 0; i <= columns; i++) {
      final x = columnSpace * i;
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
        gridPaint,
      );
    }
    canvas.drawLine(chartRect.topLeft, chartRect.topRight, gridPaint);
    canvas.drawLine(chartRect.bottomLeft, chartRect.bottomRight, gridPaint);
  }

  /// Lays out and paints a header [span]; reuses the internal
  /// [TextPainter] so no painter object is allocated per frame.
  /// Returns the laid-out label height.
  double drawHeaderText(
    Canvas canvas,
    TextSpan span,
    Offset offset, {
    bool withBackground = false,
  }) {
    labelPainter
      ..text = span
      ..layout();
    if (withBackground) {
      canvas.drawRect(
        Rect.fromLTRB(
          offset.dx - 2,
          offset.dy - 2,
          offset.dx + labelPainter.width + 2,
          offset.dy + labelPainter.height + 2,
        ),
        _headerBgPaint,
      );
    }
    labelPainter.paint(canvas, offset);
    return labelPainter.height;
  }

  /// Draws a value line, skipping null warm-up values on either end.
  void drawValueLine(
    double? lastValue,
    double? curValue,
    Canvas canvas,
    double lastX,
    double curX,
    Paint paint,
    Color color,
  ) {
    if (lastValue == null || curValue == null) return;
    canvas.drawLine(
      Offset(lastX, getY(lastValue)),
      Offset(curX, getY(curValue)),
      paint..color = color,
    );
  }

  /// Formats a value for the vertical axis.
  String formatAxisValue(double value) =>
      NumberUtil.formatFixed(value, fixedLength) ?? '';

  /// Draws the header labels of this panel for [data] at x [x].
  void drawHeaderLabels(Canvas canvas, KLineEntity data, double x);

  /// Draws the vertical axis labels of this panel.
  void drawVerticalText(Canvas canvas, TextStyle textStyle);

  /// Draws one data step (from [lastPoint] to [curPoint]).
  void drawChart(
    KLineEntity lastPoint,
    KLineEntity curPoint,
    double lastX,
    double curX,
    Canvas canvas, {
    double scaleX = 1,
  });
}
