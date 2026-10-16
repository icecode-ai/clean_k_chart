import 'package:clean_k_chart/src/entity/candle_entity.dart';

mixin VolumeEntity on CandleEntity {
  late double vol;

  double? ma5Volume;
  double? ma10Volume;
}
