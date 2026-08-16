import 'package:clean_k_chart/core/chart/domain/types/cci_mixin.dart';
import 'package:clean_k_chart/core/chart/domain/types/kdj_mixin.dart';
import 'package:clean_k_chart/core/chart/domain/types/rsi_mixin.dart';
import 'package:clean_k_chart/core/chart/domain/types/wr_mixin.dart';

mixin MacdMixin on KdjMixin, RsiMixin, WrMixin, CciMixin {
  double? dea;
  double? dif;
  double? macd;
}
