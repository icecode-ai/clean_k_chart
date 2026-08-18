import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Number formatting helpers for chart labels.
class NumberUtil {
  NumberUtil._();

  static final Map<String, NumberFormat> _formats = {};

  static NumberFormat _format(String pattern) =>
      _formats.putIfAbsent(pattern, () => NumberFormat(pattern, 'en_US'));

  /// Compact volume formatting: `1.23B` / `4.56M` / `7.89K` (threshold 10⁴).
  static String formatCompact(double value, [int precision = 2]) {
    if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(precision)}B';
    }
    if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(precision)}M';
    }
    if (value >= 1e4) {
      return '${(value / 1e3).toStringAsFixed(precision)}K';
    }
    return value.toStringAsFixed(precision);
  }

  /// Groups the integer part and pads/truncates the fraction to exactly
  /// [precision] digits. Returns null when [value] cannot be parsed.
  static String? formatFixed(
    dynamic value,
    int precision, [
    String pattern = '#,##0',
  ]) {
    try {
      // Decimal.parse avoids scientific notation like 1e-10.
      final parts = Decimal.parse(value.toString()).toString().split('.');
      final integerPart = _format(pattern).format(num.parse(parts.first));
      if (precision == 0) {
        return integerPart;
      }
      final fraction = (parts.length <= 1 ? '' : parts.last).padRight(
        precision,
        '0',
      );
      return '$integerPart.${fraction.substring(0, precision)}';
    } catch (_) {
      return null;
    }
  }

  /// Like [formatFixed] but floors the value to [precision] fraction digits.
  /// Returns null when [value] cannot be parsed.
  static String? format(
    dynamic value,
    int precision, [
    String pattern = '#,##0',
  ]) {
    try {
      final parts = Decimal.parse(value.toString())
          .floor(scale: precision)
          .toString()
          .split('.');
      final integerPart = _format(pattern).format(num.parse(parts.first));
      if (precision == 0 && parts.length == 1) {
        return integerPart;
      }
      return '$integerPart.${parts.last}';
    } catch (_) {
      return null;
    }
  }
}
