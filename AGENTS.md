# clean_k_chart

Flutter library package providing K-line/candlestick charts. Derived from `k_chart_plus` (read-only reference at workspace `readonly-dependencies/k_chart_plus`).

## Commands

- `flutter pub get` — fetch dependencies (`decimal`, `intl`)
- `flutter analyze` — static analysis (flutter_lints ^6.0.0 via `analysis_options.yaml`); must report **0 issues**
- `dart format .` — formatting
- `flutter test` — no `test/` dir yet

## Directory structure (lib/src)

Layered, one-directional: `widget → render → indicator → model`; `style` / `i18n` / `utils` are leaf layers.

| Path | Description |
|------|-------------|
| `model/entity/` | Pure data entities (`KLineEntity` + one value-slot mixin per indicator: `MAEntity`, `MACDEntity`, `KDJEntity`…, `TrendLine`, `DepthEntity`) |
| `indicator/` | Pure indicator calculation (`Indicator`/`MainIndicator`/`SecondaryIndicator`, 9 built-ins, `IndicatorCalculator`, `indicator_util.dart` math helpers). **No Flutter imports at all** |
| `style/` | Config classes: `KChartColors`/`KChartStyle` (+`VerticalTextAlignment`), `IndicatorStyles` bundle + per-indicator styles, `DepthChartColors`/`DepthChartStyle` |
| `i18n/` | `ChartTranslations` |
| `render/` | All drawing code: `chart_viewport.dart` (scale/scroll windowing, one instance per chart — no statics), `chart_dimension.dart` (layout math), `renderer_cache.dart` (long-lived renderers/painters/text caches), `painter/` (`ChartPainter` orchestrator, `DepthChartPainter`, `TrendLineRenderer`), `renderer/` (panel renderers), `indicator_view/` (indicator painters + `IndicatorPainterFactory`) |
| `widget/` | User entry points: `KChartWidget`, `DepthChart` |
| `utils/` | Internal helpers (`number_util.dart`, `date_format.dart` intl wrapper) |

## Conventions

- `lib/clean_k_chart.dart` is a **curated** public API — internal renderers/painters/utils are NOT exported. Keep it that way.
- The indicator layer must stay pure Dart (no Flutter imports). Indicator styling lives in `style/indicator_style.dart` (`IndicatorStyles` bundle passed to `KChartWidget`), NOT on indicator instances; drawing lives in the matching painter under `render/indicator_view/` registered in `IndicatorPainterFactory` (custom indicators register via `IndicatorPainterFactory.register`).
- Render state (renderers, painters, `Paint`s, `TextPainter`s) must be long-lived and re-targeted via `update()` each frame — do NOT allocate render objects per paint.
- No static/global mutable state anywhere; per-chart state lives in widget state (`ChartViewport`, `ChartRendererCache`).
- Selection/detail-dialog state is computed in gesture handlers, never pushed out of `paint()`.
- Indicator values are null while warming up (no 0/-10 sentinels).
- Data contract: the widget does NOT calculate indicators — users run `IndicatorCalculator.calculateAll` (or `Indicator.calc`) on the data list before passing it.
