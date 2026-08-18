import 'package:flutter/painting.dart' show Color;

/// Base style for indicator painters.
class IndicatorStyle {
  final double lineWidth;

  const IndicatorStyle({this.lineWidth = 1.0});
}

/// Style for the MA / EMA multi-line indicators.
class MAStyle extends IndicatorStyle {
  /// Line colors, one per calc param; cycled by index.
  final List<Color> maColors;

  const MAStyle({
    this.maColors = const [
      Color(0xFFFF0000),
      Color(0xFFFFC634),
      Color(0xFFB48EE3),
      Color(0xFF127ECC),
      Color(0xFF000000),
      Color(0xFF40D4F0),
    ],
  });

  /// The line color for param index [index].
  Color colorFor(int index) => maColors[index % maColors.length];
}

/// Style for the BOLL indicator.
class BOLLStyle extends IndicatorStyle {
  final Color bollColor;
  final Color ubColor;
  final Color lbColor;
  final Color fillColor;

  const BOLLStyle({
    this.bollColor = const Color(0xFFF7931A),
    this.ubColor = const Color(0xFFFFC634),
    this.lbColor = const Color(0xFFFFC634),
    this.fillColor = const Color(0x12FFC634),
  });
}

/// Style for the SAR indicator.
class SARStyle extends IndicatorStyle {
  final Color sarColor;

  /// Dot radius.
  final double radius;

  /// Dot stroke width.
  final double strokeWidth;

  const SARStyle({
    this.sarColor = const Color(0xFFFFC634),
    this.radius = 2.0,
    this.strokeWidth = 0.8,
  });
}

/// Style for the CCI indicator.
class CCIStyle extends IndicatorStyle {
  final Color cciColor;

  const CCIStyle({this.cciColor = const Color(0xFFFFC634)});
}

/// Style for the RSI indicator.
class RSIStyle extends IndicatorStyle {
  final Color rsiColor;

  const RSIStyle({this.rsiColor = const Color(0xFFFFC634)});
}

/// Style for the WR indicator.
class WRStyle extends IndicatorStyle {
  final Color wrColor;

  const WRStyle({this.wrColor = const Color(0xFFFFC634)});
}

/// Style for the KDJ indicator.
class KDJStyle extends IndicatorStyle {
  final Color kColor;
  final Color dColor;
  final Color jColor;

  const KDJStyle({
    this.kColor = const Color(0xFFFFC634),
    this.dColor = const Color(0xFF35CDAC),
    this.jColor = const Color(0xFFB48EE3),
  });
}

/// Style for the MACD indicator.
class MACDStyle extends IndicatorStyle {
  /// Bar colors for positive / negative histogram values.
  final Color upColor;
  final Color dnColor;

  final Color macdColor;
  final Color difColor;
  final Color deaColor;

  /// Histogram bar width.
  final double macdWidth;

  const MACDStyle({
    this.upColor = const Color(0xFFD5405D),
    this.dnColor = const Color(0xFF14AD8F),
    this.macdColor = const Color(0xFFFFC634),
    this.difColor = const Color(0xFF35CDAC),
    this.deaColor = const Color(0xFFB48EE3),
    this.macdWidth = 8.5,
  });
}

/// Bundle of every built-in indicator style, passed to [KChartWidget].
///
/// Indicators are pure calculation objects; all painting configuration
/// lives here on the rendering side.
class IndicatorStyles {
  final MAStyle ma;
  final MAStyle ema;
  final BOLLStyle boll;
  final SARStyle sar;
  final MACDStyle macd;
  final KDJStyle kdj;
  final RSIStyle rsi;
  final WRStyle wr;
  final CCIStyle cci;

  const IndicatorStyles({
    this.ma = const MAStyle(),
    this.ema = const MAStyle(),
    this.boll = const BOLLStyle(),
    this.sar = const SARStyle(),
    this.macd = const MACDStyle(),
    this.kdj = const KDJStyle(),
    this.rsi = const RSIStyle(),
    this.wr = const WRStyle(),
    this.cci = const CCIStyle(),
  });
}
