/// Clean K-line chart library.
///
/// Curated public API — internal renderers, painters and utils are not
/// exported. Layering: widget → render → indicator → model, with style /
/// i18n as leaf layers.
library;

// Widgets — user entry points
export 'src/widget/k_chart_widget.dart';
export 'src/widget/depth_chart.dart';

// Model — data entities
export 'src/model/entity/boll_entity.dart';
export 'src/model/entity/candle_entity.dart';
export 'src/model/entity/cci_entity.dart';
export 'src/model/entity/depth_entity.dart';
export 'src/model/entity/ema_entity.dart';
export 'src/model/entity/k_line_entity.dart';
export 'src/model/entity/kdj_entity.dart';
export 'src/model/entity/ma_entity.dart';
export 'src/model/entity/macd_entity.dart';
export 'src/model/entity/rsi_entity.dart';
export 'src/model/entity/sar_entity.dart';
export 'src/model/entity/trend_line.dart';
export 'src/model/entity/volume_entity.dart';
export 'src/model/entity/wr_entity.dart';

// Indicators — pure calculation
export 'src/indicator/indicator.dart';
export 'src/indicator/indicator_calculator.dart';
export 'src/indicator/main/boll_indicator.dart';
export 'src/indicator/main/ema_indicator.dart';
export 'src/indicator/main/ma_indicator.dart';
export 'src/indicator/main/sar_indicator.dart';
export 'src/indicator/secondary/cci_indicator.dart';
export 'src/indicator/secondary/kdj_indicator.dart';
export 'src/indicator/secondary/macd_indicator.dart';
export 'src/indicator/secondary/rsi_indicator.dart';
export 'src/indicator/secondary/wr_indicator.dart';

// Style — colors & dimensions
export 'src/style/k_chart_style.dart';
export 'src/style/indicator_style.dart';
export 'src/style/depth_chart_style.dart';

// i18n
export 'src/i18n/chart_translations.dart';
