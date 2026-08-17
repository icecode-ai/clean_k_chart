import 'package:clean_k_chart/src/model/entity/candle_entity.dart';
import 'package:clean_k_chart/src/model/entity/cci_entity.dart';
import 'package:clean_k_chart/src/model/entity/kdj_entity.dart';
import 'package:clean_k_chart/src/model/entity/macd_entity.dart';
import 'package:clean_k_chart/src/model/entity/rsi_entity.dart';
import 'package:clean_k_chart/src/model/entity/rw_entity.dart';
import 'package:clean_k_chart/src/model/entity/volume_entity.dart';

class KEntity
    with
        CandleEntity,
        VolumeEntity,
        KDJEntity,
        RSIEntity,
        WREntity,
        CCIEntity,
        MACDEntity {}
