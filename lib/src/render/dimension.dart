/// Layout dimension calculator for the chart viewport.
///
/// Pure layout math — must not depend on indicators or any rendering code.
class BaseDimension {
  // the height of base chart
  late double _baseHeight;
  // default: 0
  // the height of volume chart
  late double _volumeHeight;
  // default: 0
  // the height of a secondary chart
  late double _secondaryHeight;
  late double _totalSecondaryHeight;

  double _labelHeight = 12;
  double _totalLabelHeight = 12;

  // total height of chart: _baseHeight + _volumeHeight + (_secondaryHeight * n)
  // n : number of secondary charts
  //
  double _displayHeight = 0;

  /// getter the vol height
  double get volumeHeight => _volumeHeight;

  /// getter the secondary height
  double get secondaryHeight => _secondaryHeight;
  double get totalSecondaryHeight => _totalSecondaryHeight;

  double get labelHeight => _labelHeight;
  double get totalLabelHeight => _totalLabelHeight;

  /// getter the total height
  double get displayHeight => _displayHeight;

  /// constructor
  ///
  /// [secondaryCount] / [mainLabelCount] are plain counts so this class
  /// stays decoupled from the indicator layer.
  BaseDimension({
    required double baseHeight,
    required double secondaryHeight,
    required bool volHidden,
    required int secondaryCount,
    required int mainLabelCount,
  }) {
    _baseHeight = baseHeight;
    _volumeHeight = volHidden != true ? secondaryHeight : 0;
    _secondaryHeight = secondaryHeight;

    _totalSecondaryHeight = _secondaryHeight * secondaryCount;
    _totalLabelHeight = _labelHeight * mainLabelCount;

    _displayHeight =
        _baseHeight + _volumeHeight + _totalSecondaryHeight + _totalLabelHeight;
  }
}
