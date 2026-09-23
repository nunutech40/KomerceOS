import '../../../../../../core/data/apiservice/constat_endpoint.dart';
import '../../../../../../core/data/apiservice/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/setting_profile_response.dart';

abstract class SettingProfileRemoteDataSource {
  Future<SettingProfileResponse> getProfile();
  Future<List<BusinessSectorResponse>> getBusinessSectors();
  Future<List<BusinessLocationResponse>> searchLocations(String keyword);
  Future<void> updateAccount(Map<String, dynamic> data);
  Future<void> updateBusiness(Map<String, dynamic> data);
}

class SettingProfileRemoteDataSourceImpl
    implements SettingProfileRemoteDataSource {
  final DioClient client;
  SettingProfileRemoteDataSourceImpl({required this.client});

  dynamic _data(dynamic body) =>
      body is Map<String, dynamic> ? body['data'] : body;

  @override
  Future<SettingProfileResponse> getProfile() async {
    final response = await client.post(Endpoints.komshipProfile);
    final data = _data(response.data);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid profile response');
    }
    return SettingProfileResponse.fromJson(data);
  }

  @override
  Future<List<BusinessSectorResponse>> getBusinessSectors() async {
    final response = await client.post(Endpoints.komshipBusinessSectors);
    final data = _data(response.data);
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(BusinessSectorResponse.fromJson)
        .where((item) => item.id.isNotEmpty && item.name.isNotEmpty)
        .toList();
  }

  @override
  Future<List<BusinessLocationResponse>> searchLocations(String keyword) async {
    final response = await client.get(
      Endpoints.komshipLocations,
      queryParameters: {'search': keyword},
    );
    final data = _data(response.data);
    if (data is! List) return const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(BusinessLocationResponse.fromJson)
        .where((item) => item.cityCode.isNotEmpty && item.name.isNotEmpty)
        .toList();
  }

  @override
  Future<void> updateAccount(Map<String, dynamic> data) async {
    await client.put(Endpoints.superappUpdateUserProfile,
        data: FormData.fromMap(data));
  }

  @override
  Future<void> updateBusiness(Map<String, dynamic> data) async {
    await client.put(Endpoints.superappUpdateBusinessProfile,
        data: FormData.fromMap(data));
  }
}
