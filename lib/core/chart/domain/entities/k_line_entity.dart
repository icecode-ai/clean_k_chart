import 'package:clean_k_chart/core/chart/domain/entities/k_entity.dart';

class KLineEntity extends KEntity {
  late double? amount;

  double? change;
  double? ratio;
  int? time;

  KLineEntity.fromCustom({
    this.amount,
    this.change,
    this.ratio,
    required this.time,
  });

  KLineEntity.fromJson(Map<String, dynamic> json) {
    open = json['open']?.toDouble() ?? 0;
    high = json['high']?.toDouble() ?? 0;
    low = json['low']?.toDouble() ?? 0;
    close = json['close']?.toDouble() ?? 0;
    vol = json['vol']?.toDouble() ?? 0;
    amount = json['amount']?.toDouble();
    int? tempTime = json['time']?.toInt();

    // 兼容火币数据
    if (tempTime == null) {
      tempTime = json['id']?.toInt() ?? 0;
      tempTime = tempTime! * 1000;
    }

    time = tempTime;
    ratio = json['ratio']?.toDouble();
    change = json['change']?.toDouble();
  }

  Map<String, dynamic> toJson() => {
    'time': time,
    'open': open,
    'close': close,
    'high': high,
    'vol': vol,
    'amount': amount,
    'ratio': ratio,
    'change': change,
  };
}
