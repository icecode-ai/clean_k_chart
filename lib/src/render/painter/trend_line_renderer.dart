import 'dart:ui';

import 'package:clean_k_chart/src/model/entity/trend_line.dart';
import 'package:clean_k_chart/src/render/chart_viewport.dart';
import 'package:clean_k_chart/src/render/renderer/main_renderer.dart';

/// Draws the trend-line authoring guides and the stored [TrendLine]s.
///
/// All coordinates are screen coordinates: stored lines keep the data x
/// and the price value, and are projected through the current viewport /
/// main renderer mapping each frame.
class TrendLineRenderer {
  final Paint _guidePaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;
  final Paint _linePaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  void draw(
    Canvas canvas,
    Size size, {
    required List<TrendLine> lines,
    required ChartViewport viewport,
    required MainRenderer mainRenderer,
    required Color guideColor,
    required Color lineColor,
    required double selectX,
    required double selectY,
    required double topPadding,
  }) {
    final index = viewport.selectedIndex(selectX);
    final cursorX = viewport.dataXToX(viewport.getX(index));

    _guidePaint.color = guideColor;
    canvas.drawLine(
      Offset(cursorX, topPadding),
      Offset(cursorX, size.height),
      _guidePaint,
    );
    final dataLeft = viewport.dataXToX(0);
    canvas.drawLine(
      Offset(dataLeft, selectY),
      Offset(dataLeft + size.width / viewport.scaleX, selectY),
      _guidePaint,
    );

    // Cursor marker.
    final oval = viewport.scaleX >= 1
        ? Rect.fromCenter(
            center: Offset(cursorX, selectY),
            height: 15.0 * viewport.scaleX,
            width: 15.0,
          )
        : Rect.fromCenter(
            center: Offset(cursorX, selectY),
            height: 10.0,
            width: 10.0 / viewport.scaleX,
          );
    canvas.drawOval(oval, _guidePaint);

    _linePaint.color = lineColor;
    for (final line in lines) {
      final start = Offset(
        viewport.dataXToX(line.start.dataX),
        mainRenderer.getY(line.start.price),
      );
      final end = line.end == null
          ? Offset(cursorX, selectY)
          : Offset(
              viewport.dataXToX(line.end!.dataX),
              mainRenderer.getY(line.end!.price),
            );
      canvas.drawLine(start, end, _linePaint);
    }
  }
}
