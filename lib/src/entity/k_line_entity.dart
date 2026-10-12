import 'package:clean_k_chart/src/entity/k_entity.dart';
import 'package:clean_k_chart/src/extension/map_extension.dart';

class KLineEntity extends KEntity {
  final int time;
  final double open;
  final double close;
  final double high;
  final double low;
  final double vol;

  double? amount;
  double? change;
  double? ratio;
  double? toRate;
  double? prevPrice;
  double? amplitude;
  double? openPremiumRate;

  KLineEntity.fromCustom({
    required this.time,
    required this.open,
    required this.close,
    required this.high,
    required this.low,
    required this.vol,
    this.amount,
    this.change,
    this.ratio,
    this.toRate,
    this.prevPrice,
    this.amplitude,
    this.openPremiumRate,
  });

  KLineEntity.fromJson(Map<String, dynamic> json)
    : time = json.gInt('time'),
      open = json.gDouble('open'),
      close = json.gDouble('close'),
      high = json.gDouble('high'),
      low = json.gDouble('low'),
      vol = json.gDouble('vol'),
      amount = json.gDouble('amount'),
      change = json.gDouble('change'),
      ratio = json.gDouble('ratio'),
      toRate = json.gDouble('toRate'),
      prevPrice = json.gDouble('prevPrice'),
      amplitude = json.gDouble('amplitude'),
      openPremiumRate = json.gDouble('openPremiumRate');

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
