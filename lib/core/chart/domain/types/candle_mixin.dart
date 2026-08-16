import 'package:clean_k_chart/core/chart/domain/types/boll.dart';

mixin CandleMixin {
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
