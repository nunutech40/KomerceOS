import 'dart:io';

import 'package:dio/dio.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import '../services/kyc_upload_image_preparer.dart';

abstract class KycVerificationRemoteDataSource {
  Future<dynamic> latestHistory();
  Future<void> upload(
      {String? ktpPath, String? selfieKtpPath, String? livenessPath});
  Future<void> checkNik({required String nik, required String email});
  Future<void> submit(Map<String, String> partnerData);
}

class KycVerificationRemoteDataSourceImpl
    implements KycVerificationRemoteDataSource {
  const KycVerificationRemoteDataSourceImpl(this.client);

  final DioClient client;

  void _ensureSuccess(dynamic body) {
    if (body is! Map) return;
    final meta = body['meta'];
    if (meta is Map && meta['status']?.toString().toLowerCase() == 'failed') {
      throw KycApiException(
          meta['message']?.toString() ?? 'Permintaan KYC gagal');
    }
    if (body['status'] == false) {
      throw KycApiException(
          body['message']?.toString() ?? 'Permintaan KYC gagal');
    }
  }

  @override
  Future<dynamic> latestHistory() async {
    final response = await client.get(Endpoints.kycLatestHistory);
    _ensureSuccess(response.data);
    return response.data;
  }

  @override
  Future<void> upload(
      {String? ktpPath, String? selfieKtpPath, String? livenessPath}) async {
    if ([ktpPath, selfieKtpPath, livenessPath].every((path) => path == null)) {
      throw ArgumentError('At least one KYC image is required');
    }
    final prepared = <String, File>{};
    try {
      if (ktpPath != null) {
        prepared['imageKtp'] = await KycUploadImagePreparer.prepare(ktpPath);
      }
      if (selfieKtpPath != null) {
        prepared['imageKtpWithFace'] =
            await KycUploadImagePreparer.prepare(selfieKtpPath);
      }
      if (livenessPath != null) {
        prepared['imageLiveness'] =
            await KycUploadImagePreparer.prepare(livenessPath);
      }
      final data = FormData.fromMap({
        for (final entry in prepared.entries)
          entry.key: await MultipartFile.fromFile(entry.value.path,
              filename: '${entry.key}.jpg',
              contentType: DioMediaType('image', 'jpeg')),
      });
      final response = await client.post(Endpoints.kycUpload,
          data: data,
          options: Options(contentType: Headers.multipartFormDataContentType));
      _ensureSuccess(response.data);
    } finally {
      for (final file in prepared.values) {
        if (await file.exists()) await file.delete();
      }
    }
  }

  @override
  Future<void> checkNik({required String nik, required String email}) async {
    final response = await client.post(Endpoints.kycCheckNik,
        queryParameters: {'nik': nik, 'email': email});
    _ensureSuccess(response.data);
  }

  @override
  Future<void> submit(Map<String, String> partnerData) async {
    final response = await client.post(Endpoints.kycSubmit, data: partnerData);
    _ensureSuccess(response.data);
  }
}

class KycApiException implements Exception {
  const KycApiException(this.message);
  final String message;
  @override
  String toString() => message;
}
