/// Formats [dateTime] according to [pattern] (pure Dart, no dependencies).
///
/// Supported tokens: `yyyy`/`yy`, `MM`/`M`, `dd`/`d`, `HH`/`H` (24-hour),
/// `mm`/`m`, `ss`/`s` — two-digit tokens zero-pad, single-digit tokens do
/// not. Every other character is emitted as a literal, so suffixes like
/// `年`/`月`/`日` work directly. Letters outside the supported set (e.g.
/// `MMM`, `EEE`, `a`) are NOT special and pass through unchanged.
String formatDate(DateTime dateTime, String pattern) {
  final builder = StringBuffer();
  var i = 0;
  while (i < pattern.length) {
    final char = pattern[i];
    if (_tokenValues.containsKey(char)) {
      var run = 1;
      while (i + run < pattern.length && pattern[i + run] == char) {
        run++;
      }
      builder.write(_tokenValues[char]!(dateTime, run));
      i += run;
    } else {
      builder.write(char);
      i++;
    }
  }
  return builder.toString();
}

const Map<String, String Function(DateTime, int)> _tokenValues = {
  'y': _year,
  'M': _month,
  'd': _day,
  'H': _hour,
  'm': _minute,
  's': _second,
};

String _year(DateTime t, int run) =>
    run >= 3 ? t.year.toString().padLeft(4, '0') : _pad2(t.year % 100);

String _month(DateTime t, int run) =>
    run >= 2 ? _pad2(t.month) : t.month.toString();

String _day(DateTime t, int run) => run >= 2 ? _pad2(t.day) : t.day.toString();

String _hour(DateTime t, int run) =>
    run >= 2 ? _pad2(t.hour) : t.hour.toString();

String _minute(DateTime t, int run) =>
    run >= 2 ? _pad2(t.minute) : t.minute.toString();

String _second(DateTime t, int run) =>
    run >= 2 ? _pad2(t.second) : t.second.toString();

String _pad2(int value) => value.toString().padLeft(2, '0');

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
