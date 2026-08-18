import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/view/indicator_painter.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart' show KChartColors;
import 'package:flutter/painting.dart';

/// Shared implementation for multi-line main indicators (MA / EMA):
/// one line per calc param over a per-entity value list.
abstract class MultiLineIndicatorPainter extends IndicatorPainter {
  final MovingAverageStyle style;

  final Paint _linePaint = Paint()
    ..isAntiAlias = true
    ..filterQuality = FilterQuality.high;

  MultiLineIndicatorPainter(
    super.indicator, {
    this.style = const MovingAverageStyle(),
  }) {
    _linePaint.strokeWidth = style.lineWidth;
  }

  /// Label prefix, e.g. `MA` or `EMA`.
  String get labelPrefix;

  /// The indicator's value list for [entity].
  List<double?>? valuesOf(KLineEntity entity);

  @override
  TextSpan? buildLabel(
    KLineEntity entity,
    int precision,
    KChartColors chartColors,
  ) {
    final values = valuesOf(entity);
    if (values == null || values.isEmpty) return null;
    final spans = <InlineSpan>[];
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value == null) continue;
      // Values can outlive a param change on the indicator (stale entity
      // slots) — guard the param lookup instead of throwing in paint.
      final param = i < indicator.calcParams.length
          ? '${indicator.calcParams[i]}'
          : '-';
      spans.add(
        TextSpan(
          text: '$labelPrefix$param:${formatNumber(value, precision)}  ',
          style: labelStyle(style.colorFor(i)),
        ),
      );
    }
    return spans.isEmpty ? null : TextSpan(children: spans);
  }

  @override
  void drawChart(
    KLineEntity lastPoint,
    KLineEntity curPoint,
    double lastX,
    double curX,
    ValueY getY,
    Canvas canvas,
    KChartColors chartColors,
  ) {
    final lastValues = valuesOf(lastPoint);
    final curValues = valuesOf(curPoint);
    if (lastValues == null ||
        curValues == null ||
        lastValues.length != curValues.length) {
      return;
    }
    for (var i = 0; i < curValues.length; i++) {
      final lastValue = lastValues[i];
      final curValue = curValues[i];
      if (lastValue == null || curValue == null) continue;
      canvas.drawLine(
        Offset(lastX, getY(lastValue)),
        Offset(curX, getY(curValue)),
        _linePaint..color = style.colorFor(i),
      );
    }
  }
}

/// Painter for [MAIndicator].
class MAPainter extends MultiLineIndicatorPainter {
  MAPainter(super.indicator, {super.style});

  @override
  String get labelPrefix => 'MA';

  @override
  List<double?>? valuesOf(KLineEntity entity) => entity.maValues;
}
