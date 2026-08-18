import 'package:intl/intl.dart';

final Map<String, DateFormat> _cache = {};

/// Cached [DateFormat] for [pattern].
DateFormat dateFormat(String pattern) =>
    _cache.putIfAbsent(pattern, () => DateFormat(pattern));

/// Picks a date axis pattern from the cadence between two bars.
///
/// [cadenceMs] is the time delta in milliseconds between two consecutive
/// bars; its absolute value is used so descending data does not break the
/// heuristic.
String pickDatePattern(int cadenceMs) {
  final cadence = cadenceMs.abs();
  if (cadence >= 28 * 24 * 60 * 60 * 1000) {
    return 'yy-MM';
  } else if (cadence >= 24 * 60 * 60 * 1000) {
    return 'yy-MM-dd';
  }
  return 'MM-dd HH:mm';
}
