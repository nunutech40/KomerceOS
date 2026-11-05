import 'package:flutter_test/flutter_test.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/services/ktp_crop_geometry.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/ktp_capture_area.dart';

void main() {
  const area = KtpCaptureArea(
    viewportWidth: 700,
    viewportHeight: 1000,
    left: 77,
    top: 328,
    width: 546,
    height: 344,
  );

  test('crop mengikuti shape pada hasil kamera portrait yang lebih tinggi', () {
    final crop = ktpCropRegion(
      imageWidth: 720,
      imageHeight: 1280,
      area: area,
    );

    // The card seen on the device occupied x=82..653 and y=475..837.
    expect(crop.x, lessThan(82));
    expect(crop.x + crop.width, greaterThan(653));
    expect(crop.y, lessThan(475));
    expect(crop.y + crop.height, greaterThan(837));
    expect(crop.y, greaterThan(300)); // Excludes the laptop keyboard.
  });

  test('crop tetap berada di foto pada rasio kamera berbeda', () {
    final crop = ktpCropRegion(
      imageWidth: 1200,
      imageHeight: 1600,
      area: area,
    );

    expect(crop.x, greaterThanOrEqualTo(0));
    expect(crop.y, greaterThanOrEqualTo(0));
    expect(crop.x + crop.width, lessThanOrEqualTo(1200));
    expect(crop.y + crop.height, lessThanOrEqualTo(1600));
    expect(crop.width / crop.height, closeTo(85.60 / 53.98, .4));
  });
}
