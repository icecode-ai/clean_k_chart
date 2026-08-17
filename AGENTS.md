# clean_k_chart

Flutter library package providing K-line/candlestick charts. Early stage: README/CHANGELOG are placeholders, no tests yet. Derived from `k_chart_plus` (read-only reference at workspace `readonly-dependencies/k_chart_plus`).

## Commands

- `flutter pub get` — fetch dependencies (`decimal`, `intl`)
- `flutter analyze` — static analysis (flutter_lints ^6.0.0 via `analysis_options.yaml`)
- `dart format .` — formatting
- `flutter test` — no `test/` dir yet

## Directory structure (lib/src)

Layered, one-directional: `widget → render → indicator → model`; `style` / `i18n` / `utils` are leaf layers.

| Path | Description |
|------|-------------|
| `model/entity/` | Pure data entities (KLineEntity + indicator-value mixins, DepthEntity…) |
| `indicator/` | Pure indicator calculation (`Indicator`/`MainIndicator`/`SecondaryIndicator`, 9 built-ins, `IndicatorCalculator`). No Flutter rendering imports |
| `style/` | Config classes: `KChartColors`/`KChartStyle`, `IndicatorStyle` subclasses, `DepthChartStyle` |
| `i18n/` | `ChartTranslations` |
| `render/` | All drawing code: `dimension.dart` (layout math), `painter/` (CustomPainters incl. `depth_chart_painter`), `renderer/` (chart area renderers), `indicator_view/` (indicator painters + `IndicatorPainterFactory`) |
| `widget/` | User entry points: `KChartWidget`, `DepthChart` |
| `utils/` | Internal helpers (date format, number format, extensions) |

## Conventions

- `lib/clean_k_chart.dart` is a **curated** public API — internal renderers/painters/utils are NOT exported. Keep it that way.
- Indicators must not import Flutter rendering types; their drawing lives in a matching painter under `render/indicator_view/` registered in `IndicatorPainterFactory` (custom indicators can register via `IndicatorPainterFactory.register`).
- Hungarian `m`-prefixes remain in legacy renderer/painter files; new code must not use them.
