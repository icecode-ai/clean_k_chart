import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/model/entity/trend_line.dart';
import 'package:clean_k_chart/src/render/chart_dimension.dart';
import 'package:clean_k_chart/src/render/chart_viewport.dart';
import 'package:clean_k_chart/src/render/dash_line.dart';
import 'package:clean_k_chart/src/render/renderer_cache.dart';
import 'package:clean_k_chart/src/render/renderer/main_renderer.dart';
import 'package:clean_k_chart/src/render/text_painter_cache.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart';
import 'package:clean_k_chart/src/utils/date_format.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart' show CustomPainter;

/// Orchestrating CustomPainter for the K-line chart.
///
/// Owns no persistent render state — renderers, indicator painters and
/// label caches live in [ChartRendererCache] held by the widget; this
/// painter re-targets them each frame and draws the overlays
/// (crosshair, max/min markers, current price line, trend lines).
class ChartPainter extends CustomPainter {
  final KChartStyle chartStyle;
  final KChartColors chartColors;
  final IndicatorStyles indicatorStyles;
  final List<KLineEntity>? data;
  final ChartViewport viewport;
  final List<MainIndicator> mainIndicators;
  final List<SecondaryIndicator> secondaryIndicators;
  final ChartRendererCache rendererCache;
  final ChartDimension dimension;

  final bool volHidden;
  final bool isLine;
  final bool hideGrid;
  final bool showNowPrice;
  final bool tapShowInfoDialog;
  final int fixedLength;
  final VerticalTextAlignment verticalTextAlignment;

  /// Whether the crosshair (long-press or tap selection) is active.
  final bool showCrosshair;
  final double selectX;

  /// Trend-line mode and state.
  final bool trendLineEnabled;
  final List<TrendLine> trendLines;
  final double selectY;
  final int trendVersion;

  /// Main panel rect of the last paint; null before the first paint.
  /// Used by the widget for hit-testing.
  Rect? mainRect;

  // Snapshot values for shouldRepaint — [viewport] mutates in place.
  final double _scaleX;
  final double _scrollX;

  final TextPainterCache _textCache;
  final Paint _bgPaint = Paint();
  final Paint _crossPaint = Paint()..isAntiAlias = true;
  final Paint _selectPointPaint = Paint()..isAntiAlias = true;
  final Paint _selectBorderPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;
  final Paint _nowPriceLinePaint = Paint()..isAntiAlias = true;
  final Path _dashPath = Path();

  ChartPainter({
    required this.chartStyle,
    required this.chartColors,
    required this.indicatorStyles,
    required this.data,
    required this.viewport,
    required this.mainIndicators,
    required this.secondaryIndicators,
    required this.rendererCache,
    required this.dimension,
    required this.showCrosshair,
    required this.selectX,
    required this.trendLineEnabled,
    required this.trendLines,
    required this.selectY,
    required this.trendVersion,
    this.volHidden = false,
    this.isLine = false,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.tapShowInfoDialog = false,
    this.fixedLength = 2,
    this.verticalTextAlignment = VerticalTextAlignment.right,
  }) : _scaleX = viewport.scaleX,
       _scrollX = viewport.scrollX,
       _textCache = rendererCache.textCache {
    _bgPaint.color = chartColors.bgColor;
    _crossPaint
      ..color = chartColors.crossColor
      ..strokeWidth = chartStyle.crossWidth;
    _selectPointPaint.color = chartColors.selectFillColor;
    _selectBorderPaint
      ..color = chartColors.selectBorderColor
      ..strokeWidth = chartStyle.borderWidth;
    _nowPriceLinePaint.strokeWidth = chartStyle.nowPriceLineWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    viewport.width = size.width;

    final topPadding = chartStyle.topPadding + dimension.totalLabelHeight;
    final bottomPadding = chartStyle.bottomPadding;
    final childPadding = chartStyle.childPadding;
    final displayHeight = size.height - topPadding - bottomPadding;
    final volHeight = dimension.volumeHeight;
    final secondaryHeight = dimension.secondaryHeight;

    final mainHeight =
        displayHeight - volHeight - dimension.totalSecondaryHeight;
    final mainRect = Rect.fromLTRB(
      0,
      topPadding,
      size.width,
      topPadding + mainHeight,
    );
    final dateRect = Rect.fromLTRB(
      0,
      mainRect.bottom,
      size.width,
      mainRect.bottom + bottomPadding,
    );
    final volRect = volHidden
        ? null
        : Rect.fromLTRB(
            0,
            dateRect.bottom + childPadding,
            size.width,
            dateRect.bottom + volHeight,
          );
    final secondaryRects = <Rect>[
      for (var i = 0; i < secondaryIndicators.length; i++)
        Rect.fromLTRB(
          0,
          dateRect.bottom + volHeight + i * secondaryHeight + childPadding,
          size.width,
          dateRect.bottom + volHeight + i * secondaryHeight + secondaryHeight,
        ),
    ];
    this.mainRect = mainRect;

    rendererCache.sync(
      mainIndicators: mainIndicators,
      secondaryIndicators: secondaryIndicators,
      indicatorStyles: indicatorStyles,
      chartStyle: chartStyle,
      chartColors: chartColors,
      volHidden: volHidden,
      isLine: isLine,
      mainTopPadding: topPadding,
      panelTopPadding: childPadding,
      verticalTextAlignment: verticalTextAlignment,
    );

    final chartData = data;
    final hasData = chartData != null && chartData.isNotEmpty;
    var mainMaxValue = double.minPositive;
    var mainMinValue = double.maxFinite;
    var mainHighMaxValue = double.minPositive;
    var mainLowMinValue = double.maxFinite;
    var mainMaxIndex = 0;
    var mainMinIndex = 0;
    var volMaxValue = double.minPositive;
    var volMinValue = double.maxFinite;
    final secondaryMax = List<double>.filled(
      secondaryIndicators.length,
      double.minPositive,
    );
    final secondaryMin = List<double>.filled(
      secondaryIndicators.length,
      double.maxFinite,
    );

    if (hasData) {
      final start = viewport.startIndex;
      final stop = viewport.stopIndex;
      for (var i = start; i <= stop; i++) {
        final item = chartData[i];
        // Main panel: candle high/low plus every main indicator range.
        var maxPrice = item.high;
        var minPrice = item.low;
        for (final indicator in mainIndicators) {
          final range = indicator.getMaxMinValue(item, minPrice, maxPrice);
          minPrice = range.$1;
          maxPrice = range.$2;
        }
        mainMaxValue = mainMaxValue > maxPrice ? mainMaxValue : maxPrice;
        mainMinValue = mainMinValue < minPrice ? mainMinValue : minPrice;
        if (mainHighMaxValue < item.high) {
          mainHighMaxValue = item.high;
          mainMaxIndex = i;
        }
        if (mainLowMinValue > item.low) {
          mainLowMinValue = item.low;
          mainMinIndex = i;
        }
        if (isLine) {
          mainMaxValue = mainMaxValue > item.close ? mainMaxValue : item.close;
          mainMinValue = mainMinValue < item.close ? mainMinValue : item.close;
        }
        // Volume panel: bar height plus both MA lines.
        final ma5 = item.ma5Volume;
        final ma10 = item.ma10Volume;
        final volLineMax = _maxOf(item.vol, ma5, ma10);
        final volLineMin = _minOf(item.vol, ma5, ma10);
        volMaxValue = volMaxValue > volLineMax ? volMaxValue : volLineMax;
        volMinValue = volMinValue < volLineMin ? volMinValue : volLineMin;
        // Secondary panels.
        for (var s = 0; s < secondaryIndicators.length; s++) {
          final range = secondaryIndicators[s].getMaxMinValue(
            item,
            secondaryMin[s],
            secondaryMax[s],
          );
          secondaryMin[s] = range.$1;
          secondaryMax[s] = range.$2;
        }
      }
    }

    final mainRenderer = rendererCache.main!;
    mainRenderer.update(
      rect: mainRect,
      maxValue: hasData ? mainMaxValue : 0,
      minValue: hasData ? mainMinValue : 0,
      fixedLength: fixedLength,
    );
    final volRenderer = rendererCache.vol;
    if (volRenderer != null && volRect != null) {
      volRenderer.update(
        rect: volRect,
        maxValue: hasData ? volMaxValue : 0,
        minValue: hasData ? volMinValue : 0,
        fixedLength: fixedLength,
      );
    }
    final secondaryRenderers = rendererCache.secondary;
    for (var i = 0; i < secondaryRenderers.length; i++) {
      secondaryRenderers[i].update(
        rect: secondaryRects[i],
        maxValue: hasData ? secondaryMax[i] : 0,
        minValue: hasData ? secondaryMin[i] : 0,
        fixedLength: fixedLength,
      );
    }

    _drawBackground(
      canvas,
      mainRect,
      volRect,
      dateRect,
      secondaryRects,
      childPadding,
    );

    if (!hideGrid) {
      mainRenderer.drawGrid(canvas);
      volRenderer?.drawGrid(canvas);
      for (final renderer in secondaryRenderers) {
        renderer.drawGrid(canvas);
      }
    }

    if (!hasData) return;

    final startIndex = viewport.startIndex;
    final stopIndex = viewport.stopIndex;

    canvas.save();
    canvas.translate(viewport.translateX * viewport.scaleX, 0.0);
    canvas.scale(viewport.scaleX, 1.0);
    for (var i = startIndex; i <= stopIndex; i++) {
      final curPoint = chartData[i];
      final lastPoint = i == 0 ? curPoint : chartData[i - 1];
      final curX = viewport.getX(i);
      final lastX = i == 0 ? curX : viewport.getX(i - 1);
      mainRenderer.drawChart(
        lastPoint,
        curPoint,
        lastX,
        curX,
        canvas,
        scaleX: viewport.scaleX,
      );
      volRenderer?.drawChart(lastPoint, curPoint, lastX, curX, canvas);
      for (final renderer in secondaryRenderers) {
        renderer.drawChart(lastPoint, curPoint, lastX, curX, canvas);
      }
    }
    if (showCrosshair && !trendLineEnabled) {
      _drawCrossLine(canvas, size, viewport.selectedIndex(selectX));
    }
    canvas.restore();

    final textStyle = TextStyle(
      fontSize: 10,
      color: chartColors.defaultTextColor,
    );
    if (!hideGrid) {
      mainRenderer.drawVerticalText(canvas, textStyle);
    }
    volRenderer?.drawVerticalText(canvas, textStyle);
    for (final renderer in secondaryRenderers) {
      renderer.drawVerticalText(canvas, textStyle);
    }

    _drawDateAxis(canvas, size, dateRect, bottomPadding, chartData);

    final headerEntity = showCrosshair
        ? chartData[viewport.selectedIndex(selectX)]
        : chartData.last;
    mainRenderer.drawHeaderLabels(canvas, headerEntity, chartStyle.space);
    volRenderer?.drawHeaderLabels(canvas, headerEntity, chartStyle.space);
    for (final renderer in secondaryRenderers) {
      renderer.drawHeaderLabels(canvas, headerEntity, chartStyle.space);
    }

    _drawMaxMin(
      canvas,
      mainRenderer,
      mainMaxIndex,
      mainMinIndex,
      mainHighMaxValue,
      mainLowMinValue,
    );
    _drawNowPrice(
      canvas,
      size,
      mainRenderer,
      chartData,
      mainHighMaxValue,
      mainLowMinValue,
    );

    if (showCrosshair && !trendLineEnabled) {
      _drawCrossLineText(
        canvas,
        size,
        viewport.selectedIndex(selectX),
        dateRect,
      );
    }
    if (trendLineEnabled) {
      rendererCache.trendLineRenderer.draw(
        canvas,
        size,
        lines: trendLines,
        viewport: viewport,
        mainRenderer: mainRenderer,
        guideColor: chartColors.trendLineColor,
        lineColor: chartColors.trendLineColor,
        selectX: selectX,
        selectY: selectY,
        topPadding: topPadding,
      );
    }
  }

  void _drawBackground(
    Canvas canvas,
    Rect mainRect,
    Rect? volRect,
    Rect dateRect,
    List<Rect> secondaryRects,
    double childPadding,
  ) {
    canvas.drawRect(
      Rect.fromLTRB(0, 0, mainRect.width, mainRect.bottom),
      _bgPaint,
    );
    if (volRect != null) {
      canvas.drawRect(
        Rect.fromLTRB(
          0,
          volRect.top - childPadding,
          volRect.width,
          volRect.bottom,
        ),
        _bgPaint,
      );
    }
    for (final rect in secondaryRects) {
      canvas.drawRect(
        Rect.fromLTRB(0, rect.top - childPadding, rect.width, rect.bottom),
        _bgPaint,
      );
    }
    canvas.drawRect(dateRect, _bgPaint);
  }

  static double _maxOf(double a, double? b, double? c) {
    var result = a;
    if (b != null && b > result) result = b;
    if (c != null && c > result) result = c;
    return result;
  }

  static double _minOf(double a, double? b, double? c) {
    var result = a;
    if (b != null && b < result) result = b;
    if (c != null && c < result) result = c;
    return result;
  }

  void _drawCrossLine(Canvas canvas, Size size, int index) {
    final point = data![index];
    final x = viewport.getX(index);
    final y = rendererCache.main!.getY(point.close);

    drawDashedLine(
      canvas,
      Offset(x, 0),
      Offset(x, size.height),
      _crossPaint,
      _dashPath,
    );
    drawDashedLine(
      canvas,
      Offset(-viewport.translateX, y),
      Offset(-viewport.translateX + size.width / viewport.scaleX, y),
      _crossPaint,
      _dashPath,
    );

    final oval = viewport.scaleX >= 1
        ? Rect.fromCenter(
            center: Offset(x, y),
            height: 4.0 * viewport.scaleX,
            width: 4.0,
          )
        : Rect.fromCenter(
            center: Offset(x, y),
            height: 4.0,
            width: 4.0 / viewport.scaleX,
          );
    canvas.drawOval(oval, _crossPaint);
  }

  void _drawCrossLineText(Canvas canvas, Size size, int index, Rect dateRect) {
    final point = data![index];
    const w1 = 5.0, w2 = 3.0, space = 4.0;

    final tp = _textCache.obtain(
      NumberUtil.formatFixed(point.close, fixedLength) ?? '',
      TextStyle(fontSize: 10, color: chartColors.crossTextColor),
    );
    final textHeight = tp.height;
    final r = textHeight / 2 + w2;
    final y = rendererCache.main!.getY(point.close);
    final pointOnLeft =
        viewport.dataXToX(viewport.getX(index)) < size.width / 2;

    final double bubbleLeft;
    if (pointOnLeft) {
      bubbleLeft = space;
    } else {
      bubbleLeft = size.width - tp.width - 2 * w1 - space;
    }
    final bubbleRect = RRect.fromLTRBR(
      bubbleLeft,
      y - r,
      bubbleLeft + tp.width + 2 * w1,
      y + r,
      const Radius.circular(2.0),
    );
    canvas.drawRRect(bubbleRect, _selectPointPaint);
    canvas.drawRRect(bubbleRect, _selectBorderPaint);
    tp.paint(canvas, Offset(bubbleLeft + w1, y - textHeight / 2));

    final dateTp = _textCache.obtain(
      _formatDate(point.time),
      TextStyle(fontSize: 10, color: chartColors.crossTextColor),
    );
    final dateWidth = dateTp.width;
    var x = viewport.dataXToX(viewport.getX(index));
    if (x < dateWidth + 2 * w1) {
      x = 1 + dateWidth / 2 + w1;
    } else if (size.width - x < dateWidth + 2 * w1) {
      x = size.width - 1 - dateWidth / 2 - w1;
    }
    final dateBubble = RRect.fromLTRBR(
      x - dateWidth / 2 - w1,
      dateRect.top,
      x + dateWidth / 2 + w1,
      dateRect.bottom,
      const Radius.circular(2.0),
    );
    canvas.drawRRect(dateBubble, _selectPointPaint);
    canvas.drawRRect(dateBubble, _selectBorderPaint);
    dateTp.paint(
      canvas,
      Offset(
        x - dateWidth / 2,
        dateRect.top + (dateRect.height - dateTp.height) / 2,
      ),
    );
  }

  void _drawDateAxis(
    Canvas canvas,
    Size size,
    Rect dateRect,
    double bottomPadding,
    List<KLineEntity> chartData,
  ) {
    final columns = chartStyle.gridColumns;
    final columnSpace = size.width / columns;
    final startX = viewport.getX(viewport.startIndex) - viewport.pointWidth / 2;
    final stopX = viewport.getX(viewport.stopIndex) + viewport.pointWidth / 2;
    final textStyle = TextStyle(
      fontSize: 10,
      color: chartColors.defaultTextColor,
    );

    for (var i = 0; i <= columns; i++) {
      final dataX = viewport.xToDataX(columnSpace * i);
      if (dataX < startX || dataX > stopX) continue;
      final index = viewport.indexOfDataX(dataX);
      if (index < 0 || index >= chartData.length) continue;
      final tp = _textCache.obtain(
        _formatDate(chartData[index].time),
        textStyle,
      );
      var x = columnSpace * i - tp.width / 2;
      final y = dateRect.top + (bottomPadding - tp.height) / 2;
      if (x < 0) x = 0;
      if (x > size.width - tp.width) x = size.width - tp.width;
      tp.paint(canvas, Offset(x, y));
    }
  }

  void _drawMaxMin(
    Canvas canvas,
    MainRenderer mainRenderer,
    int maxIndex,
    int minIndex,
    double highMax,
    double lowMin,
  ) {
    if (isLine) return;
    final width = viewport.width;

    var x = viewport.dataXToX(viewport.getX(minIndex));
    var y = mainRenderer.getY(lowMin);
    if (x < width / 2) {
      final tp = _textCache.obtain(
        '── ${NumberUtil.formatFixed(lowMin, fixedLength) ?? ''}',
        TextStyle(fontSize: 10, color: chartColors.minColor),
      );
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      final tp = _textCache.obtain(
        '${NumberUtil.formatFixed(lowMin, fixedLength) ?? ''} ──',
        TextStyle(fontSize: 10, color: chartColors.minColor),
      );
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }

    x = viewport.dataXToX(viewport.getX(maxIndex));
    y = mainRenderer.getY(highMax);
    if (x < width / 2) {
      final tp = _textCache.obtain(
        '── ${NumberUtil.formatFixed(highMax, fixedLength) ?? ''}',
        TextStyle(fontSize: 10, color: chartColors.maxColor),
      );
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      final tp = _textCache.obtain(
        '${NumberUtil.formatFixed(highMax, fixedLength) ?? ''} ──',
        TextStyle(fontSize: 10, color: chartColors.maxColor),
      );
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
  }

  void _drawNowPrice(
    Canvas canvas,
    Size size,
    MainRenderer mainRenderer,
    List<KLineEntity> chartData,
    double highMax,
    double lowMin,
  ) {
    if (!showNowPrice) return;
    final value = chartData.last.close;
    var y = mainRenderer.getY(value);
    // Clamp into the visible value window.
    final yLow = mainRenderer.getY(lowMin);
    final yHigh = mainRenderer.getY(highMax);
    if (y > yLow) y = yLow;
    if (y < yHigh) y = yHigh;

    final priceColor = value >= chartData.last.open
        ? chartColors.nowPriceUpColor
        : chartColors.nowPriceDnColor;
    _nowPriceLinePaint.color = priceColor;

    drawDashedLine(
      canvas,
      Offset(0, y),
      Offset(-viewport.translateX + size.width / viewport.scaleX, y),
      _nowPriceLinePaint,
      _dashPath,
    );
  }

  String _formatDate(int? milliseconds) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      milliseconds ?? DateTime.now().millisecondsSinceEpoch,
    );
    final pattern =
        chartStyle.datePattern ??
        (data != null && data!.length > 1
            ? pickDatePattern((data![1].time ?? 0) - (data!.first.time ?? 0))
            : 'MM-dd HH:mm');
    return dateFormat(pattern).format(dateTime);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate._scaleX != _scaleX ||
        oldDelegate._scrollX != _scrollX ||
        oldDelegate.selectX != selectX ||
        oldDelegate.selectY != selectY ||
        oldDelegate.showCrosshair != showCrosshair ||
        oldDelegate.trendLineEnabled != trendLineEnabled ||
        oldDelegate.trendVersion != trendVersion ||
        oldDelegate.trendLines.length != trendLines.length ||
        oldDelegate.mainIndicators != mainIndicators ||
        oldDelegate.secondaryIndicators != secondaryIndicators ||
        oldDelegate.indicatorStyles != indicatorStyles ||
        oldDelegate.chartStyle != chartStyle ||
        oldDelegate.chartColors != chartColors ||
        oldDelegate.volHidden != volHidden ||
        oldDelegate.isLine != isLine ||
        oldDelegate.hideGrid != hideGrid ||
        oldDelegate.showNowPrice != showNowPrice ||
        oldDelegate.tapShowInfoDialog != tapShowInfoDialog ||
        oldDelegate.fixedLength != fixedLength ||
        oldDelegate.verticalTextAlignment != verticalTextAlignment;
  }
}
