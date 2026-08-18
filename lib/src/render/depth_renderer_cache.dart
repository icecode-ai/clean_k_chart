import 'dart:math' as math;

import 'package:clean_k_chart/src/style/depth_chart_style.dart';
import 'package:flutter/painting.dart';

/// Long-lived render state for the depth chart, held by the widget state.
///
/// Paints, paths and the label / popup text painters are created once and
/// re-targeted from the current style in [sync] — the painter itself owns
/// no render objects, so rebuilding it per gesture frame stays cheap
/// (it used to reallocate eight paints, three paths and text painters on
/// every build, plus a popup painter per long-press frame).
class DepthRendererCache {
  final Paint buyLinePaint = Paint()..isAntiAlias = true;
  final Paint sellLinePaint = Paint()..isAntiAlias = true;
  final Paint buyFillPaint = Paint()..isAntiAlias = true;
  final Paint sellFillPaint = Paint()..isAntiAlias = true;
  final Paint barrierPaint = Paint()..isAntiAlias = true;
  final Paint crossPaint = Paint()..isAntiAlias = true;
  final Paint selectFillPaint = Paint()..isAntiAlias = true;
  final Paint selectBorderPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;

  /// Filled dot at the selection point (default paint style is fill).
  final Paint dotPaint = Paint()..isAntiAlias = true;

  final Path buyPath = Path();
  final Path sellPath = Path();
  final Path dashPath = Path();

  /// Reused painter for axis / bottom labels.
  final TextPainter labelPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  /// Reused painters for the selection popup (price + amount lines).
  final TextPainter popupPricePainter = TextPainter(
    textDirection: TextDirection.ltr,
  );
  final TextPainter popupAmountPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  // Style signature — paints are re-targeted only when it changes.
  DepthChartColors? _colors;
  DepthChartStyle? _style;

  /// Re-targets the paints from [chartColors]/[chartStyle]. Cheap no-op
  /// (identity comparison) when nothing changed.
  void sync({
    required DepthChartColors chartColors,
    required DepthChartStyle chartStyle,
  }) {
    if (identical(_colors, chartColors) && identical(_style, chartStyle)) {
      return;
    }
    buyLinePaint
      ..color = chartColors.upColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = chartStyle.lineWidth;
    sellLinePaint
      ..color = chartColors.dnColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = chartStyle.lineWidth;
    buyFillPaint.color = chartColors.upFillPathColor;
    sellFillPaint.color = chartColors.dnFillPathColor;
    barrierPaint.color = chartColors.barrierColor;
    crossPaint
      ..color = chartColors.crossColor
      ..strokeWidth = chartStyle.crossWidth;
    selectFillPaint.color = chartColors.selectFillColor;
    selectBorderPaint
      ..color = chartColors.selectBorderColor
      ..strokeWidth = chartStyle.strokeWidth;
    _colors = chartColors;
    _style = chartStyle;
  }

  /// Lays out the popup text for the given [price]/[amount] labels.
  /// Draw the popup (via [paintPopup]) before re-targeting again.
  void updatePopup({
    required String price,
    required String amount,
    required Color textColor,
  }) {
    final style = TextStyle(color: textColor, fontSize: 9);
    popupPricePainter
      ..text = TextSpan(text: price, style: style)
      ..layout();
    popupAmountPainter
      ..text = TextSpan(text: amount, style: style)
      ..layout();
  }

  double popupWidth(DepthChartStyle style) =>
      math.max(popupPricePainter.width, popupAmountPainter.width) +
      2 * style.padding;

  double popupHeight(DepthChartStyle style) =>
      popupPricePainter.height +
      popupAmountPainter.height +
      style.space +
      2 * style.padding;

  void paintPopup(Canvas canvas, Offset offset, DepthChartStyle style) {
    popupPricePainter.paint(
      canvas,
      offset + Offset(style.padding, style.padding),
    );
    popupAmountPainter.paint(
      canvas,
      offset +
          Offset(
            style.padding,
            popupPricePainter.height + style.space + style.padding,
          ),
    );
  }
}
