import 'dart:math' as math;

/// One exponential-moving-average smoothing step:
/// `ema = (2 · value + (period − 1) · previous) / (period + 1)`.
double emaSmooth(double value, double previous, int period) =>
    (2 * value + (period - 1) * previous) / (period + 1);

/// Extends a running (min, max) range with [value] if it is not null.
(double, double) extendRange(double min, double max, double? value) {
  if (value == null) return (min, max);
  return (math.min(min, value), math.max(max, value));
}

/// Extends a running (min, max) range with every non-null entry of [values].
(double, double) extendRangeAll(double min, double max, List<double?>? values) {
  if (values == null) return (min, max);
  var result = (min, max);
  for (final value in values) {
    result = extendRange(result.$1, result.$2, value);
  }
  return result;
}
