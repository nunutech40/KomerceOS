import '../../../config/config.dart';

/// Resolves relative profile image keys from auth to the active environment's
/// public storage path. Absolute URLs supplied by the backend are authoritative.
String? resolveProfileImageUrl(String? value, {Config? config}) {
  final image = value?.trim();
  if (image == null ||
      image.isEmpty ||
      image.toLowerCase() == 'null' ||
      image == '-') {
    return null;
  }

  final uri = Uri.tryParse(image);
  if (uri != null && uri.hasScheme) return image;

  final activeConfig = config ?? Config.instance;
  // Some GCS object keys themselves start with '/'. Keep that extra slash
  // after the bucket for relative paths beginning with '//'.
  final hasLeadingObjectSlash = image.startsWith('//');
  final bucket =
      activeConfig.baseUrlBusinessLogoStorage.replaceFirst(RegExp(r'/+$'), '');
  String resolve(String root, String key) {
    final url = Uri.parse('$root/').resolve(key).toString();
    return hasLeadingObjectSlash
        ? url.replaceFirst('$bucket/', '$bucket//')
        : url;
  }

  var path = image.replaceFirst(RegExp(r'^/+'), '');
  const folder = 'photo_profile_partner/';
  if (path.startsWith(folder)) {
    path = path.substring(folder.length);
    if (path.startsWith('dev/')) path = path.substring(4);
    if (path.startsWith('staging/')) path = path.substring(8);
  } else if (path.startsWith('dev/')) {
    path = path.substring(4);
  } else if (path.startsWith('staging/')) {
    path = path.substring(8);
  } else if (path.contains('/')) {
    // Keep other relative storage keys compatible with the old bucket resolver.
    return resolve(bucket, path);
  }

  return resolve('$bucket/${activeConfig.profileImageStoragePath}', path);
}
