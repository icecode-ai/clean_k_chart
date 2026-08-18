import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter_factory.dart';
import 'package:clean_k_chart/src/render/painter/trend_line_renderer.dart';
import 'package:clean_k_chart/src/render/renderer/main_renderer.dart';
import 'package:clean_k_chart/src/render/renderer/secondary_renderer.dart';
import 'package:clean_k_chart/src/render/renderer/vol_renderer.dart';
import 'package:clean_k_chart/src/render/text_painter_cache.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart';
import 'package:flutter/painting.dart';

/// Long-lived render state shared across painter instances.
///
/// Held by the widget state: renderers / indicator painters / text caches
/// are created once per configuration change and re-targeted each frame,
/// instead of being reallocated on every paint like before.
class ChartRendererCache {
  /// Cached laid-out label painters.
  final TextPainterCache textCache = TextPainterCache();

  final TrendLineRenderer trendLineRenderer = TrendLineRenderer();

  // Overlay state drawn by ChartPainter (background, crosshair, price
  // line) — long-lived and re-targeted from colors/style in [sync] so
  // painter rebuilds during gestures allocate no render objects.
  final Paint bgPaint = Paint();
  final Paint crossPaint = Paint()..isAntiAlias = true;
  final Paint selectPointPaint = Paint()..isAntiAlias = true;
  final Paint selectBorderPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;
  final Paint nowPriceLinePaint = Paint()..isAntiAlias = true;
  final Path dashPath = Path();

  MainRenderer? main;
  VolRenderer? vol;
  final List<SecondaryRenderer> secondary = [];

  // Structure signature — when any of these changes the renderers are
  // rebuilt; otherwise they are only re-targeted via update().
  List<MainIndicator>? _mainIndicators;
  List<SecondaryIndicator>? _secondaryIndicators;
  IndicatorStyles? _indicatorStyles;
  KChartStyle? _chartStyle;
  KChartColors? _chartColors;
  bool? _volHidden;
  bool? _isLine;
  double? _mainTopPadding;
  double? _panelTopPadding;
  VerticalTextAlignment? _verticalTextAlignment;

  /// Ensures the renderers match the current chart configuration.
  /// Cheap (identity comparison) when nothing structural changed.
  void sync({
    required List<MainIndicator> mainIndicators,
    required List<SecondaryIndicator> secondaryIndicators,
    required IndicatorStyles indicatorStyles,
    required KChartStyle chartStyle,
    required KChartColors chartColors,
    required bool volHidden,
    required bool isLine,
    required double mainTopPadding,
    required double panelTopPadding,
    required VerticalTextAlignment verticalTextAlignment,
  }) {
    if (main != null &&
        identical(_mainIndicators, mainIndicators) &&
        identical(_secondaryIndicators, secondaryIndicators) &&
        identical(_indicatorStyles, indicatorStyles) &&
        identical(_chartStyle, chartStyle) &&
        identical(_chartColors, chartColors) &&
        _volHidden == volHidden &&
        _isLine == isLine &&
        _mainTopPadding == mainTopPadding &&
        _panelTopPadding == panelTopPadding &&
        _verticalTextAlignment == verticalTextAlignment) {
      return;
    }

    // Stale-styled labels (old colors) would linger until LRU eviction.
    textCache.clear();

    bgPaint.color = chartColors.bgColor;
    crossPaint
      ..color = chartColors.crossColor
      ..strokeWidth = chartStyle.crossWidth;
    selectPointPaint.color = chartColors.selectFillColor;
    selectBorderPaint
      ..color = chartColors.selectBorderColor
      ..strokeWidth = chartStyle.borderWidth;
    nowPriceLinePaint.strokeWidth = chartStyle.nowPriceLineWidth;

    main = MainRenderer(
      chartStyle: chartStyle,
      chartColors: chartColors,
      topPadding: mainTopPadding,
      indicatorPainters: [
        for (final indicator in mainIndicators)
          IndicatorPainterFactory.create(indicator, indicatorStyles),
      ],
      isLine: isLine,
      verticalTextAlignment: verticalTextAlignment,
    );
    vol = volHidden
        ? null
        : VolRenderer(
            chartStyle: chartStyle,
            chartColors: chartColors,
            topPadding: panelTopPadding,
          );
    secondary.clear();
    for (final indicator in secondaryIndicators) {
      secondary.add(
        SecondaryRenderer(
          chartStyle: chartStyle,
          chartColors: chartColors,
          topPadding: panelTopPadding,
          indicator: indicator,
          painter: IndicatorPainterFactory.createSecondary(
            indicator,
            indicatorStyles,
          ),
        ),
      );
    }

    _mainIndicators = mainIndicators;
    _secondaryIndicators = secondaryIndicators;
    _indicatorStyles = indicatorStyles;
    _chartStyle = chartStyle;
    _chartColors = chartColors;
    _volHidden = volHidden;
    _isLine = isLine;
    _mainTopPadding = mainTopPadding;
    _panelTopPadding = panelTopPadding;
    _verticalTextAlignment = verticalTextAlignment;
  }
}
