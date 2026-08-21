import 'config.dart';

class StagingConfig implements Config {
  @override
  String get baseUrl => 'https://staging.go.komtim.komerce.my.id';

  @override
  // TODO: implement baseUrlInternal
  String get baseUrlInternal =>
      'https://api.internal.komerce.my.id/staging/auth';

  @override
  String get baseUrlTalentPool =>
      'https://api.internal.komerce.my.id/staging/talent-pool';

  @override
  String get baseUrlWebUrlTalentPool => 'https://stg.komtim.id/talent-pool';

  @override
  String get baseUrlSuperApp => 'https://api.internal.komerce.my.id/staging';

  @override
  String get baseUrlKomship => 'https://staging.komship.komerce.my.id';
}
