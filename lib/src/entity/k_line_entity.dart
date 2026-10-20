import 'package:clean_k_chart/src/entity/candle_entity.dart';
import 'package:clean_k_chart/src/entity/cci_entity.dart';
import 'package:clean_k_chart/src/entity/kdj_entity.dart';
import 'package:clean_k_chart/src/entity/macd_entity.dart';
import 'package:clean_k_chart/src/entity/rsi_entity.dart';
import 'package:clean_k_chart/src/entity/rw_entity.dart';
import 'package:clean_k_chart/src/entity/volume_entity.dart';
import 'package:clean_k_chart/src/extension/map_extension.dart';

class KLineEntity
    with
        CandleEntity,
        VolumeEntity,
        KDJEntity,
        RSIEntity,
        WREntity,
        CCIEntity,
        MACDEntity {
  final int time;

  double? amount;
  double? change;
  double? ratio;
  double? toRate;
  double? prevPrice;
  double? amplitude;
  double? openPremiumRate;

  KLineEntity.fromCustom({
    required this.time,
    required double open,
    required double close,
    required double high,
    required double low,
    required double vol,
    this.amount,
    this.change,
    this.ratio,
    this.toRate,
    this.prevPrice,
    this.amplitude,
    this.openPremiumRate,
  }) {
    this.open = open;
    this.close = close;
    this.high = high;
    this.low = low;
    this.vol = vol;
  }

  KLineEntity.fromJson(Map<String, dynamic> json) : time = json.gInt('time') {
    open = json.gDouble('open');
    close = json.gDouble('close');
    high = json.gDouble('high');
    low = json.gDouble('low');
    vol = json.gDouble('vol');
    amount = json.gDouble('amount');
    change = json.gDouble('change');
    ratio = json.gDouble('ratio');
    toRate = json.gDouble('toRate');
    prevPrice = json.gDouble('prevPrice');
    amplitude = json.gDouble('amplitude');
    openPremiumRate = json.gDouble('openPremiumRate');
  }

  Map<String, dynamic> toJson() => {
    'time': time,
    'open': open,
    'close': close,
    'high': high,
    'low': low,
    'vol': vol,
    'amount': amount,
    'change': change,
    'ratio': ratio,
    'toRate': toRate,
    'prevPrice': prevPrice,
    'amplitude': amplitude,
    'openPremiumRate': openPremiumRate,
  };
}
