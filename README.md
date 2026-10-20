# clean_k_chart

[![pub package](https://img.shields.io/pub/v/clean_k_chart.svg)](https://pub.dev/packages/clean_k_chart)

forked from [TrangLeQuynh/k_chart_plus](https://github.com/TrangLeQuynh/k_chart_plus)

## Features
- Candlestick and line (trend) charts
- Main indicators: **MA / EMA / BOLL / SAR**
- Secondary indicators: **MACD / KDJ / RSI / WR / CCI**
- Volume chart with MA5/MA10 overlays
- Cross-line info window while long-pressing (or tapping)
- Max/min price markers, current-price dashed line
- Pinch to scale, drag to scroll, fling with load-more callbacks
- Fully customizable colors (`KChartColors`) and dimensions (`KChartStyle`)
- no Material/Cupertino dependencies

## Getting started

Add the dependency to `pubspec.yaml`:

```yaml
dependencies:
  clean_k_chart: ^1.0.0
```

## Usage

```dart
import 'package:clean_k_chart/clean_k_chart.dart';

KChartWidget(
  datas, // List<KLineEntity>
  KChartStyle(),
  KChartColors(),
  detailBuilder: (entity) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Open: ${entity.open}'),
      Text('Close: ${entity.close}'),
      Text('High: ${entity.high}'),
      Text('Low: ${entity.low}'),
      Text('Vol: ${entity.vol}'),
    ],
  ),
  mainIndicators: [MAIndicator(), BOLLIndicator()],
  secondaryIndicators: [MACDIndicator()],
  isTapShowInfoDialog: true,
  onLoadMore: (isRight) {
    // Load older (isRight == false) or newer data here.
  },
)
```

Indicator periods are configurable via `calcParams`, e.g.
`RSIIndicator(calcParams: const [14])` or
`BOLLIndicator(calcParams: const [20, 2])`.

Indicator values are computed automatically for you by `KChartWidget`; to
compute them yourself (e.g. inside your data layer) use:

```dart
DataUtil.calculateAll(datas, mainIndicators, secondaryIndicators);
```

## Additional information

- The chart forbids Material/Cupertino imports by design, so it renders
  identically under any widget set.
- Colors for every part of the chart (background, candles, grid, cross line,
  indicator lines ...) can be overridden through `KChartColors`.
