import 'package:clean_k_chart/src/model/entity/cci_entity.dart';
import 'package:clean_k_chart/src/model/entity/kdj_entity.dart';
import 'package:clean_k_chart/src/model/entity/rsi_entity.dart';
import 'package:clean_k_chart/src/model/entity/rw_entity.dart';

mixin MACDEntity on KDJEntity, RSIEntity, WREntity, CCIEntity {
  double? dea;
  double? dif;
  double? macd;
}
