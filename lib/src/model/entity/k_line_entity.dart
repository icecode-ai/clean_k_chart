import 'package:clean_k_chart/src/model/entity/k_entity.dart';
import 'package:clean_k_chart/src/utils/extension/map_extension.dart';

class KLineEntity extends KEntity {
  int? time;
  late double open;
  late double close;
  late double high;
  late double low;
  late double vol;
  late double? amount;
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

  KLineEntity.fromJson(Map<String, dynamic> json) {
    time = json.gInt('time');
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['open'] = this.open;
    data['close'] = this.close;
    data['high'] = this.high;
    data['low'] = this.low;
    data['vol'] = this.vol;
    data['amount'] = this.amount;
    data['change'] = this.change;
    data['ratio'] = this.ratio;

    data['toRate'] = this.toRate;
    data['prevPrice'] = this.prevPrice;
    data['amplitude'] = this.amplitude;
    data['openPremiumRate'] = this.openPremiumRate;

    return data;
  }

  @override
  String toString() {
    return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, time: $time, amount: $amount, ratio: $ratio, change: $change}';
  }
}
