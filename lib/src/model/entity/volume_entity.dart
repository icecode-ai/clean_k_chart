/// Volume fields of a candlestick bar.
mixin VolumeEntity {
  late double vol;

  /// 5-period volume moving average; null while warming up.
  double? ma5Volume;

  /// 10-period volume moving average; null while warming up.
  double? ma10Volume;
}
