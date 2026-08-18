import 'package:clean_k_chart/src/indicator/indicator.dart';
import 'package:clean_k_chart/src/model/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/model/entity/trend_line.dart';
import 'package:clean_k_chart/src/render/chart_dimension.dart';
import 'package:clean_k_chart/src/render/chart_viewport.dart';
import 'package:clean_k_chart/src/render/painter/chart_painter.dart';
import 'package:clean_k_chart/src/render/renderer_cache.dart';
import 'package:clean_k_chart/src/style/indicator_style.dart';
import 'package:clean_k_chart/src/style/k_chart_style.dart';
import 'package:flutter/material.dart';

/// Builds the detail dialog content for the selected K-line.
typedef KLineDetailBuilder = Widget Function(KLineEntity entity);

/// Interactive K-line (candlestick) chart.
///
/// Indicator values are NOT calculated by this widget — run them through
/// [IndicatorCalculator.calculateAll] (or [Indicator.calc]) before passing
/// the data list.
class KChartWidget extends StatefulWidget {
  final List<KLineEntity>? data;
  final List<MainIndicator> mainIndicators;
  final List<SecondaryIndicator> secondaryIndicators;
  final IndicatorStyles indicatorStyles;
  final KChartColors chartColors;
  final KChartStyle chartStyle;

  /// Hides the volume panel.
  final bool volHidden;

  /// Draws a close-price line instead of candlesticks.
  final bool isLine;

  /// Whether a tap on the main panel pins the crosshair + detail dialog.
  final bool tapShowInfoDialog;

  final bool hideGrid;
  final bool showNowPrice;

  /// Whether the detail dialog overlay is enabled at all.
  final bool showInfoDialog;

  final int fixedLength;
  final double baseHeight;
  final double? secondaryHeight;
  final VerticalTextAlignment verticalTextAlignment;

  /// Enables the trend-line authoring mode.
  final bool trendLineEnabled;

  /// Extra right-hand padding reserved in the data area.
  final double xFrontPadding;

  final KLineDetailBuilder detailBuilder;

  /// Called when the chart is flung to either horizontal end.
  /// `true`: the right (latest) end; `false`: the left (oldest) end.
  final void Function(bool scrollToEnd)? onLoadMore;

  /// Notifies whether a drag/fling interaction is in progress.
  final void Function(bool dragging)? onDragChanged;

  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;

  const KChartWidget({
    super.key,
    this.data,
    required this.detailBuilder,
    this.chartStyle = const KChartStyle(),
    this.chartColors = const KChartColors(),
    this.indicatorStyles = const IndicatorStyles(),
    this.mainIndicators = const [],
    this.secondaryIndicators = const [],
    this.trendLineEnabled = false,
    this.xFrontPadding = 0,
    this.volHidden = false,
    this.isLine = false,
    this.tapShowInfoDialog = false,
    this.hideGrid = true,
    this.showNowPrice = true,
    this.showInfoDialog = true,
    this.fixedLength = 2,
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.onLoadMore,
    this.onDragChanged,
    this.verticalTextAlignment = VerticalTextAlignment.right,
    this.baseHeight = 360,
    this.secondaryHeight,
  });

  @override
  State<KChartWidget> createState() => _KChartWidgetState();
}

enum _GestureMode { idle, drag, scale, longPress }

class _KChartWidgetState extends State<KChartWidget>
    with SingleTickerProviderStateMixin {
  final ChartRendererCache _rendererCache = ChartRendererCache();
  ChartViewport? _viewport;

  double _scaleX = 0.5;
  double _lastScale = 0.5;
  double _scrollX = 0;
  double _selectX = 0;
  double _selectY = 0;
  _GestureMode _mode = _GestureMode.idle;

  bool _showCrosshair = false;
  bool _showDetail = false;
  bool _detailOnLeft = false;
  KLineEntity? _detailEntity;

  late final AnimationController _flingController = AnimationController(
    vsync: this,
  );
  double _flingBegin = 0;
  double _flingEnd = 0;

  // Trend-line authoring state.
  final List<TrendLine> _trendLines = [];
  int _trendVersion = 0;
  Offset? _lastTrendPointer;
  bool _awaitingSecondPoint = false;
  bool _canRecordTrend = false;

  @override
  void initState() {
    super.initState();
    _flingController.addListener(_onFlingTick);
    _flingController.addStatusListener(_onFlingStatus);
  }

  @override
  void didUpdateWidget(KChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      final data = widget.data;
      if (data == null || data.isEmpty) {
        _scrollX = 0;
        _selectX = 0;
        _scaleX = 0.5;
        _lastScale = 0.5;
      }
      _showDetail = false;
      _showCrosshair = false;
      _detailEntity = null;
    }
  }

  @override
  void dispose() {
    _flingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimension = ChartDimension(
      baseHeight: widget.baseHeight,
      secondaryHeight: widget.secondaryHeight ?? widget.baseHeight * 0.2,
      volHidden: widget.volHidden,
      secondaryCount: widget.secondaryIndicators.length,
      mainLabelCount: widget.mainIndicators.length,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth ? constraints.maxWidth : 0.0;
        final viewport =
            _viewport ??
            ChartViewport(
              pointWidth: widget.chartStyle.pointWidth,
              frontPadding: widget.xFrontPadding,
            );
        _viewport = viewport;
        viewport
          ..width = width
          ..itemCount = widget.data?.length ?? 0
          ..pointWidth = widget.chartStyle.pointWidth
          ..frontPadding = widget.xFrontPadding;
        _scrollX = _scrollX.clamp(0.0, viewport.maxScrollX);

        final painter = ChartPainter(
          chartStyle: widget.chartStyle,
          chartColors: widget.chartColors,
          indicatorStyles: widget.indicatorStyles,
          data: widget.data,
          viewport: viewport,
          mainIndicators: widget.mainIndicators,
          secondaryIndicators: widget.secondaryIndicators,
          rendererCache: _rendererCache,
          dimension: dimension,
          showCrosshair: _showCrosshair,
          selectX: _selectX,
          trendLineEnabled: widget.trendLineEnabled,
          trendLines: _trendLines,
          selectY: _selectY,
          trendVersion: _trendVersion,
          volHidden: widget.volHidden,
          isLine: widget.isLine,
          hideGrid: widget.hideGrid,
          showNowPrice: widget.showNowPrice,
          tapShowInfoDialog: widget.tapShowInfoDialog,
          fixedLength: widget.fixedLength,
          verticalTextAlignment: widget.verticalTextAlignment,
        );

        return GestureDetector(
          onTapUp: (details) => _onTapUp(painter, details),
          onHorizontalDragDown: (_) => _onDragDown(),
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onHorizontalDragCancel: _onDragCancel,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          onLongPressStart: _onLongPressStart,
          onLongPressMoveUpdate: _onLongPressMoveUpdate,
          onLongPressEnd: _onLongPressEnd,
          onLongPressCancel: _onLongPressCancel,
          child: Stack(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(double.infinity, dimension.displayHeight),
                  painter: painter,
                ),
              ),
              if (widget.showInfoDialog) _buildDetailDialog(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailDialog() {
    final entity = _detailEntity;
    if (!_showDetail || widget.isLine || entity == null) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: _detailOnLeft ? 10.0 : null,
      right: _detailOnLeft ? null : 10.0,
      child: widget.detailBuilder(entity),
    );
  }

  // ---------------------------------------------------------------------
  // Gesture handling
  // ---------------------------------------------------------------------

  void _onTapUp(ChartPainter painter, TapUpDetails details) {
    if (!widget.trendLineEnabled) {
      final inMain = painter.mainRect?.contains(details.localPosition) ?? false;
      if (inMain &&
          widget.tapShowInfoDialog &&
          _selectX != details.localPosition.dx) {
        _selectX = details.localPosition.dx;
        _selectY = details.localPosition.dy;
        _showCrosshair = true;
        _updateDetail();
        setState(() {});
      }
      return;
    }

    // Trend-line authoring: capture anchor points on tap.
    if (_mode == _GestureMode.longPress || !_canRecordTrend) return;
    _canRecordTrend = false;
    final anchor = _captureTrendAnchor();
    if (anchor == null) return;
    if (!_awaitingSecondPoint) {
      _trendLines.add(TrendLine(anchor, null));
      _awaitingSecondPoint = true;
    } else {
      final start = _trendLines.isNotEmpty ? _trendLines.last.start : anchor;
      _trendLines
        ..removeLast()
        ..add(TrendLine(start, anchor));
      _awaitingSecondPoint = false;
    }
    _trendVersion++;
    setState(() {});
  }

  /// Captures the current selection as a (data x, price) anchor.
  Offset? _captureTrendAnchor() {
    final viewport = _viewport;
    final mainRenderer = _rendererCache.main;
    if (viewport == null || mainRenderer == null || viewport.itemCount == 0) {
      return null;
    }
    final dataX = viewport.getX(viewport.selectedIndex(_selectX));
    final price = mainRenderer.valueFromY(_selectY);
    return Offset(dataX, price);
  }

  void _onDragDown() {
    _mode = _GestureMode.drag;
    _showCrosshair = false;
    _showDetail = false;
    _stopFling();
    _setDragging(true);
    setState(() {});
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_mode == _GestureMode.longPress) return;
    final viewport = _viewport;
    if (viewport == null) return;
    _scrollX = ((details.primaryDelta ?? 0) / _scaleX + _scrollX).clamp(
      0.0,
      viewport.maxScrollX,
    );
    setState(() {});
  }

  void _onDragEnd(DragEndDetails details) {
    _onFling(details.velocity.pixelsPerSecond.dx);
  }

  void _onDragCancel() {
    _mode = _GestureMode.idle;
    _setDragging(false);
    setState(() {});
  }

  void _onScaleStart(ScaleStartDetails details) {
    if (_mode == _GestureMode.idle) {
      _mode = _GestureMode.scale;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_mode == _GestureMode.drag || _mode == _GestureMode.longPress) return;
    _scaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
    setState(() {});
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _mode = _GestureMode.idle;
    _lastScale = _scaleX;
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _mode = _GestureMode.longPress;
    _selectX = details.localPosition.dx;
    _selectY = details.localPosition.dy;
    _lastTrendPointer = details.localPosition;
    _showCrosshair = !widget.trendLineEnabled;
    if (!widget.trendLineEnabled) {
      _updateDetail();
    }
    setState(() {});
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!widget.trendLineEnabled) {
      _selectX = details.localPosition.dx;
      _selectY = details.localPosition.dy;
      _updateDetail();
    } else {
      final last = _lastTrendPointer;
      if (last != null) {
        _selectX += details.localPosition.dx - last.dx;
        _selectY += details.localPosition.dy - last.dy;
      }
      _lastTrendPointer = details.localPosition;
    }
    setState(() {});
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _finishLongPress(recordTrendPoint: true);
  }

  void _onLongPressCancel() {
    _finishLongPress(recordTrendPoint: false);
  }

  void _finishLongPress({required bool recordTrendPoint}) {
    _mode = _GestureMode.idle;
    _showCrosshair = false;
    _showDetail = false;
    if (recordTrendPoint && widget.trendLineEnabled) {
      _canRecordTrend = true;
    }
    setState(() {});
  }

  // ---------------------------------------------------------------------
  // Fling
  // ---------------------------------------------------------------------

  void _onFling(double velocity) {
    _flingBegin = _scrollX;
    _flingEnd = _scrollX + velocity * widget.flingRatio;
    _flingController.duration = Duration(milliseconds: widget.flingTime);
    _flingController.forward(from: 0);
  }

  void _onFlingTick() {
    final t = widget.flingCurve.transform(_flingController.value);
    _scrollX = _flingBegin + (_flingEnd - _flingBegin) * t;
    _checkFlingBounds();
    setState(() {});
  }

  void _checkFlingBounds() {
    final viewport = _viewport;
    if (viewport == null) return;
    if (_scrollX <= 0) {
      _scrollX = 0;
      widget.onLoadMore?.call(false);
      _stopFling();
    } else if (_scrollX >= viewport.maxScrollX) {
      _scrollX = viewport.maxScrollX;
      widget.onLoadMore?.call(true);
      _stopFling();
    }
  }

  void _stopFling() {
    if (_flingController.isAnimating) {
      _flingController.stop();
      _setDragging(false);
      setState(() {});
    }
  }

  void _onFlingStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _setDragging(false);
      setState(() {});
    }
  }

  void _setDragging(bool dragging) {
    widget.onDragChanged?.call(dragging);
  }

  // ---------------------------------------------------------------------
  // Detail dialog
  // ---------------------------------------------------------------------

  void _updateDetail() {
    final data = widget.data;
    final viewport = _viewport;
    if (data == null || data.isEmpty || viewport == null) {
      _detailEntity = null;
      _showDetail = false;
      return;
    }
    var index = viewport.selectedIndex(_selectX);
    if (index < 0) index = 0;
    if (index > data.length - 1) index = data.length - 1;
    _detailEntity = data[index];
    // Dialog on the left when the selected point sits on the right half.
    _detailOnLeft =
        viewport.dataXToX(viewport.getX(index)) >= viewport.width / 2;
    _showDetail = true;
  }
}
