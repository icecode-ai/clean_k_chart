/// Layout dimension calculator for the chart viewport.
///
/// Pure layout math — must not depend on indicators or any rendering code.
class ChartDimension {
  static const double _labelHeight = 12.0;

  final double _volumeHeight;
  final double _secondaryHeight;
  final double _totalSecondaryHeight;
  final double _totalLabelHeight;
  final double _displayHeight;

  /// Height of the volume panel (0 when hidden).
  double get volumeHeight => _volumeHeight;

  /// Height of a single secondary panel.
  double get secondaryHeight => _secondaryHeight;

  /// Combined height of every secondary panel.
  double get totalSecondaryHeight => _totalSecondaryHeight;

  /// Combined height of the main-panel header labels.
  double get totalLabelHeight => _totalLabelHeight;

  /// Total height of the whole chart:
  /// base + volume + secondary panels + header labels.
  double get displayHeight => _displayHeight;

  ChartDimension({
    required double baseHeight,
    required double secondaryHeight,
    required bool volHidden,
    required int secondaryCount,
    required int mainLabelCount,
  }) : _volumeHeight = volHidden ? 0 : secondaryHeight,
       _secondaryHeight = secondaryHeight,
       _totalSecondaryHeight = secondaryHeight * secondaryCount,
       _totalLabelHeight = _labelHeight * mainLabelCount,
       _displayHeight =
           baseHeight +
           (volHidden ? 0 : secondaryHeight) +
           secondaryHeight * secondaryCount +
           _labelHeight * mainLabelCount;
}
