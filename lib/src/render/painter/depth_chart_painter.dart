import 'dart:math' as math;

import 'package:clean_k_chart/src/i18n/chart_translations.dart';
import 'package:clean_k_chart/src/model/entity/depth_entity.dart';
import 'package:clean_k_chart/src/render/dash_line.dart';
import 'package:clean_k_chart/src/render/depth_renderer_cache.dart';
import 'package:clean_k_chart/src/style/depth_chart_style.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart' show CustomPainter;

/// Painter for the depth (bid/ask cumulative volume) chart.
///
/// Owns no persistent render state — paints, paths and text painters
/// live in [DepthRendererCache] held by the widget and are re-targeted
/// each frame.
class DepthChartPainter extends CustomPainter {
  final List<DepthEntity> bids;
  final List<DepthEntity> asks;

  /// Long-press position; null while no press is active.
  final Offset? pressOffset;

  final int baseUnit;
  final int quoteUnit;
  final DepthChartColors chartColors;
  final DepthChartStyle chartStyle;
  final Offset offset;
  final ChartTranslations translations;
  final DepthRendererCache rendererCache;

  static const double _paddingBottom = 32.0;
  static const int _lineCount = 4;

  double _width = 0;
  double _drawHeight = 0;
  double _drawWidth = 0;
  double? _buyPointWidth;
  double? _sellPointWidth;

  /// Volume ceiling of the y axis (both sides share it); null without
  /// data.
  final double? _maxVolume;

  DepthChartPainter({
    required this.bids,
    required this.asks,
    required this.pressOffset,
    required this.baseUnit,
    required this.quoteUnit,
    required this.chartColors,
    required this.chartStyle,
    required this.offset,
    required this.translations,
    required this.rendererCache,
  }) : _maxVolume = _resolveMaxVolume(bids, asks);

  static double? _resolveMaxVolume(
    List<DepthEntity> bids,
    List<DepthEntity> asks,
  ) {
    if (bids.isEmpty || asks.isEmpty) return null;
    return math.max(bids.first.vol, asks.last.vol) * 1.08;
  }

  double get _volumeStep => _maxVolume! / _lineCount;

  bool get _hasData => bids.isNotEmpty && asks.isNotEmpty;

  @override
  void paint(Canvas canvas, Size size) {
    final maxVolume = _maxVolume;
    if (!_hasData || maxVolume == null || maxVolume <= 0) return;
    rendererCache.sync(chartColors: chartColors, chartStyle: chartStyle);
    _width = size.width;
    _drawWidth = _width / 2;
    _drawHeight = size.height - _paddingBottom;

    canvas.save();
    _drawBuy(canvas);
    _drawSell(canvas);
    _drawText(canvas);
    canvas.restore();
  }

  void _drawBuy(Canvas canvas) {
    final data = bids;
    _buyPointWidth = _drawWidth / (data.length - 1 == 0 ? 1 : data.length - 1);
    rendererCache.buyPath.reset();
    for (var i = 0; i < data.length; i++) {
      final x = _buyPointWidth! * i;
      final y = getY(data[i].vol);
      if (i == 0) {
        rendererCache.buyPath.moveTo(0, y);
      }
      if (i >= 1) {
        canvas.drawLine(
          Offset(_buyPointWidth! * (i - 1), getY(data[i - 1].vol)),
          Offset(x, y),
          rendererCache.buyLinePaint,
        );
      }
      if (i != data.length - 1) {
        rendererCache.buyPath.quadraticBezierTo(
          x,
          y,
          _buyPointWidth! * (i + 1),
          getY(data[i + 1].vol),
        );
      } else {
        if (i == 0) {
          rendererCache.buyPath
            ..lineTo(_drawWidth, y)
            ..lineTo(_drawWidth, _drawHeight)
            ..lineTo(0, _drawHeight);
        } else {
          rendererCache.buyPath
            ..quadraticBezierTo(x, y, x, _drawHeight)
            ..quadraticBezierTo(x, _drawHeight, 0, _drawHeight);
        }
        rendererCache.buyPath.close();
      }
    }
    canvas.drawPath(rendererCache.buyPath, rendererCache.buyFillPaint);
  }

  void _drawSell(Canvas canvas) {
    final data = asks;
    _sellPointWidth = _drawWidth / (data.length - 1 == 0 ? 1 : data.length - 1);
    rendererCache.sellPath.reset();
    for (var i = 0; i < data.length; i++) {
      final x = _sellPointWidth! * i + _drawWidth;
      final y = getY(data[i].vol);
      if (i == 0) {
        rendererCache.sellPath.moveTo(_drawWidth, y);
      }
      if (i >= 1) {
        canvas.drawLine(
          Offset(
            _sellPointWidth! * (i - 1) + _drawWidth,
            getY(data[i - 1].vol),
          ),
          Offset(x, y),
          rendererCache.sellLinePaint,
        );
      }
      if (i != data.length - 1) {
        rendererCache.sellPath.quadraticBezierTo(
          x,
          y,
          _sellPointWidth! * (i + 1) + _drawWidth,
          getY(data[i + 1].vol),
        );
      } else {
        if (i == 0) {
          rendererCache.sellPath
            ..lineTo(_width, y)
            ..lineTo(_width, _drawHeight)
            ..lineTo(_drawWidth, _drawHeight);
        } else {
          rendererCache.sellPath
            ..quadraticBezierTo(_width, y, x, _drawHeight)
            ..quadraticBezierTo(x, _drawHeight, _drawWidth, _drawHeight);
        }
        rendererCache.sellPath.close();
      }
    }
    canvas.drawPath(rendererCache.sellPath, rendererCache.sellFillPaint);
  }

  void _drawText(Canvas canvas) {
    final textStyle = TextStyle(
      color: chartColors.defaultTextColor,
      fontSize: 10,
    );

    for (var j = 0; j < _lineCount; j++) {
      final value = _maxVolume! - _volumeStep * j;
      final tp = _obtainText(
        NumberUtil.formatCompact(value, baseUnit),
        textStyle,
      );
      tp.paint(
        canvas,
        Offset(_width - tp.width, _drawHeight / _lineCount * j + tp.height / 2),
      );
    }

    final centerPrice = (bids.last.price + asks.first.price) / 2;

    _paintBottomText(
      canvas,
      NumberUtil.formatFixed(bids.first.price, quoteUnit) ?? '',
      0,
      textStyle,
    );
    _paintBottomText(
      canvas,
      NumberUtil.formatFixed(centerPrice, quoteUnit) ?? '',
      _drawWidth,
      textStyle,
      center: true,
    );
    _paintBottomText(
      canvas,
      NumberUtil.formatFixed(asks.last.price, quoteUnit) ?? '',
      _width,
      textStyle,
      alignEnd: true,
    );
    _paintBottomText(
      canvas,
      NumberUtil.formatFixed((bids.first.price + centerPrice) / 2, quoteUnit) ??
          '',
      _drawWidth / 2,
      textStyle,
      center: true,
    );
    _paintBottomText(
      canvas,
      NumberUtil.formatFixed((asks.last.price + centerPrice) / 2, quoteUnit) ??
          '',
      (_drawWidth + _width) / 2,
      textStyle,
      center: true,
    );

    final press = pressOffset;
    if (press == null) return;
    final dx = press.dx;
    if (dx <= _drawWidth) {
      final index = _indexAtX(dx, _buyPointWidth!, bids.length);
      _drawSelectView(canvas, isBuy: true, index: index);
      final mirroredIndex = bids.length - index - 1;
      if (mirroredIndex < asks.length) {
        _drawSelectView(canvas, isBuy: false, index: mirroredIndex);
      }
    } else {
      final index = _indexAtX(dx - _drawWidth, _sellPointWidth!, asks.length);
      _drawSelectView(canvas, isBuy: false, index: index);
      final mirroredIndex = bids.length - index - 1;
      if (mirroredIndex >= 0 && mirroredIndex < bids.length) {
        _drawSelectView(canvas, isBuy: true, index: mirroredIndex);
      }
    }
  }

  void _paintBottomText(
    Canvas canvas,
    String text,
    double anchorX,
    TextStyle style, {
    bool center = false,
    bool alignEnd = false,
  }) {
    final tp = _obtainText(text, style);
    final dx = center
        ? anchorX - tp.width / 2
        : alignEnd
        ? anchorX - tp.width
        : anchorX;
    tp.paint(canvas, Offset(dx, _bottomTextY(tp.height)));
  }

  TextPainter _obtainText(String text, TextStyle style) {
    return rendererCache.labelPainter
      ..text = TextSpan(text: text, style: style)
      ..layout();
  }

  void _drawSelectView(
    Canvas canvas, {
    required bool isBuy,
    required int index,
  }) {
    final data = isBuy ? bids : asks;
    final entity = data[index];
    final dx = isBuy ? getBuyX(index) : getSellX(index);
    final dy = getY(entity.vol);

    // Overlay barrier dimming the opposite half.
    canvas.drawRect(
      isBuy
          ? Rect.fromLTRB(0, 0, dx, _drawHeight)
          : Rect.fromLTRB(dx, 0, _width, _drawHeight),
      rendererCache.barrierPaint,
    );

    drawDashedLine(
      canvas,
      Offset(dx, 0),
      Offset(dx, _drawHeight),
      rendererCache.crossPaint,
      rendererCache.dashPath,
    );

    final linePaint = isBuy
        ? rendererCache.buyLinePaint
        : rendererCache.sellLinePaint;
    canvas.drawCircle(
      Offset(dx, dy),
      chartStyle.dotRadius * 0.6,
      rendererCache.dotPaint..color = linePaint.color,
    );
    canvas.drawCircle(Offset(dx, dy), chartStyle.dotRadius, linePaint);

    rendererCache.updatePopup(
      price:
          '${translations.price} '
          '${NumberUtil.format(entity.price, quoteUnit) ?? ''}',
      amount:
          '${translations.amount} '
          '${NumberUtil.formatCompact(entity.vol, baseUnit)}',
      textColor: chartColors.annotationColor,
    );

    final popupWidth = rendererCache.popupWidth(chartStyle);
    final popupHeight = rendererCache.popupHeight(chartStyle);
    final popupDx = dx < _width * (isBuy ? 0.25 : 0.75)
        ? dx + offset.dx
        : dx - offset.dx - popupWidth;
    // Clamp bounds must stay ordered — a popup taller than the drawable
    // area (very small chart) used to throw from clamp().
    var topBound = offset.dy;
    var bottomBound = _drawHeight - popupHeight - offset.dy;
    if (bottomBound < topBound) bottomBound = topBound;
    final popupDy = (dy - popupHeight / 2).clamp(topBound, bottomBound);

    final rect = Rect.fromLTWH(popupDx, popupDy, popupWidth, popupHeight);
    final boxRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(chartStyle.radius),
    );

    canvas.drawRRect(boxRect, rendererCache.selectFillPaint);
    canvas.drawRRect(boxRect, rendererCache.selectBorderPaint);
    rendererCache.paintPopup(canvas, rect.topLeft, chartStyle);
  }

  /// Index of the point at x [x] on a side whose points sit [pointWidth]
  /// apart (uniform grid — direct rounding, no search).
  int _indexAtX(double x, double pointWidth, int count) {
    if (count == 0 || pointWidth <= 0) return 0;
    return (x / pointWidth).round().clamp(0, count - 1);
  }

  double getBuyX(int position) => position * _buyPointWidth!;

  double getSellX(int position) => position * _sellPointWidth! + _drawWidth;

  double _bottomTextY(double textHeight) =>
      (_paddingBottom - textHeight) / 2 + _drawHeight;

  double getY(double volume) =>
      _drawHeight - _drawHeight * volume / _maxVolume!;

  @override
  bool shouldRepaint(DepthChartPainter oldDelegate) {
    return oldDelegate.bids != bids ||
        oldDelegate.asks != asks ||
        oldDelegate.pressOffset != pressOffset ||
        oldDelegate.baseUnit != baseUnit ||
        oldDelegate.quoteUnit != quoteUnit ||
        oldDelegate.offset != offset ||
        oldDelegate.chartColors != chartColors ||
        oldDelegate.chartStyle != chartStyle ||
        oldDelegate.translations != translations;
  }
}
