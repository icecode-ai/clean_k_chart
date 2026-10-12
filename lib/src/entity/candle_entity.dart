import 'package:clean_k_chart/src/entity/boll_entity.dart';

mixin CandleEntity {
  late double open;
  late double high;
  late double low;
  late double close;

  List<double>? maValueList;
  List<double>? emaValueList;
  double? sar;
  BollEntity? boll;
}
