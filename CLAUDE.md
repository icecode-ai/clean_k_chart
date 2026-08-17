# clean_k_chart

Flutter library package providing K-line/candlestick charts. Early stage: README/CHANGELOG are placeholders, no tests yet. Derived from `k_chart_plus` (read-only reference at workspace `readonly-dependencies/k_chart_plus`).

## Commands

- `flutter pub get` — fetch dependencies (`decimal`, `intl`)
- `flutter analyze` — static analysis (flutter_lints ^6.0.0 via `analysis_options.yaml`)
- `dart format .` — formatting
- `flutter test` — no `test/` dir yet

## Structure

- `lib/clean_k_chart.dart` — public API entry; re-exports all public parts below
- `lib/k_chart_widget.dart` — main chart widget `KChartWidget`
- `lib/depth_chart.dart` — depth chart widget `DepthChart`
- `lib/entity/` — data models (`KLineEntity` etc.)
- `lib/indicator/indicator_template.dart` — abstract `IndicatorTemplate<T, K>` base
- `lib/indicator/main/` — price-panel overlays: MA / EMA / BOLL / SAR
- `lib/indicator/secondary/` — sub-panels: MACD / KDJ / RSI / WR / CCI
- `lib/renderer/` — CustomPainter-based renderers (`chart_painter`, main/vol/secondary renderers)
- `lib/styles/` — chart style configs (colors, candle width)
- `lib/utils/data_util.dart` — `DataUtil.calculateAll/calculateIndicators` computes indicator values into `KLineEntity` lists
- `lib/chart_translations.dart` — chart UI strings

## Conventions

- Dart SDK ^3.13.0
- New public API must be re-exported from `lib/clean_k_chart.dart`
- New indicators extend `IndicatorTemplate` and go under `indicator/main/` or `indicator/secondary/`
