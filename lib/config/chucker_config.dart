/// Chucker is available only in internal builds, including release APKs from CI.
/// An omitted or unknown FLAVOR is treated as production.
class ChuckerConfig {
  const ChuckerConfig._();

  static const String flavor = String.fromEnvironment('FLAVOR');
  static const bool enabled = flavor == 'dev' || flavor == 'staging';
}
