/// Value slots for the EMA indicator — one entry per calc param.
///
/// The list is null until [EMAIndicator.calc] runs; entries are seeded
/// from the first close and therefore never null themselves.
mixin EMAEntity {
  List<double>? emaValues;
}
