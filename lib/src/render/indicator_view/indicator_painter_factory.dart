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

typedef IndicatorPainterBuilder = IndicatorPainter Function(
  Indicator indicator,
);

/// Maps indicator instances to their renderers.
///
/// Built-in indicators are registered by type. Custom indicators can hook
/// in their painter via [register].
class IndicatorPainterFactory {
  IndicatorPainterFactory._();

  static final Map<Type, IndicatorPainterBuilder> _builders = {
    MAIndicator: (i) => MAPainter(i as MAIndicator),
    EMAIndicator: (i) => EMAPainter(i as EMAIndicator),
    BOLLIndicator: (i) => BOLLPainter(i as BOLLIndicator),
    SARIndicator: (i) => SARPainter(i as SARIndicator),
    MACDIndicator: (i) => MACDPainter(i as MACDIndicator),
    KDJIndicator: (i) => KDJPainter(i as KDJIndicator),
    RSIIndicator: (i) => RSIPainter(i as RSIIndicator),
    WRIndicator: (i) => WRPainter(i as WRIndicator),
    CCIIndicator: (i) => CCIPainter(i as CCIIndicator),
  };

  /// Registers a painter for a custom indicator type (exact type match).
  static void register<T extends Indicator>(
    IndicatorPainter Function(T indicator) builder,
  ) {
    _builders[T] = (indicator) => builder(indicator as T);
  }

  static IndicatorPainter create(Indicator indicator) {
    final builder = _builders[indicator.runtimeType];
    if (builder == null) {
      throw ArgumentError(
        'No IndicatorPainter registered for '
        '"${indicator.runtimeType}". Register one via '
        'IndicatorPainterFactory.register.',
      );
    }
    return builder(indicator);
  }
}
