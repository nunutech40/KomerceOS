import '../entities/ktp_ocr_data.dart';

abstract interface class KtpOcrRepository {
  Future<KtpOcrData> readPhoto(String imagePath);
}
