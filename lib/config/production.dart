import 'config.dart';

class ProductionConfig implements Config {
  @override
  String get baseUrl => 'https://api.komtim.komerce.id';

  @override
  // TODO: implement baseUrlInternal
  String get baseUrlInternal => 'https://api.partner.komerce.id/auth';

  @override
  String get baseUrlTalentPool => 'https://api.partner.komerce.id/talent-pool';

  @override
  String get baseUrlWebUrlTalentPool => 'https://komtim.id/talent-pool';

  @override
  String get baseUrlSuperApp => 'https://api.partner.komerce.id';

  @override
  String get baseUrlKomship => 'https://api-komship.komerce.id';
}
