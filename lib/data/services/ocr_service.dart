// lib/data/services/ocr_service.dart
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  /// Extracts all text elements with their bounding box coordinates.
  Future<List<Map<String, dynamic>>> extractStructuredText(
      PlatformFile file) async {
    if (file.path == null) {
      throw Exception('File path is null');
    }

    final inputImage = InputImage.fromFilePath(file.path!);
    final RecognizedText recognizedText =
        await _textRecognizer.processImage(inputImage);

    final List<Map<String, dynamic>> structuredTextList = [];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          structuredTextList.add({
            'text': element.text,
            'left': element.boundingBox.left.round(),
            'top': element.boundingBox.top.round(),
            'right': element.boundingBox.right.round(),
            'bottom': element.boundingBox.bottom.round(),
          });
        }
      }
    }
    return structuredTextList;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
