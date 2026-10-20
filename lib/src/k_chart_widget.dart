import 'dart:async';

import 'package:clean_k_chart/src/entity/info_window_entity.dart';
import 'package:clean_k_chart/src/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/indicator/indicator_template.dart';
import 'package:clean_k_chart/src/renderer/base_dimension.dart';
import 'package:clean_k_chart/src/renderer/chart_painter.dart';
import 'package:clean_k_chart/src/renderer/main_renderer.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:clean_k_chart/src/utils/data_util.dart';
import 'package:clean_k_chart/src/utils/date_format_util.dart';
import 'package:flutter/widgets.dart';

typedef WidgetDetailBuilder = Widget Function(KLineEntity entity);

/// Common date formats accepted by [KChartStyle.dateTimeFormat].
class TimeFormat {
  static const List<String> yearMonthDay = [yyyy, '-', mm, '-', dd];
  static const List<String> yearMonthDayWithHour = [
    yyyy,
    '-',
    mm,
    '-',
    dd,
    ' ',
    HH,
    ':',
    nn,
  ];
}

class KChartWidget extends StatefulWidget {
  final List<KLineEntity>? datas;
  final List<MainIndicator> mainIndicators;

  /// warning only using MA, BOLL, SAR
  final bool volHidden;
  final List<SecondaryIndicator> secondaryIndicators;

  /// SecondaryState { MACD, KDJ, RSI, WR, CCI }
  final bool isLine;
  final bool isTapShowInfoDialog;
  final bool hideGrid;
  final bool showNowPrice;
  final bool showInfoDialog;
  final double mBaseHeight;
  final double? mSecondaryHeight;

  /// It will be called when the screen scrolls to the end.
  /// If true, it will be scrolled to the end of the right side of the screen.
  /// If it is false, it will be scrolled to the end of the left side of the screen.
  final Function(bool)? onLoadMore;

  final int fixedLength;
  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;
  final Function(bool)? isOnDrag;
  final KChartColors chartColors;
  final KChartStyle chartStyle;
  final VerticalTextAlignment verticalTextAlignment;
  final double xFrontPadding;
  final WidgetDetailBuilder detailBuilder;

  const KChartWidget(
    this.datas,
    this.chartStyle,
    this.chartColors, {
    super.key,
    required this.detailBuilder,
    this.xFrontPadding = 0,
    this.mainIndicators = const [],
    this.secondaryIndicators = const [],
    this.volHidden = false,
    this.isLine = false,
    this.isTapShowInfoDialog = false,
    this.hideGrid = true,
    this.showNowPrice = true,
    this.showInfoDialog = true,
    this.onLoadMore,
    this.fixedLength = 2,
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
    this.verticalTextAlignment = VerticalTextAlignment.right,
    this.mBaseHeight = 360,
    this.mSecondaryHeight,
  });

  @override
  State<StatefulWidget> createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  final StreamController<InfoWindowEntity?> mInfoWindowStream =
      StreamController<InfoWindowEntity?>();
  double mScaleX = 0.5, mScrollX = 0.0, mSelectX = 0.0;
  AnimationController? _controller;
  Animation<double>? aniX;

  /// The painter of the latest frame. Kept so gesture handlers can read
  /// per-instance values such as [ChartPainter.maxScrollX].
  ChartPainter? _painter;

  /// Last info window pushed to [mInfoWindowStream]. Used to drop duplicate
  /// notifications produced during painting, which would otherwise trigger an
  /// endless repaint loop while the selection stays on the same candle.
  InfoWindowEntity? _lastInfoWindow;

  /// Data list the indicators were last calculated for. `calculateAll` mutates
  /// the entities in place, so it only has to run when the data (or the
  /// selected indicators) actually change.
  List<KLineEntity>? _calculatedDatas;
  int _calculatedDataLength = -1;
  List<MainIndicator>? _calculatedMainIndicators;
  List<SecondaryIndicator>? _calculatedSecondaryIndicators;

  double _lastScale = 0.5;
  bool isScale = false, isDrag = false, isLongPress = false, isOnTap = false;

  @override
  void dispose() {
    mInfoWindowStream.close();

    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas != null && widget.datas!.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 0.5;
    }

    _calculateIndicatorsIfNeeded();

    final BaseDimension baseDimension = BaseDimension(
      mBaseHeight: widget.mBaseHeight,
      mSecondaryHeight: widget.mSecondaryHeight ?? widget.mBaseHeight * .2,
      volHidden: widget.volHidden,
      secondaryIndicators: widget.secondaryIndicators,
      mainIndicators: widget.mainIndicators,
    );

    final ChartPainter painter = ChartPainter(
      widget.chartStyle,
      widget.chartColors,
      baseDimension: baseDimension,
      onInfoWindow: _pushInfoWindow,
      xFrontPadding: widget.xFrontPadding,
      datas: widget.datas,
      scaleX: mScaleX,
      scrollX: mScrollX,
      selectX: mSelectX,
      isLongPress: isLongPress,
      isOnTap: isOnTap,
      isTapShowInfoDialog: widget.isTapShowInfoDialog,
      mainIndicators: widget.mainIndicators,
      volHidden: widget.volHidden,
      secondaryIndicators: widget.secondaryIndicators,
      isLine: widget.isLine,
      hideGrid: widget.hideGrid,
      showNowPrice: widget.showNowPrice,
      fixedLength: widget.fixedLength,
      verticalTextAlignment: widget.verticalTextAlignment,
    );

    _painter = painter;

    return GestureDetector(
      onTapUp: (details) {
        if (painter.isInMainRect(details.localPosition)) {
          isOnTap = true;

          if (mSelectX != details.localPosition.dx &&
              widget.isTapShowInfoDialog) {
            mSelectX = details.localPosition.dx;
            notifyChanged();
          }
        }
      },
      onHorizontalDragDown: (details) {
        isOnTap = false;

        _stopAnimation();
        _onDragChanged(true);
      },
      onHorizontalDragUpdate: (details) {
        if (isScale || isLongPress) {
          return;
        }

        mScrollX = ((details.primaryDelta ?? 0) / mScaleX + mScrollX)
            .clamp(0.0, painter.maxScrollX)
            .toDouble();

        notifyChanged();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        _onFling(details.velocity.pixelsPerSecond.dx);
      },
      onHorizontalDragCancel: () => _onDragChanged(false),
      onScaleStart: (_) {
        isScale = true;
      },
      onScaleUpdate: (details) {
        if (isDrag || isLongPress) {
          return;
        }

        mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);

        notifyChanged();
      },
      onScaleEnd: (_) {
        isScale = false;
        _lastScale = mScaleX;
      },
      onLongPressStart: (details) {
        isOnTap = false;
        isLongPress = true;

        if (mSelectX != details.localPosition.dx) {
          mSelectX = details.localPosition.dx;

          notifyChanged();
        }
      },
      onLongPressMoveUpdate: (details) {
        if (mSelectX != details.localPosition.dx) {
          mSelectX = details.localPosition.dx;

          notifyChanged();
        }
      },
      onLongPressEnd: (details) {
        isLongPress = false;
        _pushInfoWindow(null);

        notifyChanged();
      },
      child: Stack(
        children: <Widget>[
          CustomPaint(
            size: Size(double.infinity, baseDimension.mDisplayHeight),
            painter: painter,
          ),
          if (widget.showInfoDialog) _buildInfoDialog(),
        ],
      ),
    );
  }

  /// Calculates indicator values for [KChartWidget.datas] when the data list
  /// or the indicator configuration changed.
  ///
  /// [DataUtil.calculateAll] writes its results back into the entities, so
  /// repeated runs are idempotent.
  void _calculateIndicatorsIfNeeded() {
    final datas = widget.datas;
    if (datas == null || datas.isEmpty) {
      return;
    }

    final bool dataChanged =
        !identical(datas, _calculatedDatas) ||
        datas.length != _calculatedDataLength;

    final bool indicatorsChanged =
        !identical(widget.mainIndicators, _calculatedMainIndicators) ||
        !identical(widget.secondaryIndicators, _calculatedSecondaryIndicators);

    if (!dataChanged && !indicatorsChanged) {
      return;
    }

    _calculatedDatas = datas;
    _calculatedDataLength = datas.length;
    _calculatedMainIndicators = widget.mainIndicators;
    _calculatedSecondaryIndicators = widget.secondaryIndicators;

    DataUtil.calculateAll(
      datas,
      widget.mainIndicators,
      widget.secondaryIndicators,
    );
  }

  /// Forwards [info] to the info dialog stream unless it is identical to the
  /// previously pushed value.
  void _pushInfoWindow(InfoWindowEntity? info) {
    final InfoWindowEntity? last = _lastInfoWindow;
    if (last == info) {
      return;
    }

    if (last != null && info != null && last.isLeft == info.isLeft) {
      if (identical(last.kLineEntity, info.kLineEntity)) {
        return;
      }
    }

    _lastInfoWindow = info;

    mInfoWindowStream.sink.add(info);
  }

  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller!.isAnimating) {
      _controller!.stop();

      _onDragChanged(false);

      if (needNotify) {
        notifyChanged();
      }
    }
  }

  void _onDragChanged(bool isOnDrag) {
    isDrag = isOnDrag;

    if (widget.isOnDrag != null) {
      widget.isOnDrag!(isDrag);
    }
  }

  void _onFling(double x) {
    _controller?.dispose();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.flingTime),
      vsync: this,
    );

    aniX = Tween<double>(begin: mScrollX, end: x * widget.flingRatio + mScrollX)
        .animate(
          CurvedAnimation(parent: _controller!.view, curve: widget.flingCurve),
        );

    aniX!.addListener(() {
      mScrollX = aniX!.value;
      if (mScrollX <= 0) {
        mScrollX = 0;

        if (widget.onLoadMore != null) {
          widget.onLoadMore!(true);
        }

        _stopAnimation();
      } else if (mScrollX >= (_painter?.maxScrollX ?? 0)) {
        mScrollX = _painter?.maxScrollX ?? 0;

        if (widget.onLoadMore != null) {
          widget.onLoadMore!(false);
        }

        _stopAnimation();
      }

      notifyChanged();
    });

    aniX!.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });

    _controller!.forward();
  }

  void notifyChanged() => setState(() {});

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity?>(
      stream: mInfoWindowStream.stream,
      builder: (context, snapshot) {
        if ((!isLongPress && !isOnTap) ||
            widget.isLine == true ||
            !snapshot.hasData ||
            snapshot.data?.kLineEntity == null) {
          return const SizedBox();
        }

        final KLineEntity entity = snapshot.data!.kLineEntity;
        if (snapshot.data!.isLeft) {
          return Positioned(
            left: 10.0,
            child: widget.detailBuilder.call(entity),
          );
        }

        return Positioned(
          right: 10.0,
          child: widget.detailBuilder.call(entity),
        );
      },
    );
  }
}
