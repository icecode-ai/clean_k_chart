import 'package:clean_k_chart/src/entity/cci_entity.dart';
import 'package:clean_k_chart/src/entity/kdj_entity.dart';
import 'package:clean_k_chart/src/entity/rsi_entity.dart';
import 'package:clean_k_chart/src/entity/rw_entity.dart';

mixin MACDEntity on KDJEntity, RSIEntity, WREntity, CCIEntity {
  double? dea;
  double? dif;
  double? macd;
}
