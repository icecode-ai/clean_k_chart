## 0.2.0

Quality pass over the 0.1.0 structure: correctness fixes, render-object
economy and API cleanup. Breaking changes are rename/removals of dead or
misleading API surface (the package is pre-1.0 with no consumers).

### Breaking changes

* **Style**
  * `MAStyle` → `MovingAverageStyle` (it styles both MA and EMA); its
    color list `maColors` → `lineColors`.
  * `IndicatorStyle.lineWidth` is now forwarded by every subclass — it
    was silently stuck at the 1.0 default.
* **Entity layer**
  * `KLineEntity`: dead `amount`/`change`/`ratio` slots removed (parsed
    but never consumed; also dropped from the JSON round-trip).
  * `TrendLine` anchors are `TrendLineAnchor(dataX, price)` — pure data
    coordinates, no `dart:ui` `Offset` in the model layer.
  * `BollValue.up/mid/dn` are non-nullable (the indicator always sets
    all three); `emaValues` is `List<double>?` whose entries are never
    null (seeded from the first close).
* **Depth chart**
  * `bids`/`asks` are non-null; `isLongPress` removed (derived from
    `pressOffset`).
  * `baseUnit`/`quoteUnit` defaults swapped to the conventional
    volume-6 / price-2 digits (were inherited swapped).
  * `DepthChartPainter` takes a long-lived `rendererCache`
    (`DepthRendererCache`), the same pattern as `ChartPainter`.
* BOLL standard deviation is population (÷n) per the canonical
  definition (was ÷(n−1), inherited).

### Fixed

* `NumberUtil.format` produced malformed labels for integer-valued and
  short fractions (`"1,234.1234"`); the fraction now always pads to the
  requested precision.
* Non-finite / degenerate value windows (all-zero volume, NaN data) are
  sanitized to a flat range instead of producing `scaleY = Infinity`.
* `DepthChartPainter.shouldRepaint` ignored `baseUnit`/`quoteUnit`/
  `offset`, leaving stale popup formatting.
* `drawDashedLine` silently drew nothing for reversed coordinates; the
  line is now normalized, with a solid-line fallback for diagonals.
* Date labels no longer stamp `DateTime.now()` on bars without a
  timestamp; the pattern is derived once per painter, not per label.
* Empty `calcParams`/color lists, popup clamp bounds in tiny charts and
  zero grid counts no longer throw inside paint.
* MACD/BOLL/volume header labels treat 0 as a value, not as "missing"
  (null-only warm-up contract).
* `pubspec.yaml`: incoherent `flutter: ">=1.17.0"` template leftover
  removed (the Dart SDK constraint is the source of truth).

### Performance

* Depth chart: paints, paths and label/popup painters are long-lived in
  `DepthRendererCache` (previously the full set was reallocated per
  build and per long-press frame).
* `ChartPainter` overlay paints hoisted into `ChartRendererCache` —
  gesture-driven painter rebuilds allocate no render objects.
* `ChartViewport.indexOfDataX` is O(1) rounding on the uniform grid
  (previously a recursive binary search per lookup); the depth chart
  index lookup likewise.
* `TextPainterCache` is LRU with capacity 96 and is cleared when the
  style configuration changes (previously FIFO with stale entries).
* Shared helpers in `render/render_util.dart` deduplicate the value-line
  draw and the axis label style.

## 0.1.0

Structural rewrite: clearer layering, better performance and stability.
The public API is **breaking** — the package was pre-1.0 with no consumers,
so names were fixed now rather than deprecated.

### Breaking changes

* **Entity layer**
  * `MACDEntity` is no longer a grab-bag of every secondary indicator —
    it now only holds `dif`/`dea`/`macd`. Each secondary indicator has its
    own mixin (`KDJEntity`, `RSIEntity`, `WREntity`, `CCIEntity`) applied
    on `KLineEntity`.
  * `rw_entity.dart` → `wr_entity.dart`; field `r` → `wr`.
  * `MA5Volume`/`MA10Volume` → `ma5Volume`/`ma10Volume` (camelCase).
  * `maValueList`/`emaValueList` → `maValues`/`emaValues`, element type is
    now `double?` (null = warm-up, no more 0 sentinels).
  * `Boll.BOLLMA` internal scratch field removed; `Boll` → `BollValue`.
  * `KEntity` and `InfoWindowEntity` removed; OHLCV is declared once
    (previously three times). `toRate`/`prevPrice`/`amplitude`/
    `openPremiumRate` removed (never consumed).
  * `TrendLine` moved to `model/entity/trend_line.dart` and now stores a
    price value instead of raw screen coordinates.
* **Indicator layer**
  * `Indicator` base class no longer carries `indicatorStyle` — the
    indicator layer is now pure Dart with zero Flutter rendering imports.
    Styles live in `IndicatorStyles`, passed to `KChartWidget`.
  * `calcParams` is now honored by every indicator and exposed as a
    constructor parameter (RSI `[14]`, WR `[14]`, KDJ `[9,3,3]`, MACD,
    BOLL, SAR, CCI …), copied into an unmodifiable list.
  * `WRIndicator` renamed from `'volumeRatio'` to `'williamsR'`.
  * Generics `<T, K>` removed from `Indicator`/`MainIndicator`/
    `SecondaryIndicator` and painters.
  * `IndicatorPainterFactory.create` now takes `(indicator, styles)`.
* **Widget**
  * `KChartWidget` constructor is fully named (`data:` instead of
    positional `datas`); `isLongPass` typo, `TimeFormat`/`timeFormat`
    dead parameter and unused `materialInfoDialog` removed;
    `isTrendLine` → `trendLineEnabled`, `isTapShowInfoDialog` →
    `tapShowInfoDialog`, `isOnDrag` → `onDragChanged`.
  * `VerticalTextAlignment` moved from a renderer file to
    `style/k_chart_style.dart`.
  * `KChartStyle` dimensions are now constructor parameters (previously
    hardcoded); `dateTimeFormat` token list replaced by `datePattern`
    (intl pattern string).
  * `DepthChartTranslations` → `ChartTranslations`; depth chart up/down
    colors now match the red-up/green-down convention of the K-line chart
    (bid and ask colors are therefore swapped compared to 0.0.x).
  * Hungarian `m`-prefixes removed across renderers/painters/state.

### Fixed

* KDJ painter crashed when exactly one of two adjacent points was still
  warming up (`||` + force unwrap → `&&`).
* Every fling leaked an `AnimationController`; one controller is now
  reused for the widget's lifetime.
* Grid drawing loop drew ~25× too many vertical lines (loop bound used
  pixel space instead of column count) in all three renderers.
* Flat / all-zero data windows produced `scaleY = Infinity` (division by
  zero) in the base renderer, volume renderer and depth chart.
* Missing `onLongPressCancel` handler left the crosshair stuck when the
  gesture lost the arena.
* Tap before the first paint crashed on uninitialized rects.
* SAR acceleration factor reset asymmetry (down-reversal reset `af = 0`);
  `-100` magic sentinel replaced by a nullable extreme point.
* MACD warm-up rows kept stale values when recalculated over reused data.
* Hand-rolled date formatter (wrong `S`/`uuu` tokens, English-only names,
  DST-sensitive day-of-year) replaced by `intl.DateFormat`.
* WR used a 15-bar window after warm-up and `-10` as its warm-up value;
  now a true `period`-bar window with null warm-up.
* `initFormats` cadence heuristic assumed ascending timestamps.
* Trend lines were mis-scaled when zoomed (drawn inside the scaled
  canvas with screen x); they now anchor to data x + price value.
* State mutation during `build()` (scroll reset on empty data) moved to
  `didUpdateWidget`.

### Performance

* Renderers, indicator painters, `Paint`s and `TextPainter`s are created
  once per configuration and re-targeted each frame instead of being
  reallocated on every paint (previously every scroll/long-press frame
  rebuilt the whole renderer tree).
* `shouldRepaint` compares fields instead of returning `true`
  unconditionally (both charts).
* `RepaintBoundary` around both charts; the info dialog no longer forces
  a chart repaint (the paint-time `StreamSink` side channel is gone —
  selection is computed in the gesture handlers).
* Static mutable scroll bounds (`BaseChartPainter.maxScrollX`) replaced
  by a per-widget `ChartViewport`; two chart instances no longer share
  scroll state. Trend-line globals removed likewise.
* NumberFormat / DateFormat / axis label TextPainter caching.
* BOLL band fill reuses one `Path`; dashed lines reuse a `Path` instead
  of allocating two `Offset`s per segment.
