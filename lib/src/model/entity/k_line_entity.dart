import 'package:clean_k_chart/src/model/entity/boll_entity.dart';
import 'package:clean_k_chart/src/model/entity/candle_entity.dart';
import 'package:clean_k_chart/src/model/entity/cci_entity.dart';
import 'package:clean_k_chart/src/model/entity/ema_entity.dart';
import 'package:clean_k_chart/src/model/entity/kdj_entity.dart';
import 'package:clean_k_chart/src/model/entity/ma_entity.dart';
import 'package:clean_k_chart/src/model/entity/macd_entity.dart';
import 'package:clean_k_chart/src/model/entity/rsi_entity.dart';
import 'package:clean_k_chart/src/model/entity/sar_entity.dart';
import 'package:clean_k_chart/src/model/entity/volume_entity.dart';
import 'package:clean_k_chart/src/model/entity/wr_entity.dart';

/// A single K-line (candlestick) bar.
///
/// Mixes in one value-slot mixin per indicator so each indicator can write
/// its computed values directly onto the bar. Indicator values are nullable
/// and null means "not computed / warming up".
class KLineEntity
    with
        CandleEntity,
        VolumeEntity,
        MAEntity,
        EMAEntity,
        SAREntity,
        BOLLEntity,
        MACDEntity,
        KDJEntity,
        RSIEntity,
        WREntity,
        CCIEntity {
  int time;
  double amount;
  double change;
  double ratio;
  double toRate;
  double prevPrice;
  double amplitude;
  double openPremiumRate;

  KLineEntity({
    double open = 0,
    double high = 0,
    double low = 0,
    double close = 0,
    double vol = 0,
    this.time = 0,
    this.amount = 0,
    this.change = 0,
    this.ratio = 0,
    this.toRate = 0,
    this.prevPrice = 0,
    this.amplitude = 0,
    this.openPremiumRate = 0,
  }) {
    this.open = open;
    this.high = high;
    this.low = low;
    this.close = close;
    this.vol = vol;
  }

  factory KLineEntity.fromJson(Map<String, dynamic> json) {
    return KLineEntity(
      open: _readDouble(json, 'open'),
      high: _readDouble(json, 'high'),
      low: _readDouble(json, 'low'),
      close: _readDouble(json, 'close'),
      vol: _readDouble(json, 'vol'),
      time: _readInt(json, 'time'),
      amount: _readDouble(json, 'amount'),
      change: _readDouble(json, 'change'),
      ratio: _readDouble(json, 'ratio'),
      toRate: _readDouble(json, 'toRate'),
      prevPrice: _readDouble(json, 'prevPrice'),
      amplitude: _readDouble(json, 'amplitude'),
      openPremiumRate: _readDouble(json, 'openPremiumRate'),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'time': time,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'vol': vol,
    };
  }

  @override
  String toString() {
    return 'KLineEntity{open: $open, high: $high, low: $low, close: $close, '
        'vol: $vol, time: $time}';
  }

  static int _readInt(Map<String, dynamic> json, String key, [int def = 0]) {
    final value = json[key];
    if (value == null) return def;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? def;
  }

  static double _readDouble(
    Map<String, dynamic> json,
    String key, [
    double def = 0,
  ]) {
    return _readDoubleOrNull(json, key) ?? def;
  }

  static double? _readDoubleOrNull(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
