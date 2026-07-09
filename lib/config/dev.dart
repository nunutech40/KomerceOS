import 'config.dart';

class DevConfig implements Config {
  @override
  String get baseUrl => 'https://dev.go.komtim.komerce.my.id';

  @override
  // TODO: implement baseUrlInternal
  String get baseUrlInternal => 'https://api.internal.komerce.my.id/dev/auth';

  @override
  String get baseUrlTalentPool =>
      'https://api.internal.komerce.my.id/dev/talent-pool';

  @override
  String get baseUrlWebUrlTalentPool => 'https://dev.komtim.id/talent-pool';

  @override
  String get baseUrlSuperApp => 'https://api.internal.komerce.my.id/dev';
}
