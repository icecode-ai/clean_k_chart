import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/render/indicator_view/main/ma_painter.dart';

/// Painter for [EMAIndicator].
class EMAPainter extends MultiLineIndicatorPainter {
  EMAPainter(super.indicator, {super.style});

  @override
  String get labelPrefix => 'EMA';

  @override
  List<double?>? valuesOf(KLineEntity entity) => entity.emaValues;
}
