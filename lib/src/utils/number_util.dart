class NumberUtil {
  static final RegExp _decimalRegExp = RegExp(
    r'^([+-]?\d*)(?:\.(\d*))?(?:[eE]([+-]?\d+))?$',
  );

  static final RegExp _groupRegExp = RegExp(r'\B(?=(\d{3})+(?!\d))');

  static String formatCompact(double n, [int precision = 2]) {
    try {
      if (n >= 1e9) {
        n /= 1e9;
        return "${n.toStringAsFixed(precision)}B";
      } else if (n >= 1e6) {
        n /= 1e6;
        return "${n.toStringAsFixed(precision)}M";
      } else if (n >= 1e4) {
        n /= 1e3;
        return "${n.toStringAsFixed(precision)}K";
      } else {
        return n.toStringAsFixed(precision);
      }
    } catch (e) {
      return n.toString();
    }
  }

  static bool checkNotNullOrZero(double? a) {
    if (a == null || a == 0) {
      return false;
    } else if (a.abs().toStringAsFixed(4) == "0.0000") {
      return false;
    } else {
      return true;
    }
  }

  static String? formatFixed(Object? value, int precision) {
    try {
      final (bigIntValue, scale) = _parseDecimal(value.toString());
      final String number = _toPlainString(bigIntValue, scale);
      final List<String> parts = number.split('.');
      final String integerPart = _groupThousands(parts.first);

      if (precision == 0) {
        return integerPart;
      }

      String fractionalPart = (parts.length <= 1 ? '' : parts.last).padRight(
        precision,
        '0',
      );

      fractionalPart = fractionalPart.substring(0, precision);

      return '$integerPart.$fractionalPart';
    } catch (e) {
      return null;
    }
  }

  static String? format(Object? value, int precision) {
    try {
      var (bigIntValue, scale) = _parseDecimal(value.toString());

      if (precision < scale) {
        final BigInt divisor = BigInt.from(10).pow(scale - precision);
        BigInt quotient = bigIntValue ~/ divisor;
        if (bigIntValue.remainder(divisor) != BigInt.zero &&
            bigIntValue.isNegative) {
          quotient -= BigInt.one;
        }
        bigIntValue = quotient;
        scale = precision;
      }

      final String number = _toPlainString(bigIntValue, scale);
      final List<String> parts = number.split('.');
      final String integerPart = _groupThousands(parts.first);

      if (parts.length == 1) {
        return integerPart;
      }

      return '$integerPart.${parts.last}';
    } catch (e) {
      return null;
    }
  }

  static (BigInt, int) _parseDecimal(String source) {
    final Match? match = _decimalRegExp.firstMatch(source);
    if (match == null) {
      throw FormatException('$source is not a valid decimal');
    }

    final String group1 = match.group(1) ?? '';
    final String group2 = match.group(2) ?? '';
    final String? group3 = match.group(3);
    final BigInt value = BigInt.parse('$group1$group2');

    var scale = group3 == null ? 0 : -int.parse(group3);
    scale += group2.length;

    return (value, scale);
  }

  static String _toPlainString(BigInt value, int scale) {
    if (value == BigInt.zero) {
      return '0';
    }

    var digits = value.abs().toString();
    var s = scale;
    while (digits.endsWith('0')) {
      digits = digits.substring(0, digits.length - 1);
      s -= 1;
    }

    String result;
    if (s <= 0) {
      result = digits + '0' * -s;
    } else if (digits.length <= s) {
      result = '0.${'0' * (s - digits.length)}$digits';
    } else {
      result =
          '${digits.substring(0, digits.length - s)}.'
          '${digits.substring(digits.length - s)}';
    }

    return value.isNegative ? '-$result' : result;
  }

  static String _groupThousands(String digits) {
    return digits.replaceAllMapped(_groupRegExp, (match) => ',');
  }
}
