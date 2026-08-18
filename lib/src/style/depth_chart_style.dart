import 'package:flutter/painting.dart' show Color;

/// Color configuration for [DepthChart].
///
/// Up/down colors follow the red-up / green-down convention, consistent
/// with [KChartColors]: the buy (bid) side uses [upColor], the sell (ask)
/// side uses [dnColor].
class DepthChartColors {
  /// Buy side line / fill colors.
  final Color upColor;
  final Color upFillPathColor;

  /// Sell side line / fill colors.
  final Color dnColor;
  final Color dnFillPathColor;

  /// Default text color (axis labels).
  final Color defaultTextColor;

  /// Border color of the selection popup.
  final Color selectBorderColor;

  /// Background color of the selection popup.
  final Color selectFillColor;

  /// Popup text color.
  final Color annotationColor;

  /// Crosshair line color.
  final Color crossColor;

  /// Overlay barrier color while selecting.
  final Color barrierColor;

  const DepthChartColors({
    this.upColor = const Color(0xFFD5405D),
    this.upFillPathColor = const Color(0x23D5405D),
    this.dnColor = const Color(0xFF14AD8F),
    this.dnFillPathColor = const Color(0x2314AD8F),
    this.selectBorderColor = const Color(0xFF909196),
    this.selectFillColor = const Color(0xFFFFFFFF),
    this.defaultTextColor = const Color(0xFF909196),
    this.annotationColor = const Color(0xFF222223),
    this.crossColor = const Color(0xFF191919),
    this.barrierColor = const Color(0x21AFAFAF),
  });
}

/// Dimension configuration for [DepthChart].
class DepthChartStyle {
  final double lineWidth;

  /// Popup corner radius.
  final double radius;

  /// Popup border width.
  final double strokeWidth;

  /// Gap between popup text rows.
  final double space;

  /// Popup inner padding.
  final double padding;

  /// Selection dot radius.
  final double dotRadius;

  /// Crosshair line width.
  final double crossWidth;

  const DepthChartStyle({
    this.lineWidth = 1.0,
    this.radius = 4.0,
    this.strokeWidth = 0.6,
    this.space = 2.0,
    this.padding = 6.0,
    this.dotRadius = 5.0,
    this.crossWidth = 0.5,
  });
}
