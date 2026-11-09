import 'dart:io';

import 'package:dio/dio.dart';
import 'package:komtim_partner/core/data/apiservice/constat_endpoint.dart';
import 'package:komtim_partner/core/data/apiservice/dio_client.dart';
import '../services/kyc_upload_image_preparer.dart';

abstract class KycVerificationRemoteDataSource {
  Future<dynamic> latestHistory();
  Future<void> upload(
      {required String ktpPath,
      required String selfieKtpPath,
      required String livenessPath});
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
      {required String ktpPath,
      required String selfieKtpPath,
      required String livenessPath}) async {
    if ([ktpPath, selfieKtpPath, livenessPath].any((path) => path.isEmpty)) {
      throw ArgumentError('All three KYC images are required');
    }
    final prepared = <String, File>{
      'image_ktp': File(ktpPath),
      'image_ktp_with_face': File(selfieKtpPath),
      'image_liveness': File(livenessPath),
    };
    final data = FormData();
    // Each local image was compressed when its capture step completed.
    for (final name in const [
      'image_ktp',
      'image_ktp_with_face',
      'image_liveness',
    ]) {
      final file = prepared[name];
      if (file == null) throw ArgumentError('Missing KYC image: $name');
      final bytes = await file.readAsBytes();
      if (bytes.length < 4 || bytes[0] != 0xff || bytes[1] != 0xd8) {
        throw const FileSystemException('Foto KYC bukan JPEG yang valid');
      }
      if (bytes.length > KycUploadImagePreparer.maxBytes) {
        throw const FileSystemException('Foto KYC melebihi 1 MB');
      }
      data.files.add(MapEntry(
        name,
        MultipartFile.fromBytes(bytes,
            filename: '$name.jpg', contentType: DioMediaType('image', 'jpeg')),
      ));
    }
    final response = await client.post(Endpoints.kycUpload,
        data: data,
        options: Options(contentType: Headers.multipartFormDataContentType));
    _ensureSuccess(response.data);
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
