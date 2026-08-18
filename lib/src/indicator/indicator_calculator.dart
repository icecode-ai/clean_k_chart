import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';

/// Batch runner for indicator calculations over a K-line data list.
///
/// The chart widget does NOT trigger indicator calculations itself — call
/// [calculateAll] (or individual [Indicator.calc]s) after loading data,
/// then pass the list to [KChartWidget]:
///
/// ```dart
/// IndicatorCalculator.calculateAll(data, mainIndicators, secondaryIndicators);
/// ```
class IndicatorCalculator {
  IndicatorCalculator._();

  /// Calculates volume MA5/MA10 plus every given indicator over [dataList].
  static void calculateAll(
    List<KLineEntity> dataList,
    List<MainIndicator> mainIndicators,
    List<SecondaryIndicator> secondaryIndicators,
  ) {
    calcVolumeMA(dataList);
    calculateIndicators(dataList, mainIndicators, secondaryIndicators);
  }

  /// Calculates every given indicator over [dataList] (volume MA excluded).
  static void calculateIndicators(
    List<KLineEntity> dataList,
    List<MainIndicator> mainIndicators,
    List<SecondaryIndicator> secondaryIndicators,
  ) {
    for (final indicator in mainIndicators) {
      indicator.calc(dataList);
    }
    for (final indicator in secondaryIndicators) {
      indicator.calc(dataList);
    }
  }

  /// Calculates a single indicator over [dataList].
  static void calculateIndicator(
    List<KLineEntity> dataList,
    Indicator indicator,
  ) {
    indicator.calc(dataList);
  }

  /// Calculates the MA5/MA10 volume moving averages over [dataList].
  static void calcVolumeMA(List<KLineEntity> dataList) {
    _calcVolumeMA(dataList, 5);
    _calcVolumeMA(dataList, 10);
  }

  static void _calcVolumeMA(List<KLineEntity> dataList, int period) {
    var sum = 0.0;
    for (var i = 0; i < dataList.length; i++) {
      sum += dataList[i].vol;
      if (i >= period) {
        sum -= dataList[i - period].vol;
      }
      final value = i >= period - 1 ? sum / period : null;
      if (period == 5) {
        dataList[i].ma5Volume = value;
      } else {
        dataList[i].ma10Volume = value;
      }
    }
  }
}
