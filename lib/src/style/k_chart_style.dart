import 'package:flutter/painting.dart' show Color;

/// Where the vertical axis price labels are drawn.
enum VerticalTextAlignment { left, right }

/// Color configuration for [KChartWidget].
///
/// Up/down colors follow the red-up / green-down convention.
class KChartColors {
  /// The background color of the chart.
  final Color bgColor;

  /// Line chart stroke + gradient fill colors.
  final Color kLineColor;
  final List<Color> kLineFillColors;

  /// Volume MA line colors.
  final Color ma5Color;
  final Color ma10Color;

  /// Candle up/down colors.
  final Color upColor;
  final Color dnColor;

  final Color volColor;

  /// Volume bar up/down colors.
  final Color volUpColor;
  final Color volDnColor;

  /// Default text color (grid labels).
  final Color defaultTextColor;

  /// Current price line colors.
  final Color nowPriceUpColor;
  final Color nowPriceDnColor;

  /// Trend line guide color.
  final Color trendLineColor;

  /// Border color of the selection bubble.
  final Color selectBorderColor;

  /// Background color of the selection bubble.
  final Color selectFillColor;

  /// Grid color.
  final Color gridColor;

  /// Crosshair line color.
  final Color crossColor;

  /// Crosshair bubble text color.
  final Color crossTextColor;

  /// Colors of the max/min value markers.
  final Color maxColor;
  final Color minColor;

  const KChartColors({
    this.bgColor = const Color(0xffffffff),
    this.kLineColor = const Color(0xff217AFF),
    this.kLineFillColors = const [Color(0x80217aff), Color(0x00217AFF)],
    this.ma5Color = const Color(0xFFFF0000),
    this.ma10Color = const Color(0xFF000000),
    this.upColor = const Color(0xFFD5405D),
    this.dnColor = const Color(0xFF14AD8F),
    this.volColor = const Color(0xff2f8fd5),
    this.volUpColor = const Color(0xFFD5405D),
    this.volDnColor = const Color(0xFF14AD8F),
    this.defaultTextColor = const Color(0xFF909196),
    this.nowPriceUpColor = const Color(0xFFD5405D),
    this.nowPriceDnColor = const Color(0xFF14AD8F),
    this.trendLineColor = const Color(0xFFF89215),
    this.selectBorderColor = const Color(0xFF222223),
    this.selectFillColor = const Color(0xffffffff),
    this.gridColor = const Color(0xFFD1D3DB),
    this.crossColor = const Color(0xFF191919),
    this.crossTextColor = const Color(0xFF222223),
    this.maxColor = const Color(0xFF222223),
    this.minColor = const Color(0xFF222223),
  });
}

/// Dimension configuration for [KChartWidget].
class KChartStyle {
  /// Padding above the main chart (header label space is added on top).
  final double topPadding;

  /// Height of the bottom date axis strip.
  final double bottomPadding;

  /// Vertical gap between the volume / secondary panels.
  final double childPadding;

  /// Horizontal padding for in-panel text.
  final double space;

  /// Top margin of header labels inside each panel.
  final double indicatorTopMargin;

  /// Distance between two data points.
  final double pointWidth;

  /// Candle body width.
  final double candleWidth;

  /// Candle wick line width.
  final double candleLineWidth;

  /// Volume bar width.
  final double volWidth;

  /// Crosshair line width.
  final double crossWidth;

  /// Current price dashed line width.
  final double nowPriceLineWidth;

  /// Border width of selection bubbles.
  final double borderWidth;

  /// Grid density.
  final int gridRows;
  final int gridColumns;

  /// Custom date axis pattern (intl [DateFormat] pattern, e.g. `'yy-MM-dd'`).
  /// When null the pattern is picked from the data cadence.
  final String? datePattern;

  const KChartStyle({
    this.topPadding = 24.0,
    this.bottomPadding = 24.0,
    this.childPadding = 24.0,
    this.space = 0.0,
    this.indicatorTopMargin = 8.0,
    this.pointWidth = 11.0,
    this.candleWidth = 8.5,
    this.candleLineWidth = 1.0,
    this.volWidth = 8.5,
    this.crossWidth = 0.8,
    this.nowPriceLineWidth = 0.8,
    this.borderWidth = 0.5,
    this.gridRows = 4,
    this.gridColumns = 4,
    this.datePattern,
  });
}
