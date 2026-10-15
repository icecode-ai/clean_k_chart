import 'dart:async';

import 'package:clean_k_chart/src/entity/info_window_entity.dart';
import 'package:clean_k_chart/src/entity/k_line_entity.dart';
import 'package:clean_k_chart/src/indicator/indicator_template.dart';
import 'package:clean_k_chart/src/renderer/base_dimension.dart';
import 'package:clean_k_chart/src/renderer/chart_painter.dart';
import 'package:clean_k_chart/src/renderer/main_renderer.dart';
import 'package:clean_k_chart/src/styles/k_chart_style.dart';
import 'package:clean_k_chart/src/utils/date_format_util.dart';
import 'package:flutter/widgets.dart';

typedef WidgetDetailBuilder = Widget Function(KLineEntity entity);

class TimeFormat {
  static const List<String> YEAR_MONTH_DAY = [yyyy, '-', mm, '-', dd];
  static const List<String> YEAR_MONTH_DAY_WITH_HOUR = [
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

  ///warning only using MA, BOLL, SAR
  final bool volHidden;
  final List<SecondaryIndicator> secondaryIndicators;

  ///SecondaryState { MACD, KDJ, RSI, WR, CCI }
  final bool isLine;
  final bool isTapShowInfoDialog;
  final bool hideGrid;
  final bool showNowPrice;
  final bool showInfoDialog;
  final bool materialInfoDialog;
  final List<String> timeFormat;
  final double mBaseHeight;
  final double? mSecondaryHeight;

  // It will be called when the screen scrolls to the end.
  // If true, it will be scrolled to the end of the right side of the screen.
  // If it is false, it will be scrolled to the end of the left side of the screen.
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
    // this.onSecondaryTap,
    this.volHidden = false,
    this.isLine = false,
    this.isTapShowInfoDialog = false,
    this.hideGrid = true,
    this.showNowPrice = true,
    this.showInfoDialog = true,
    this.materialInfoDialog = true,
    this.timeFormat = TimeFormat.YEAR_MONTH_DAY,
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

  // For TrendLine
  List<TrendLine> lines = [];
  double? changeinXposition;
  double? changeinYposition;
  double mSelectY = 0.0;
  bool waitingForOtherPairofCords = false;
  bool enableCordRecord = false;

  double getMinScrollX() {
    return mScaleX;
  }

  double _lastScale = 0.5;
  bool isScale = false, isDrag = false, isLongPress = false, isOnTap = false;

  @override
  void dispose() {
    mInfoWindowStream.sink.close();
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

    final BaseDimension baseDimension = BaseDimension(
      mBaseHeight: widget.mBaseHeight,
      mSecondaryHeight: widget.mSecondaryHeight ?? widget.mBaseHeight * .2,
      volHidden: widget.volHidden,
      secondaryIndicators: widget.secondaryIndicators,
      mainIndicators: widget.mainIndicators,
    );

    final painter = ChartPainter(
      widget.chartStyle,
      widget.chartColors,
      baseDimension: baseDimension,
      sink: mInfoWindowStream.sink,
      xFrontPadding: widget.xFrontPadding,
      datas: widget.datas,
      scaleX: mScaleX,
      scrollX: mScrollX,
      selectX: mSelectX,
      isLongPass: isLongPress,
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
        if (isScale || isLongPress) return;
        mScrollX = ((details.primaryDelta ?? 0) / mScaleX + mScrollX)
            .clamp(0.0, ChartPainter.maxScrollX)
            .toDouble();
        notifyChanged();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        var velocity = details.velocity.pixelsPerSecond.dx;
        _onFling(velocity);
      },
      onHorizontalDragCancel: () => _onDragChanged(false),
      onScaleStart: (_) {
        isScale = true;
      },
      onScaleUpdate: (details) {
        if (isDrag || isLongPress) return;
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

        if ((mSelectX != details.localPosition.dx ||
            mSelectY != details.globalPosition.dy)) {
          mSelectX = details.localPosition.dx;

          notifyChanged();
        }
      },
      onLongPressMoveUpdate: (details) {
        if ((mSelectX != details.localPosition.dx ||
            mSelectY != details.globalPosition.dy)) {
          mSelectX = details.localPosition.dx;
          mSelectY = details.localPosition.dy;

          notifyChanged();
        }
      },
      onLongPressEnd: (details) {
        isLongPress = false;
        enableCordRecord = true;
        mInfoWindowStream.sink.add(null);

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
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.flingTime),
      vsync: this,
    );

    aniX = null;
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
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
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

  late List<String> infos;

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
