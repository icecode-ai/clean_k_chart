/// Number formatting helpers for chart labels (pure Dart, no dependencies).
class NumberUtil {
  NumberUtil._();

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
  /// [precision] digits (fraction truncated toward zero). Returns null for
  /// NaN, infinity or unparseable input.
  static String? formatFixed(dynamic value, int precision) {
    final d = _decimalDigits(value);
    if (d == null) return null;
    final fraction = d.fraction.length <= precision
        ? d.fraction
        : d.fraction.substring(0, precision);
    return _format(d.negative, d.integer, fraction, precision);
  }

  /// Like [formatFixed] but floors the value to [precision] fraction digits
  /// toward negative infinity (e.g. `-1.999` → `-2.00`). Returns null for
  /// NaN, infinity or unparseable input.
  static String? format(dynamic value, int precision) {
    final d = _decimalDigits(value);
    if (d == null) return null;
    if (d.fraction.length <= precision) {
      return _format(d.negative, d.integer, d.fraction, precision);
    }

    final kept = d.fraction.substring(0, precision);
    final discarded = d.fraction.substring(precision);
    if (!d.negative || !discarded.contains(RegExp('[1-9]'))) {
      return _format(d.negative, d.integer, kept, precision);
    }

    // Negative floor: bump the magnitude up by one unit in the last kept
    // place, carrying into the integer part when the kept digits roll over.
    final combined = _increment(d.integer + kept);
    final splitAt = combined.length - precision;
    final integer = precision == 0 ? combined : combined.substring(0, splitAt);
    final fraction = precision == 0 ? '' : combined.substring(splitAt);
    return _format(true, integer, fraction, precision);
  }

  static String _format(
    bool negative,
    String integer,
    String fraction,
    int precision,
  ) {
    final sign = negative ? '-' : '';
    final grouped = _group(integer);
    if (precision == 0) return '$sign$grouped';
    return '$sign$grouped.${fraction.padRight(precision, '0')}';
  }

  /// Groups integer digits in threes with `,` separators.
  static String _group(String integer) {
    final builder = StringBuffer();
    for (var i = 0; i < integer.length; i++) {
      builder.write(integer[i]);
      final remaining = integer.length - i;
      if (remaining > 1 && remaining % 3 == 1) builder.write(',');
    }
    return builder.toString();
  }

  /// Adds 1 to a digit string, carrying leftwards and growing on overflow.
  static String _increment(String digits) {
    final chars = digits.split('');
    var carry = 1;
    for (var i = chars.length - 1; i >= 0 && carry > 0; i--) {
      final sum = int.parse(chars[i]) + carry;
      chars[i] = '${sum % 10}';
      carry = sum ~/ 10;
    }
    if (carry > 0) chars.insert(0, '$carry');
    return chars.join();
  }

  /// Splits [value] into sign, integer digits and fraction digits.
  ///
  /// Expands scientific notation (e.g. `1e-10`) so double shortest-form
  /// output never leaks into labels. Returns null for NaN, infinity or
  /// input that is not a finite decimal number.
  static _Decimal? _decimalDigits(dynamic value) {
    if (value is num && (value.isNaN || value.isInfinite)) return null;
    final plain = _plainString(value.toString());
    if (plain == null) return null;

    var negative = false;
    var body = plain;
    if (body.startsWith('-')) {
      negative = true;
      body = body.substring(1);
    } else if (body.startsWith('+')) {
      body = body.substring(1);
    }

    final dot = body.indexOf('.');
    final integerPart = dot < 0 ? body : body.substring(0, dot);
    final fractionPart = dot < 0 ? '' : body.substring(dot + 1);
    if (!RegExp(r'^\d*$').hasMatch(integerPart) ||
        !RegExp(r'^\d*$').hasMatch(fractionPart) ||
        integerPart.isEmpty && fractionPart.isEmpty) {
      return null;
    }

    var integer = integerPart.replaceFirst(RegExp(r'^0+'), '');
    if (integer.isEmpty) integer = '0';
    // Leading zeros of the fraction carry place value ("0.001" → "001")
    // so only trailing zeros are stripped.
    final fraction = fractionPart.replaceFirst(RegExp(r'0+$'), '');
    // Negative zero normalizes to zero.
    if (integer == '0' && fraction.isEmpty) negative = false;
    return _Decimal(negative, integer, fraction);
  }

  /// Converts a numeric string to plain (non-scientific) decimal notation.
  static String? _plainString(String s) {
    final eIndex = s.indexOf('e');
    if (eIndex < 0) return s;

    var mantissa = s.substring(0, eIndex);
    final exponent = int.tryParse(s.substring(eIndex + 1));
    if (exponent == null) return null;

    var negative = false;
    if (mantissa.startsWith('-')) {
      negative = true;
      mantissa = mantissa.substring(1);
    }
    final dot = mantissa.indexOf('.');
    final intDigits = dot < 0 ? mantissa : mantissa.substring(0, dot);
    final fracDigits = dot < 0 ? '' : mantissa.substring(dot + 1);
    final digits = intDigits + fracDigits;
    if (digits.isEmpty || !RegExp(r'^\d+$').hasMatch(digits)) return null;

    final point = intDigits.length + exponent;
    String body;
    if (point <= 0) {
      body = '0.${'0' * -point}$digits';
    } else if (point >= digits.length) {
      body = digits + '0' * (point - digits.length);
    } else {
      body = '${digits.substring(0, point)}.${digits.substring(point)}';
    }
    return negative ? '-$body' : body;
  }
}

/// Sign, integer digits and fraction digits of a finite decimal number.
/// [integer] has no leading zeros and is at least `"0"`; [fraction] keeps
/// its leading zeros (they carry place value) and has no trailing zeros.
class _Decimal {
  const _Decimal(this.negative, this.integer, this.fraction);

  final bool negative;
  final String integer;
  final String fraction;
}
