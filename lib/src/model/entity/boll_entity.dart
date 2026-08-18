/// Bollinger band values for one bar.
class BollValue {
  final double up;
  final double mid;
  final double dn;

  const BollValue({required this.up, required this.mid, required this.dn});
}

/// Value slot for the BOLL indicator.
mixin BOLLEntity {
  BollValue? boll;
}
