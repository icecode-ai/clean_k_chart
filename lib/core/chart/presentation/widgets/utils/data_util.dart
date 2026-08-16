import 'package:clean_k_chart/core/chart/domain/entities/k_line_entity.dart';
import 'package:clean_k_chart/indicator/indicator_template.dart';

class DataUtil {
  static void calculateAll(
    List<KLineEntity> dataList,
    List<MainIndicator> mainLi,
    List<SecondaryIndicator> secondaryLi,
  ) {
    calcVolumeMA(dataList);
    calculateIndicators(dataList, mainLi, secondaryLi);
  }

  static void calculateIndicators(
    List<KLineEntity> dataList,
    List<MainIndicator> mainLi,
    List<SecondaryIndicator> secondaryLi,
  ) {
    /// calculate main state
    mainLi.forEach((e) {
      e.calc(dataList);
    });

    /// calculate secondary state
    secondaryLi.forEach((e) {
      e.calc(dataList);
    });
  }

  static void calculateIndicator(
    List<KLineEntity> dataList,
    IndicatorTemplate indicator,
  ) {
    indicator.calc(dataList);
  }

  static void calcVolumeMA(List<KLineEntity> dataList) {
    double volumeMa5 = 0;
    double volumeMa10 = 0;

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entry = dataList[i];

      volumeMa5 += entry.vol;
      volumeMa10 += entry.vol;

      if (i == 4) {
        entry.ma5Volume = (volumeMa5 / 5);
      } else if (i > 4) {
        volumeMa5 -= dataList[i - 5].vol;
        entry.ma5Volume = volumeMa5 / 5;
      } else {
        entry.ma5Volume = 0;
      }

      if (i == 9) {
        entry.ma10Volume = volumeMa10 / 10;
      } else if (i > 9) {
        volumeMa10 -= dataList[i - 10].vol;
        entry.ma10Volume = volumeMa10 / 10;
      } else {
        entry.ma10Volume = 0;
      }
    }
  }
}
