import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/config/config.dart';
import 'package:komtim_partner/config/dev.dart';
import 'package:komtim_partner/config/production.dart';
import 'package:komtim_partner/config/staging.dart';
import 'package:komtim_partner/core/data/models/profile_image_url.dart';
import 'package:komtim_partner/core/data/models/superapp_profile_response.dart';
import 'package:komtim_partner/features/superapp/features/setting/data/models/setting_profile_response.dart';

void main() {
  const storage = 'https://storage.googleapis.com/komerce-dev-auth';

  test('relative profile images use the correct folder for each flavor', () {
    for (final (config, folder) in [
      (DevConfig(), 'photo_profile_partner/dev'),
      (StagingConfig(), 'photo_profile_partner/staging'),
      (ProductionConfig(), 'photo_profile_partner'),
    ]) {
      expect(config.baseUrlBusinessLogoStorage, storage);
      expect(resolveProfileImageUrl('photo.jpg', config: config),
          '$storage/$folder/photo.jpg');
      expect(
        resolveProfileImageUrl('/photo_profile_partner/dev/photo.jpg',
            config: config),
        '$storage/$folder/photo.jpg',
      );
      expect(
        resolveProfileImageUrl('photo_profile_partner/staging/logo.png',
            config: config),
        '$storage/$folder/logo.png',
      );
      expect(
        resolveProfileImageUrl('//photo_profile_partner/staging/photo.jpg',
            config: config),
        '$storage//$folder/photo.jpg',
      );
    }
  });

  test('absolute URLs are kept and empty image values stay absent', () {
    const url = '$storage/photo_profile_partner/dev/photo.png';
    expect(resolveProfileImageUrl(url, config: StagingConfig()), url);
    const doubleSlashUrl = '$storage//photo_profile_partner/staging/photo.png';
    expect(resolveProfileImageUrl(doubleSlashUrl, config: StagingConfig()),
        doubleSlashUrl);
    expect(resolveProfileImageUrl(null), isNull);
    expect(resolveProfileImageUrl('null'), isNull);
    expect(resolveProfileImageUrl('-'), isNull);
  });

  test('staging key from backend keeps the leading slash in its GCS object key',
      () {
    const key =
        '//photo_profile_partner/staging/1791952166_acdb9d61_komerce_profile_1791952155932201.jpg';
    expect(
      resolveProfileImageUrl(key, config: StagingConfig()),
      '$storage$key',
    );
  });

  test('global API and cached profiles resolve personal and business images',
      () {
    final profile = SuperappProfileResponse.fromJson(const {
      'photo_profile_url': 'avatar.png',
      'business_profile': {'business_logo': 'logo.png'},
    });
    final prefix = '$storage/${Config.instance.profileImageStoragePath}';
    expect(profile.photoProfileUrl, '$prefix/avatar.png');
    expect(profile.businessProfile?.businessLogo, '$prefix/logo.png');
    final cached = SuperappProfileResponse.fromJsonCache(const {
      'photo_profile_url': '/photo_profile_partner/dev/avatar.png',
      'business_profile': {
        'business_logo': '/photo_profile_partner/dev/logo.png',
      },
    });
    expect(cached.photoProfileUrl, '$prefix/avatar.png');
    expect(cached.businessProfile?.businessLogo, '$prefix/logo.png');
    final backend = SuperappProfileResponse.fromJson(const {
      'photo_profile_url': '//photo_profile_partner/staging/avatar.png',
      'business_profile': {
        'business_logo': '//photo_profile_partner/staging/logo.png',
      },
    });
    final doubleSlashPrefix =
        '$storage//${Config.instance.profileImageStoragePath}';
    expect(backend.photoProfileUrl, '$doubleSlashPrefix/avatar.png');
    expect(
        backend.businessProfile?.businessLogo, '$doubleSlashPrefix/logo.png');
  });

  test('setting profile business logo uses the same URL resolver', () {
    final profile = SettingProfileResponse.fromJson(const {
      'partner_business_logo': 'logo.png',
    });
    expect(profile.toEntity().logoUrl,
        '$storage/${Config.instance.profileImageStoragePath}/logo.png');
  });
}
