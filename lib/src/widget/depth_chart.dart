import 'package:clean_k_chart/src/i18n/chart_translations.dart';
import 'package:clean_k_chart/src/model/entity/depth_entity.dart';
import 'package:clean_k_chart/src/render/depth_renderer_cache.dart';
import 'package:clean_k_chart/src/render/painter/depth_chart_painter.dart';
import 'package:clean_k_chart/src/style/depth_chart_style.dart';
import 'package:flutter/material.dart';

/// Depth (bid/ask cumulative volume) chart with a long-press selection
/// popup.
class DepthChart extends StatefulWidget {
  final List<DepthEntity> bids;
  final List<DepthEntity> asks;
  final DepthChartColors chartColors;
  final DepthChartStyle chartStyle;
  final ChartTranslations translations;

  /// Decimal digits of the volume axis.
  final int baseUnit;

  /// Decimal digits of the price axis.
  final int quoteUnit;

  /// Popup placement offset.
  final Offset offset;

  const DepthChart({
    super.key,
    required this.bids,
    required this.asks,
    this.chartColors = const DepthChartColors(),
    this.chartStyle = const DepthChartStyle(),
    this.translations = const ChartTranslations(),
    this.baseUnit = 2,
    this.quoteUnit = 6,
    this.offset = const Offset(8, 0),
  });

  @override
  State<DepthChart> createState() => _DepthChartState();
}

class _DepthChartState extends State<DepthChart> {
  final DepthRendererCache _rendererCache = DepthRendererCache();

  Offset? _pressOffset;
  bool _isLongPress = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        setState(() {
          _pressOffset = details.localPosition;
          _isLongPress = true;
        });
      },
      onLongPressMoveUpdate: (details) {
        setState(() {
          _pressOffset = details.localPosition;
        });
      },
      onLongPressEnd: (details) {
        setState(() {
          _pressOffset = null;
          _isLongPress = false;
        });
      },
      onLongPressCancel: () {
        setState(() {
          _pressOffset = null;
          _isLongPress = false;
        });
      },
      child: RepaintBoundary(
        child: CustomPaint(
          size: const Size(double.infinity, double.infinity),
          painter: DepthChartPainter(
            bids: widget.bids,
            asks: widget.asks,
            pressOffset: _pressOffset,
            isLongPress: _isLongPress,
            baseUnit: widget.baseUnit,
            quoteUnit: widget.quoteUnit,
            chartColors: widget.chartColors,
            chartStyle: widget.chartStyle,
            offset: widget.offset,
            translations: widget.translations,
            rendererCache: _rendererCache,
          ),
        ),
      ),
    );
  }
}
