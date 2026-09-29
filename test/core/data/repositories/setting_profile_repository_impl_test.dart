import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/common/failure.dart';
import 'package:komtim_partner/config/config.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import 'package:komtim_partner/core/data/models/superapp_profile_response.dart';
import 'package:komtim_partner/core/data/repositories/superapp_profile_repository_impl.dart';
import 'package:komtim_partner/core/domain/entities/superapp_profile_model.dart';
import 'package:komtim_partner/features/superapp/features/setting/data/datasources/setting_profile_remote_datasource.dart';
import 'package:komtim_partner/features/superapp/features/setting/data/repositories/setting_profile_repository_impl.dart';
import 'package:komtim_partner/features/superapp/features/setting/domain/entities/setting_profile.dart';

class CapturingAdapter implements HttpClientAdapter {
  RequestOptions? request;
  List<int> bytes = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    request = options;
    bytes = await requestStream!
        .fold<List<int>>([], (all, chunk) => all..addAll(chunk));
    return ResponseBody.fromString('{"code":200,"status":"success"}', 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
  }

  @override
  void close({bool force = false}) {}
}

class TestDioClient implements DioClient {
  @override
  final Dio dio =
      Dio(BaseOptions(headers: {'Content-Type': 'application/json'}));

  @override
  Future<Response> put(String path,
          {dynamic data,
          Map<String, dynamic>? queryParameters,
          Options? options,
          CancelToken? cancelToken,
          ProgressCallback? onSendProgress,
          ProgressCallback? onReceiveProgress}) =>
      dio.put(path,
          data: data,
          options: options,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestGlobalProfileRepository implements SuperappProfileRepository {
  final SuperappProfileModel profile;
  TestGlobalProfileRepository(this.profile);
  @override
  Future<Either<Failure, SuperappProfileModel>> getProfile() async =>
      Right(profile);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late CapturingAdapter adapter;
  late TestDioClient client;
  late SettingProfileRepositoryImpl repository;

  setUp(() {
    adapter = CapturingAdapter();
    client = TestDioClient();
    client.dio.httpClientAdapter = adapter;
    repository = SettingProfileRepositoryImpl(
      remote: SettingProfileRemoteDataSourceImpl(client: client),
      superappProfileRepository:
          TestGlobalProfileRepository(SuperappProfileResponse.fromJson(const {
        'full_name': 'Partner',
        'username': 'partner',
        'business_profile': {
          'brand_name': 'Toko',
          'business_phone': '081234567890',
          'location': 'Banyumas',
          'business_sector': 'Fashion',
          'business_logo': 'https://example.com/logo.jpg',
        },
      }).toEntity()),
    );
    addTearDown(() => client.dio.close(force: true));
  });

  test('GET global profile supplies all business form fields', () async {
    final result = await repository.getProfile();
    expect(result.businessName, 'Toko');
    expect(result.businessPhone, '081234567890');
    expect(result.location?.label, 'Banyumas');
    expect(result.businessSector?.label, 'Fashion');
    expect(result.logoUrl, 'https://example.com/logo.jpg');
  });

  test('global parser supports the field names returned by the dev GET API',
      () {
    final globalProfile = SuperappProfileResponse.fromJson(const {
      'business_profile': {
        'business_logo': '',
        'brand_name': 'Test Ya Hijab',
        'business_location': 'Simeulue Timur, Kabupaten Simeulue, Aceh',
        'pic_phone': '08755766499494',
        'partner_category_name': 'Bisnis Offline',
      },
    }).toEntity();
    final form = SettingProfile.fromGlobalProfile(globalProfile);
    expect(form.businessName, 'Test Ya Hijab');
    expect(form.businessPhone, '08755766499494');
    expect(form.location?.label, 'Simeulue Timur, Kabupaten Simeulue, Aceh');
    expect(form.businessSector?.label, 'Bisnis Offline');
    expect(form.logoUrl, isNull);
  });

  test('global parser preserves absent business data without inventing values',
      () {
    final profile = BusinessProfileResponse.fromJson(const {
      'business_logo': '',
      'brand_name': 'Test Ya Hijab',
      'business_location': null,
      'pic_phone': '',
      'partner_category_name': null,
    });
    expect(profile.businessLogo, isNull);
    expect(profile.businessPhone, isNull);
    expect(profile.location, isNull);
    expect(profile.businessSector, isNull);
  });

  test('relative logo storage paths become full URLs for the active flavor',
      () {
    final profile = BusinessProfileResponse.fromJson(const {
      'business_logo': '/photo_profile_partner/dev/saved-logo.jpg',
    });
    expect(profile.businessLogo,
        '${Config.instance.baseUrlKomshipHiring}/storage/photo_profile_partner/dev/saved-logo.jpg');
    expect(BusinessProfileResponse.fromJson(profile.toJson()), profile);
  });

  test('business request contains multipart file headers and actual JPEG bytes',
      () async {
    const imagePath = 'assets/images/komtim_icon.jpeg';
    final jpegBytes = await File(imagePath).readAsBytes();
    await repository.updateBusiness(const SettingProfile(
      businessName: 'Toko',
      businessPhone: '081234567890',
      location: ProfileOption(id: '1', label: 'Banyumas'),
      businessSector: ProfileOption(id: '2', label: 'Fashion'),
      logoPath: imagePath,
    ));
    final request = adapter.request!;
    final body = latin1.decode(adapter.bytes);
    expect(request.method, 'PUT');
    expect(request.path, Endpoints.superappUpdateBusinessProfile);
    expect(request.contentType, startsWith('multipart/form-data; boundary='));
    expect(body, contains('name="logo"; filename="komtim_icon.jpeg"'));
    expect(body.toLowerCase(), contains('content-type: image/jpeg'));
    expect(body, contains(latin1.decode(jpegBytes)));
    expect(body, contains('name="pic_phone"\r\n\r\n081234567890'));
    expect(body, contains('name="business_location"\r\n\r\nBanyumas'));
    expect(body, contains('name="partner_category_name"\r\n\r\nFashion'));
    expect(body, isNot(contains('name="business_logo"')));
  });

  test('business update without new logo omits the file part', () async {
    await repository.updateBusiness(const SettingProfile(businessName: 'Toko'));
    expect(latin1.decode(adapter.bytes), isNot(contains('name="logo"')));
  });

  test('missing selected file fails instead of silently saving without a logo',
      () async {
    await expectLater(
        repository.updateBusiness(const SettingProfile(
          logoPath: '/nonexistent/komerce/missing-logo.jpg',
        )),
        throwsA(isA<FileSystemException>()));
    expect(adapter.request, isNull);
  });
}
