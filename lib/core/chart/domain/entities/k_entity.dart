import 'package:clean_k_chart/core/chart/domain/types/candle_mixin.dart';
import 'package:clean_k_chart/core/chart/domain/types/cci_mixin.dart';
import 'package:clean_k_chart/core/chart/domain/types/kdj_mixin.dart';
import 'package:clean_k_chart/core/chart/domain/types/macd_mixin.dart';
import 'package:clean_k_chart/core/chart/domain/types/rsi_mixin.dart';
import 'package:clean_k_chart/core/chart/domain/types/volume_mixin.dart';
import 'package:clean_k_chart/core/chart/domain/types/wr_mixin.dart';

class KEntity
    with
        CandleMixin,
        VolumeMixin,
        KdjMixin,
        RsiMixin,
        WrMixin,
        CciMixin,
        MacdMixin {}
