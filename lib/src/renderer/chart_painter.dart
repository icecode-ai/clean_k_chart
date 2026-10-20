import 'package:clean_k_chart/src/entity/info_window_entity.dart';
import 'package:clean_k_chart/src/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/extension/canvas_extension.dart';
import 'package:clean_k_chart/src/renderer/base_chart_painter.dart';
import 'package:clean_k_chart/src/renderer/base_chart_renderer.dart';
import 'package:clean_k_chart/src/renderer/main_renderer.dart';
import 'package:clean_k_chart/src/renderer/secondary_renderer.dart';
import 'package:clean_k_chart/src/renderer/vol_renderer.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:clean_k_chart/src/utils/date_format_util.dart';
import 'package:clean_k_chart/src/utils/number_util.dart';
import 'package:flutter/painting.dart';

/// Called whenever the currently focused candle changes while the user is
/// long-pressing (or tapping) the chart. A `null` value means no selection.
typedef OnInfoWindowChanged = void Function(InfoWindowEntity? info);

class ChartPainter extends BaseChartPainter {
  late BaseChartRenderer mMainRenderer;

  BaseChartRenderer? mVolRenderer;

  Set<BaseChartRenderer> mSecondaryRendererList = {};

  int fixedLength;

  final KChartColors chartColors;

  late Paint paintCross, selectPointPaint, selectorBorderPaint;
  late Paint nowPriceLinePaint;

  final bool hideGrid;
  final bool showNowPrice;
  final VerticalTextAlignment verticalTextAlignment;

  /// Notified when the focused candle changes. Deduplicated by the widget so
  /// identical selections do not trigger extra rebuilds.
  final OnInfoWindowChanged onInfoWindow;

  ChartPainter(
    super.chartStyle,
    this.chartColors, {
    required this.onInfoWindow,
    required super.datas,
    required super.scaleX,
    required super.scrollX,
    required super.isLongPress,
    required super.selectX,
    required super.xFrontPadding,
    required super.baseDimension,
    super.isOnTap,
    super.isTapShowInfoDialog,
    super.mainIndicators,
    super.volHidden,
    super.secondaryIndicators,
    super.isLine,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.fixedLength = 2,
    this.verticalTextAlignment = VerticalTextAlignment.right,
  }) {
    paintCross = Paint()
      ..color = chartColors.crossColor
      ..strokeWidth = chartStyle.crossWidth
      ..isAntiAlias = true;

    selectPointPaint = Paint()
      ..isAntiAlias = true
      ..color = chartColors.selectFillColor;

    selectorBorderPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = chartStyle.borderWidth
      ..style = PaintingStyle.stroke
      ..color = chartColors.selectBorderColor;

    nowPriceLinePaint = Paint()
      ..strokeWidth = chartStyle.nowPriceLineWidth
      ..isAntiAlias = true;
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return oldDelegate.datas != datas ||
        oldDelegate.scaleX != scaleX ||
        oldDelegate.scrollX != scrollX ||
        oldDelegate.selectX != selectX ||
        oldDelegate.isLongPress != isLongPress ||
        oldDelegate.isOnTap != isOnTap ||
        oldDelegate.isTapShowInfoDialog != isTapShowInfoDialog ||
        oldDelegate.isLine != isLine ||
        oldDelegate.mainIndicators != mainIndicators ||
        oldDelegate.secondaryIndicators != secondaryIndicators ||
        oldDelegate.volHidden != volHidden ||
        oldDelegate.xFrontPadding != xFrontPadding ||
        oldDelegate.baseDimension != baseDimension ||
        oldDelegate.chartStyle != chartStyle ||
        oldDelegate.chartColors != chartColors ||
        oldDelegate.hideGrid != hideGrid ||
        oldDelegate.showNowPrice != showNowPrice ||
        oldDelegate.fixedLength != fixedLength ||
        oldDelegate.verticalTextAlignment != verticalTextAlignment;
  }

  @override
  void initChartRenderer() {
    mMainRenderer = MainRenderer(
      mMainRect,
      mMainMaxValue,
      mMainMinValue,
      mTopPadding,
      mainIndicators,
      isLine,
      fixedLength,
      chartStyle,
      chartColors,
      scaleX,
      verticalTextAlignment,
      mBottomPadding,
    );

    if (mVolRect != null) {
      mVolRenderer = VolRenderer(
        mVolRect!,
        mVolMaxValue,
        mVolMinValue,
        mChildPadding,
        fixedLength,
        chartStyle,
        chartColors,
      );
    }

    mSecondaryRendererList.clear();

    for (int i = 0; i < mSecondaryRectList.length; ++i) {
      mSecondaryRendererList.add(
        SecondaryRenderer(
          mSecondaryRectList[i].mRect,
          mSecondaryRectList[i].mMaxValue,
          mSecondaryRectList[i].mMinValue,
          mChildPadding,
          secondaryIndicators[i],
          fixedLength,
          chartStyle,
          chartColors,
        ),
      );
    }
  }

  @override
  void drawBg(Canvas canvas, Size size) {
    final Paint mBgPaint = Paint()..color = chartColors.bgColor;

    final Rect mainRect = Rect.fromLTRB(
      0,
      0,
      mMainRect.width,
      mMainRect.height + mTopPadding,
    );

    canvas.drawRect(mainRect, mBgPaint);

    if (mVolRect != null) {
      final Rect volRect = Rect.fromLTRB(
        0,
        mVolRect!.top - mChildPadding,
        mVolRect!.width,
        mVolRect!.bottom,
      );

      canvas.drawRect(volRect, mBgPaint);
    }

    for (int i = 0; i < mSecondaryRectList.length; ++i) {
      Rect? mSecondaryRect = mSecondaryRectList[i].mRect;

      final Rect secondaryRect = Rect.fromLTRB(
        0,
        mSecondaryRect.top - mChildPadding,
        mSecondaryRect.width,
        mSecondaryRect.bottom,
      );

      canvas.drawRect(secondaryRect, mBgPaint);
    }

    canvas.drawRect(mDateRect, mBgPaint);
  }

  @override
  void drawGrid(canvas) {
    if (!hideGrid) {
      mMainRenderer.drawGrid(canvas, mGridRows, mGridColumns);
      mVolRenderer?.drawGrid(canvas, mGridRows, mGridColumns);

      for (var element in mSecondaryRendererList) {
        element.drawGrid(canvas, mGridRows, mGridColumns);
      }
    }
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(mTranslateX * scaleX, 0.0);
    canvas.scale(scaleX, 1.0);

    final List<KLineEntity>? data = datas;
    for (int i = mStartIndex; data != null && i <= mStopIndex; i++) {
      final KLineEntity curPoint = data[i];
      final KLineEntity lastPoint = i == 0 ? curPoint : data[i - 1];

      double curX = getX(i);
      double lastX = i == 0 ? curX : getX(i - 1);

      mMainRenderer.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      mVolRenderer?.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);

      for (var element in mSecondaryRendererList) {
        element.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      }
    }

    if ((isLongPress == true || (isTapShowInfoDialog && isOnTap))) {
      drawCrossLine(canvas, size);
    }

    canvas.restore();
  }

  @override
  void drawVerticalText(canvas) {
    final TextStyle textStyle = getTextStyle(chartColors.defaultTextColor);
    if (!hideGrid) {
      mMainRenderer.drawVerticalText(canvas, textStyle, mGridRows);
    }

    mVolRenderer?.drawVerticalText(canvas, textStyle, mGridRows);

    for (var element in mSecondaryRendererList) {
      element.drawVerticalText(canvas, textStyle, mGridRows);
    }
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    if (datas == null) {
      return;
    }

    final double columnSpace = size.width / mGridColumns;
    final double startX = getX(mStartIndex) - mPointWidth / 2;
    final double stopX = getX(mStopIndex) + mPointWidth / 2;

    double x = 0.0;
    double y = 0.0;

    for (var i = 0; i <= mGridColumns; ++i) {
      double translateX = xToTranslateX(columnSpace * i);

      if (translateX >= startX && translateX <= stopX) {
        final int index = indexOfTranslateX(translateX);
        if (datas?[index] == null) {
          continue;
        }

        final TextPainter tp = getTextPainter(
          getDate(datas![index].time),
          null,
        );

        y = mDateRect.top + (mBottomPadding - tp.height) / 2;
        x = columnSpace * i - tp.width / 2;

        // Prevent date text out of canvas
        if (x < 0) {
          x = 0;
        }

        if (x > size.width - tp.width) {
          x = size.width - tp.width;
        }

        tp.paint(canvas, Offset(x, y));
        tp.dispose();
      }
    }
  }

  /// draw the cross line. when user focus
  @override
  void drawCrossLineText(Canvas canvas, Size size) {
    final index = calculateSelectedX(selectX);
    final KLineEntity point = getItem(index);

    final TextPainter tp = getTextPainter(
      NumberUtil.formatFixed(point.close, fixedLength),
      chartColors.crossTextColor,
    );

    final double textHeight = tp.height;
    double textWidth = tp.width;

    double w1 = 5;
    double w2 = 3;
    double r = textHeight / 2 + w2;
    double y = getMainY(point.close);
    double x;
    double space = 4.0;
    bool isLeft = false;

    if (translateXtoX(getX(index)) < mWidth / 2) {
      isLeft = false;
      x = space;

      final RRect rect = RRect.fromLTRBR(
        x,
        y - r,
        x + textWidth + 2 * w1,
        y + r,
        const Radius.circular(2.0),
      );

      canvas.drawRRect(rect, selectPointPaint);
      canvas.drawRRect(rect, selectorBorderPaint);

      tp.paint(canvas, Offset(x + w1, y - textHeight / 2));
    } else {
      isLeft = true;
      x = mWidth - textWidth - 2 * w1 - space;

      final RRect rect = RRect.fromLTRBR(
        x,
        y - r,
        mWidth - space,
        y + r,
        const Radius.circular(2.0),
      );

      canvas.drawRRect(rect, selectPointPaint);
      canvas.drawRRect(rect, selectorBorderPaint);

      tp.paint(canvas, Offset(x + w1, y - textHeight / 2));
    }

    tp.dispose();

    final TextPainter dateTp = getTextPainter(
      getDate(point.time),
      chartColors.crossTextColor,
    );

    textWidth = dateTp.width;
    r = textHeight / 2;
    x = translateXtoX(getX(index));
    y = mDateRect.top;

    if (x < textWidth + 2 * w1) {
      x = 1 + textWidth / 2 + w1;
    } else if (mWidth - x < textWidth + 2 * w1) {
      x = mWidth - 1 - textWidth / 2 - w1;
    }

    RRect rectBox = RRect.fromLTRBR(
      x - textWidth / 2 - w1,
      y,
      x + textWidth / 2 + w1,
      mDateRect.bottom,
      const Radius.circular(2.0),
    );

    // double baseLine = textHeight / 2;
    canvas.drawRRect(rectBox, selectPointPaint);
    canvas.drawRRect(rectBox, selectorBorderPaint);

    dateTp.paint(
      canvas,
      Offset(
        x - textWidth / 2,
        mDateRect.top + (mDateRect.height - dateTp.height) / 2,
      ),
    );
    dateTp.dispose();

    //Long press to display the details of this data
    onInfoWindow(InfoWindowEntity(point, isLeft: isLeft));
  }

  @override
  void drawText(Canvas canvas, KLineEntity data, double x) {
    //Long press to display the data in the press
    if (isLongPress || (isTapShowInfoDialog && isOnTap)) {
      final index = calculateSelectedX(selectX);

      data = getItem(index);
    }

    //Release to display the last data
    mMainRenderer.drawText(canvas, data, x);
    mVolRenderer?.drawText(canvas, data, x);

    for (var element in mSecondaryRendererList) {
      element.drawText(canvas, data, x);
    }
  }

  @override
  void drawMaxAndMin(Canvas canvas) {
    if (isLine == true) {
      return;
    }

    //plot maxima and minima
    double x = translateXtoX(getX(mMainMinIndex));
    double y = getMainY(mMainLowMinValue);
    _drawMinMaxText(canvas, x, y, mMainLowMinValue, chartColors.minColor);

    x = translateXtoX(getX(mMainMaxIndex));
    y = getMainY(mMainHighMaxValue);
    _drawMinMaxText(canvas, x, y, mMainHighMaxValue, chartColors.maxColor);
  }

  void _drawMinMaxText(
    Canvas canvas,
    double x,
    double y,
    double value,
    Color color,
  ) {
    final String formatted = NumberUtil.formatFixed(value, fixedLength) ?? '';
    final bool alignLeft = x < mWidth / 2;
    final String text = alignLeft ? "── $formatted" : "$formatted ──";

    final TextPainter tp = getTextPainter(text, color);
    tp.paint(canvas, Offset(alignLeft ? x : x - tp.width, y - tp.height / 2));
    tp.dispose();
  }

  @override
  void drawNowPrice(Canvas canvas) {
    final List<KLineEntity>? data = datas;
    if (!showNowPrice || data == null || data.isEmpty) {
      return;
    }

    final KLineEntity last = data.last;
    final double value = last.close;

    // view display area boundary value drawing
    double y = getMainY(value);
    if (y > getMainY(mMainLowMinValue)) {
      y = getMainY(mMainLowMinValue);
    }

    if (y < getMainY(mMainHighMaxValue)) {
      y = getMainY(mMainHighMaxValue);
    }

    nowPriceLinePaint.color = value >= last.open
        ? chartColors.nowPriceUpColor
        : chartColors.nowPriceDnColor;

    //first draw the horizontal line
    canvas.drawDashLine(
      Offset(0, y),
      Offset(-mTranslateX + mWidth / scaleX, y),
      nowPriceLinePaint,
    );
  }

  ///draw cross lines
  @override
  void drawCrossLine(Canvas canvas, Size size) {
    final index = calculateSelectedX(selectX);
    final KLineEntity point = getItem(index);
    final double x = getX(index);
    final double y = getMainY(point.close);

    // K-line chart vertical line
    canvas.drawDashLine(Offset(x, 0), Offset(x, size.height), paintCross);

    // K-line chart horizontal line
    canvas.drawDashLine(
      Offset(-mTranslateX, y),
      Offset(-mTranslateX + mWidth / scaleX, y),
      paintCross,
    );

    if (scaleX >= 1) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), height: 4.0 * scaleX, width: 4.0),
        paintCross,
      );
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), height: 4.0, width: 4.0 / scaleX),
        paintCross,
      );
    }
  }

  TextPainter getTextPainter(String? text, Color? color) {
    color ??= chartColors.defaultTextColor;

    final TextSpan span = TextSpan(text: text, style: getTextStyle(color));

    final TextPainter tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    return tp;
  }

  String getDate(int? date) => dateFormat(
    DateTime.fromMillisecondsSinceEpoch(
      date ?? DateTime.now().millisecondsSinceEpoch,
    ),
    mFormats,
  );

  double getMainY(double y) => mMainRenderer.getY(y);

  /// Whether the point is in MainRect
  bool isInMainRect(Offset point) {
    return mMainRect.contains(point);
  }
}
