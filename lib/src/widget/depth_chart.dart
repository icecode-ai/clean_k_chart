import 'package:clean_k_chart/src/model/entity/depth_entity.dart';
import 'package:clean_k_chart/src/render/painter/depth_chart_painter.dart';
import 'package:clean_k_chart/src/i18n/chart_translations.dart';
import 'package:clean_k_chart/src/style/depth_chart_style.dart';
import 'package:flutter/material.dart';

class DepthChart extends StatefulWidget {
  final List<DepthEntity> bids, asks;
  final int baseUnit;
  final int quoteUnit;
  final Offset offset;
  final DepthChartColors chartColors;
  final DepthChartStyle chartStyle;
  final DepthChartTranslations chartTranslations;

  DepthChart(
    this.bids,
    this.asks,
    this.chartColors, {
    this.baseUnit = 2,
    this.quoteUnit = 6,
    this.offset = const Offset(8, 0),
    this.chartTranslations = const DepthChartTranslations(),
    this.chartStyle = const DepthChartStyle(),
  });

  @override
  _DepthChartState createState() => _DepthChartState();
}

class _DepthChartState extends State<DepthChart> {
  Offset? pressOffset;
  bool isLongPress = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        pressOffset = details.localPosition;
        isLongPress = true;
        setState(() {});
      },
      onLongPressMoveUpdate: (details) {
        pressOffset = details.localPosition;
        isLongPress = true;
        setState(() {});
      },
      onLongPressEnd: (details) {
        pressOffset = null;
        isLongPress = false;
        setState(() {});
      },
      child: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: DepthChartPainter(
          widget.bids,
          widget.asks,
          pressOffset,
          isLongPress,
          widget.baseUnit,
          widget.quoteUnit,
          widget.chartColors,
          widget.chartStyle,
          widget.offset,
          widget.chartTranslations,
        ),
      ),
    );
  }
}
