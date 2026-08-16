# clean_k_chart

Flutter/Dart package: a clean K-line (candlestick) chart library ported from `k_chart_plus` (read-only reference in workspace `readonly-dependencies/k_chart_plus`). Early stage.

## Commands

```bash
flutter pub get     # install deps
flutter analyze     # lint + static analysis (flutter_lints ^6.0.0)
flutter test        # run tests (no test/ dir yet)
dart format .       # format
```

## Structure

- `lib/k_chart_plus.dart` — real public API entry; exports chart widget, styles, entities, renderers, indicators
- `lib/clean_k_chart.dart` — placeholder stub (template Calculator), not yet the real entry
- `lib/entity/` — data models (`k_line_entity.dart` is the core candle model)
- `lib/renderer/` — custom painters/renderers (main, volume, secondary)
- `lib/indicator/` — indicators; `main/` = MA/EMA/BOLL/SAR, `secondary/` = MACD/KDJ/RSI/CCI/WR; all extend `indicator_template.dart`
- `lib/styles/`, `lib/utils/`, `lib/extension/` — chart styles, data processing, helpers

## Conventions

- Dart SDK ^3.13.0; docs/comments in the ported code are partly Chinese — keep existing language when editing
- Keep public exports funneled through `lib/k_chart_plus.dart`
