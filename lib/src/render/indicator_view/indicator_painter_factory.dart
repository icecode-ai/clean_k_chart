import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/indicator/main/boll_indicator.dart';
import 'package:clean_k_chart/src/indicator/main/ema_indicator.dart';
import 'package:clean_k_chart/src/indicator/main/ma_indicator.dart';
import 'package:clean_k_chart/src/indicator/main/sar_indicator.dart';
import 'package:clean_k_chart/src/indicator/secondary/cci_indicator.dart';
import 'package:clean_k_chart/src/indicator/secondary/kdj_indicator.dart';
import 'package:clean_k_chart/src/indicator/secondary/macd_indicator.dart';
import 'package:clean_k_chart/src/indicator/secondary/rsi_indicator.dart';
import 'package:clean_k_chart/src/indicator/secondary/wr_indicator.dart';
import 'package:clean_k_chart/src/render/indicator_view/indicator_painter.dart';
import 'package:clean_k_chart/src/render/indicator_view/main/boll_painter.dart';
import 'package:clean_k_chart/src/render/indicator_view/main/ema_painter.dart';
import 'package:clean_k_chart/src/render/indicator_view/main/ma_painter.dart';
import 'package:clean_k_chart/src/render/indicator_view/main/sar_painter.dart';
import 'package:clean_k_chart/src/render/indicator_view/secondary/cci_painter.dart';
import 'package:clean_k_chart/src/render/indicator_view/secondary/kdj_painter.dart';
import 'package:clean_k_chart/src/render/indicator_view/secondary/macd_painter.dart';
import 'package:clean_k_chart/src/render/indicator_view/secondary/rsi_painter.dart';
import 'package:clean_k_chart/src/render/indicator_view/secondary/wr_painter.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';

typedef IndicatorPainterBuilder = IndicatorPainter Function(
  Indicator indicator,
  IndicatorStyles styles,
);

/// Maps indicator instances to their painters.
///
/// Built-in indicators are registered by type. Custom indicators hook in
/// their painter via [register].
class IndicatorPainterFactory {
  IndicatorPainterFactory._();

  static final Map<Type, IndicatorPainterBuilder> _builders = {
    MAIndicator: (i, s) => MAPainter(i as MAIndicator, style: s.ma),
    EMAIndicator: (i, s) => EMAPainter(i as EMAIndicator, style: s.ema),
    BOLLIndicator: (i, s) => BOLLPainter(i as BOLLIndicator, style: s.boll),
    SARIndicator: (i, s) => SARPainter(i as SARIndicator, style: s.sar),
    MACDIndicator: (i, s) => MACDPainter(i as MACDIndicator, style: s.macd),
    KDJIndicator: (i, s) => KDJPainter(i as KDJIndicator, style: s.kdj),
    RSIIndicator: (i, s) => RSIPainter(i as RSIIndicator, style: s.rsi),
    WRIndicator: (i, s) => WRPainter(i as WRIndicator, style: s.wr),
    CCIIndicator: (i, s) => CCIPainter(i as CCIIndicator, style: s.cci),
  };

  /// Registers a painter for a custom indicator type (exact type match).
  static void register<T extends Indicator>(
    IndicatorPainter Function(T indicator, IndicatorStyles styles) builder,
  ) {
    _builders[T] = (indicator, styles) => builder(indicator as T, styles);
  }

  /// Creates the painter for [indicator], styled from [styles].
  /// Throws [ArgumentError] when no painter is registered for the type.
  static IndicatorPainter create(Indicator indicator, IndicatorStyles styles) {
    final builder = _builders[indicator.runtimeType];
    if (builder == null) {
      throw ArgumentError(
        'No IndicatorPainter registered for "${indicator.runtimeType}". '
        'Register one via IndicatorPainterFactory.register.',
      );
    }
    return builder(indicator, styles);
  }

  /// Like [create] but asserts the painter is usable in a secondary panel.
  static SecondaryIndicatorPainter createSecondary(
    SecondaryIndicator indicator,
    IndicatorStyles styles,
  ) {
    final painter = create(indicator, styles);
    if (painter is SecondaryIndicatorPainter) {
      return painter;
    }
    throw ArgumentError(
      'Painter for "${indicator.shortName}" must extend '
      'SecondaryIndicatorPainter.',
    );
  }
}
