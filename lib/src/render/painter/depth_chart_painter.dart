import 'dart:math' as math;

import 'package:clean_k_chart/src/i18n/chart_translations.dart';
import 'package:clean_k_chart/src/model/entity/depth_entity.dart';
import 'package:clean_k_chart/src/render/dash_line.dart';
import 'package:clean_k_chart/src/style/depth_chart_style.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart' show CustomPainter;

/// Painter for the depth (bid/ask cumulative volume) chart.
class DepthChartPainter extends CustomPainter {
  final List<DepthEntity>? bids;
  final List<DepthEntity>? asks;
  final Offset? pressOffset;
  final bool isLongPress;
  final int baseUnit;
  final int quoteUnit;
  final DepthChartColors chartColors;
  final DepthChartStyle chartStyle;
  final Offset offset;
  final ChartTranslations translations;

  static const double _paddingBottom = 32.0;
  static const int _lineCount = 4;

  double _width = 0;
  double _drawHeight = 0;
  double _drawWidth = 0;
  double? _buyPointWidth;
  double? _sellPointWidth;
  double? _maxVolume;
  double? _volumeStep;

  final Paint _buyLinePaint = Paint()..isAntiAlias = true;
  final Paint _sellLinePaint = Paint()..isAntiAlias = true;
  final Paint _buyFillPaint = Paint()..isAntiAlias = true;
  final Paint _sellFillPaint = Paint()..isAntiAlias = true;
  final Paint _barrierPaint = Paint()..isAntiAlias = true;
  final Paint _crossPaint = Paint()..isAntiAlias = true;
  final Paint _selectFillPaint = Paint()..isAntiAlias = true;
  final Paint _selectBorderPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;

  final Path _buyPath = Path();
  final Path _sellPath = Path();
  final Path _dashPath = Path();
  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
  );

  DepthChartPainter({
    required this.bids,
    required this.asks,
    required this.pressOffset,
    required this.isLongPress,
    required this.baseUnit,
    required this.quoteUnit,
    required this.chartColors,
    required this.chartStyle,
    required this.offset,
    required this.translations,
  }) {
    _buyLinePaint
      ..color = chartColors.upColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = chartStyle.lineWidth;
    _sellLinePaint
      ..color = chartColors.dnColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = chartStyle.lineWidth;
    _buyFillPaint.color = chartColors.upFillPathColor;
    _sellFillPaint.color = chartColors.dnFillPathColor;
    _barrierPaint.color = chartColors.barrierColor;
    _crossPaint
      ..strokeWidth = chartStyle.crossWidth
      ..color = chartColors.crossColor;
    _selectFillPaint.color = chartColors.selectFillColor;
    _selectBorderPaint
      ..color = chartColors.selectBorderColor
      ..strokeWidth = chartStyle.strokeWidth;

    final buyData = bids;
    final sellData = asks;
    if (buyData == null ||
        sellData == null ||
        buyData.isEmpty ||
        sellData.isEmpty) {
      return;
    }
    _maxVolume = math.max(buyData.first.vol, sellData.last.vol) * 1.08;
    _volumeStep = _maxVolume! / _lineCount;
  }

  bool get _hasData =>
      bids != null && asks != null && bids!.isNotEmpty && asks!.isNotEmpty;

  @override
  void paint(Canvas canvas, Size size) {
    if (!_hasData || _maxVolume == null || _maxVolume! <= 0) return;
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
    final data = bids!;
    _buyPointWidth = _drawWidth / (data.length - 1 == 0 ? 1 : data.length - 1);
    _buyPath.reset();
    for (var i = 0; i < data.length; i++) {
      final x = _buyPointWidth! * i;
      final y = getY(data[i].vol);
      if (i == 0) {
        _buyPath.moveTo(0, y);
      }
      if (i >= 1) {
        canvas.drawLine(
          Offset(_buyPointWidth! * (i - 1), getY(data[i - 1].vol)),
          Offset(x, y),
          _buyLinePaint,
        );
      }
      if (i != data.length - 1) {
        _buyPath.quadraticBezierTo(
          x,
          y,
          _buyPointWidth! * (i + 1),
          getY(data[i + 1].vol),
        );
      } else {
        if (i == 0) {
          _buyPath
            ..lineTo(_drawWidth, y)
            ..lineTo(_drawWidth, _drawHeight)
            ..lineTo(0, _drawHeight);
        } else {
          _buyPath
            ..quadraticBezierTo(x, y, x, _drawHeight)
            ..quadraticBezierTo(x, _drawHeight, 0, _drawHeight);
        }
        _buyPath.close();
      }
    }
    canvas.drawPath(_buyPath, _buyFillPaint);
  }

  void _drawSell(Canvas canvas) {
    final data = asks!;
    _sellPointWidth = _drawWidth / (data.length - 1 == 0 ? 1 : data.length - 1);
    _sellPath.reset();
    for (var i = 0; i < data.length; i++) {
      final x = _sellPointWidth! * i + _drawWidth;
      final y = getY(data[i].vol);
      if (i == 0) {
        _sellPath.moveTo(_drawWidth, y);
      }
      if (i >= 1) {
        canvas.drawLine(
          Offset(
            _sellPointWidth! * (i - 1) + _drawWidth,
            getY(data[i - 1].vol),
          ),
          Offset(x, y),
          _sellLinePaint,
        );
      }
      if (i != data.length - 1) {
        _sellPath.quadraticBezierTo(
          x,
          y,
          _sellPointWidth! * (i + 1) + _drawWidth,
          getY(data[i + 1].vol),
        );
      } else {
        if (i == 0) {
          _sellPath
            ..lineTo(_width, y)
            ..lineTo(_width, _drawHeight)
            ..lineTo(_drawWidth, _drawHeight);
        } else {
          _sellPath
            ..quadraticBezierTo(_width, y, x, _drawHeight)
            ..quadraticBezierTo(x, _drawHeight, _drawWidth, _drawHeight);
        }
        _sellPath.close();
      }
    }
    canvas.drawPath(_sellPath, _sellFillPaint);
  }

  void _drawText(Canvas canvas) {
    final textStyle = TextStyle(
      color: chartColors.defaultTextColor,
      fontSize: 10,
    );

    for (var j = 0; j < _lineCount; j++) {
      final value = _maxVolume! - _volumeStep! * j;
      final tp = _obtainText(
        NumberUtil.formatCompact(value, baseUnit),
        textStyle,
      );
      tp.paint(
        canvas,
        Offset(_width - tp.width, _drawHeight / _lineCount * j + tp.height / 2),
      );
    }

    final centerPrice = (bids!.last.price + asks!.first.price) / 2;

    _paintBottomText(
      canvas,
      NumberUtil.formatFixed(bids!.first.price, quoteUnit) ?? '',
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
      NumberUtil.formatFixed(asks!.last.price, quoteUnit) ?? '',
      _width,
      textStyle,
      alignEnd: true,
    );
    _paintBottomText(
      canvas,
      NumberUtil.formatFixed(
            (bids!.first.price + centerPrice) / 2,
            quoteUnit,
          ) ??
          '',
      _drawWidth / 2,
      textStyle,
      center: true,
    );
    _paintBottomText(
      canvas,
      NumberUtil.formatFixed((asks!.last.price + centerPrice) / 2, quoteUnit) ??
          '',
      (_drawWidth + _width) / 2,
      textStyle,
      center: true,
    );

    if (isLongPress && pressOffset != null) {
      final dx = pressOffset!.dx;
      if (dx <= _drawWidth) {
        final index = _indexOfX(dx, 0, bids!.length - 1, getBuyX);
        _drawSelectView(canvas, isBuy: true, index: index);
        final mirroredIndex = bids!.length - index - 1;
        if (mirroredIndex < asks!.length) {
          _drawSelectView(canvas, isBuy: false, index: mirroredIndex);
        }
      } else {
        final index = _indexOfX(dx, 0, asks!.length - 1, getSellX);
        _drawSelectView(canvas, isBuy: false, index: index);
        final mirroredIndex = bids!.length - index - 1;
        if (mirroredIndex >= 0 && mirroredIndex < bids!.length) {
          _drawSelectView(canvas, isBuy: true, index: mirroredIndex);
        }
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
    return _textPainter
      ..text = TextSpan(text: text, style: style)
      ..layout();
  }

  void _drawSelectView(
    Canvas canvas, {
    required bool isBuy,
    required int index,
  }) {
    final data = isBuy ? bids! : asks!;
    final entity = data[index];
    final dx = isBuy ? getBuyX(index) : getSellX(index);
    final dy = getY(entity.vol);

    // Overlay barrier dimming the opposite half.
    canvas.drawRect(
      isBuy
          ? Rect.fromLTRB(0, 0, dx, _drawHeight)
          : Rect.fromLTRB(dx, 0, _width, _drawHeight),
      _barrierPaint,
    );

    drawDashedLine(
      canvas,
      Offset(dx, 0),
      Offset(dx, _drawHeight),
      _crossPaint,
      _dashPath,
    );

    final linePaint = isBuy ? _buyLinePaint : _sellLinePaint;
    canvas.drawCircle(
      Offset(dx, dy),
      chartStyle.dotRadius * 0.6,
      linePaint..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(dx, dy),
      chartStyle.dotRadius,
      linePaint..style = PaintingStyle.stroke,
    );

    _PopupPainter popupPainter = _PopupPainter(
      translations: translations,
      chartColors: chartColors,
      chartStyle: chartStyle,
      price: NumberUtil.format(entity.price, quoteUnit) ?? '',
      amount: NumberUtil.formatCompact(entity.vol, baseUnit),
    );

    final popupDx = dx < _width * (isBuy ? 0.25 : 0.75)
        ? dx + offset.dx
        : dx - offset.dx - popupPainter.width;
    final popupDy = (dy - popupPainter.height / 2).clamp(
      offset.dy,
      _drawHeight - popupPainter.height - offset.dy,
    );

    final rect = Rect.fromLTWH(
      popupDx,
      popupDy,
      popupPainter.width,
      popupPainter.height,
    );
    final boxRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(chartStyle.radius),
    );

    canvas.drawRRect(boxRect, _selectFillPaint);
    canvas.drawRRect(boxRect, _selectBorderPaint);
    popupPainter.paint(canvas, rect.topLeft);
  }

  int _indexOfX(
    double targetX,
    int start,
    int end,
    double Function(int position) getX,
  ) {
    if (end == start || end == -1) {
      return start;
    }
    if (end - start == 1) {
      final startValue = getX(start);
      final endValue = getX(end);
      return (targetX - startValue).abs() < (targetX - endValue).abs()
          ? start
          : end;
    }
    final mid = start + (end - start) ~/ 2;
    final midValue = getX(mid);
    if (targetX < midValue) {
      return _indexOfX(targetX, start, mid, getX);
    } else if (targetX > midValue) {
      return _indexOfX(targetX, mid, end, getX);
    }
    return mid;
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
        oldDelegate.isLongPress != isLongPress ||
        oldDelegate.chartColors != chartColors ||
        oldDelegate.chartStyle != chartStyle ||
        oldDelegate.translations != translations;
  }
}

class _PopupPainter {
  final DepthChartColors chartColors;
  final DepthChartStyle chartStyle;

  final TextPainter _pricePainter;
  final TextPainter _amountPainter;

  double get width =>
      math.max(_pricePainter.width, _amountPainter.width) +
      2 * chartStyle.padding;

  double get height =>
      _pricePainter.height +
      _amountPainter.height +
      chartStyle.space +
      2 * chartStyle.padding;

  _PopupPainter({
    required ChartTranslations translations,
    required this.chartColors,
    required this.chartStyle,
    required String price,
    required String amount,
  }) : _pricePainter = _getTextPainter(
         '${translations.price} $price',
         chartColors.annotationColor,
       ),
       _amountPainter = _getTextPainter(
         '${translations.amount} $amount',
         chartColors.annotationColor,
       ) {
    _pricePainter.layout();
    _amountPainter.layout();
  }

  void paint(Canvas canvas, Offset offset) {
    _pricePainter.paint(
      canvas,
      offset + Offset(chartStyle.padding, chartStyle.padding),
    );
    _amountPainter.paint(
      canvas,
      offset +
          Offset(
            chartStyle.padding,
            _pricePainter.height + chartStyle.space + chartStyle.padding,
          ),
    );
  }

  static TextPainter _getTextPainter(String text, Color color) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    );
  }
}
