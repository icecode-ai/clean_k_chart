import 'package:clean_k_chart/src/model/entity/boll_entity.dart';

mixin CandleEntity {
  late double open;
  late double high;
  late double low;
  late double close;

  // movingAverage
  List<double>? maValueList;

  List<double>? emaValueList;

  // stopAndReverse
  double? sar;

  // bollingerBands
  Boll? boll;
}
