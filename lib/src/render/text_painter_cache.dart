import 'package:flutter/painting.dart';

/// Cache of laid-out [TextPainter]s keyed by text + style, so repeated
/// axis / label text skips re-layout each frame.
class TextPainterCache {
  final _entries = <String, TextPainter>{};

  static const int _maxEntries = 96;

  /// Returns a laid-out painter for [text] rendered with [style].
  TextPainter obtain(String text, TextStyle style) {
    final key = '${style.color?.toARGB32() ?? 0}|${style.fontSize ?? 0}|$text';
    final cached = _entries[key];
    if (cached != null) return cached;

    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    if (_entries.length >= _maxEntries) {
      _entries.remove(_entries.keys.first);
    }
    _entries[key] = painter;
    return painter;
  }

  void clear() => _entries.clear();
}
