import 'package:clean_k_chart/src/entity/candle_entity.dart';
import 'package:clean_k_chart/src/entity/cci_entity.dart';
import 'package:clean_k_chart/src/entity/kdj_entity.dart';
import 'package:clean_k_chart/src/entity/macd_entity.dart';
import 'package:clean_k_chart/src/entity/rsi_entity.dart';
import 'package:clean_k_chart/src/entity/rw_entity.dart';
import 'package:clean_k_chart/src/entity/volume_entity.dart';

class KEntity
    with
        CandleEntity,
        VolumeEntity,
        KDJEntity,
        RSIEntity,
        WREntity,
        CCIEntity,
        MACDEntity {}
