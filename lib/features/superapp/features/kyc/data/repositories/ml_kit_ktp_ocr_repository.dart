import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/services/ktp_ocr_parser.dart';
import 'package:komtim_partner/features/superapp/features/kyc/data/services/ktp_ocr_line.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/entities/ktp_ocr_data.dart';
import 'package:komtim_partner/features/superapp/features/kyc/domain/repositories/ktp_ocr_repository.dart';

class MlKitKtpOcrRepository implements KtpOcrRepository {
  const MlKitKtpOcrRepository();

  @override
  Future<KtpOcrData> readPhoto(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final image = InputImage.fromFilePath(imagePath);
      final recognized = await recognizer.processImage(image);
      final lines = recognized.blocks
          .expand((block) => block.lines)
          .map((line) => KtpOcrLine(
                text: line.text,
                left: line.boundingBox.left,
                top: line.boundingBox.top,
                width: line.boundingBox.width,
                height: line.boundingBox.height,
              ))
          .toList();
      return lines.isEmpty
          ? KtpOcrParser.parseLines(recognized.text.split('\n'))
          : KtpOcrParser.parsePositionedLines(lines);
    } finally {
      await recognizer.close();
    }
  }
}
