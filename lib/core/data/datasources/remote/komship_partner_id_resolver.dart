import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/datasources/preferences/shared_pref.dart';

/// Komship `partner_id` for partner-scoped Komship APIs (mutation, saldo
/// ideal). The Super App profile does not carry it, so it falls back to
/// Komship `my-profile`, the same source Komship Android stores at login.
class KomshipPartnerIdResolver {
  KomshipPartnerIdResolver({required this.client, required this.sharedPref});

  final DioClient client;
  final SharedPref sharedPref;

  int? _cached;
  String? _cachedFor;

  Future<int> resolve() async {
    final profile = await sharedPref.getProfileResponse();
    final stored = profile?.partnerId;
    if (stored != null && stored > 0) return stored;

    final token = await sharedPref.getAccessToken();
    if (_cached != null && _cachedFor == token) return _cached!;

    final response = await client.post(Endpoints.komshipProfile);
    final body = response.data;
    final data = body is Map ? body['data'] : null;
    final id = data is Map ? num.tryParse('${data['partner_id']}')?.toInt() : null;
    if (id == null || id <= 0) {
      throw StateError('Data partner Komship tidak tersedia.');
    }
    _cached = id;
    _cachedFor = token;
    return id;
  }
}
