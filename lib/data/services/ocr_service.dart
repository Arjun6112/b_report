// lib/data/services/ocr_service.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    as mlkit;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf_pdf;

class OcrService {
  final mlkit.TextRecognizer _textRecognizer =
      mlkit.TextRecognizer(script: mlkit.TextRecognitionScript.latin);

  /// Extracts text from multiple files (images and PDFs) and returns combined structured text
  Future<List<Map<String, dynamic>>> extractStructuredTextFromFiles(
      List<PlatformFile> files) async {
    final List<Map<String, dynamic>> allStructuredText = [];

    for (int fileIndex = 0; fileIndex < files.length; fileIndex++) {
      final file = files[fileIndex];
      final structuredText = await extractStructuredText(file);

      // Add file index to each text element to track which file it came from
      for (final textElement in structuredText) {
        textElement['fileIndex'] = fileIndex;
        textElement['fileName'] = file.name;
        allStructuredText.add(textElement);
      }
    }

    return allStructuredText;
  }

  /// Extracts all text elements with their bounding box coordinates from a single file.
  /// Supports both images (PNG, JPG) and PDF files.
  Future<List<Map<String, dynamic>>> extractStructuredText(
      PlatformFile file) async {
    if (file.path == null) {
      throw Exception('File path is null');
    }

    final String fileExtension = file.extension?.toLowerCase() ?? '';

    if (fileExtension == 'pdf') {
      return await _extractFromPdf(file);
    } else if (['png', 'jpg', 'jpeg'].contains(fileExtension)) {
      return await _extractFromImage(file);
    } else {
      throw Exception('Unsupported file format: $fileExtension');
    }
  }

  /// Extracts text from PDF files using Syncfusion PDF library
  Future<List<Map<String, dynamic>>> _extractFromPdf(PlatformFile file) async {
    try {
      // Read the PDF file
      final File pdfFile = File(file.path!);
      final List<int> bytes = await pdfFile.readAsBytes();

      // Load the PDF document
      final sf_pdf.PdfDocument document = sf_pdf.PdfDocument(inputBytes: bytes);
      final List<Map<String, dynamic>> structuredTextList = [];

      // Extract text from each page
      for (int pageIndex = 0; pageIndex < document.pages.count; pageIndex++) {
        // Extract text with layout information
        final sf_pdf.PdfTextExtractor extractor =
            sf_pdf.PdfTextExtractor(document);
        final List<sf_pdf.TextLine> textLines = extractor.extractTextLines(
            startPageIndex: pageIndex, endPageIndex: pageIndex);

        // Convert TextLines to our structured format
        for (final sf_pdf.TextLine textLine in textLines) {
          for (final sf_pdf.TextWord word in textLine.wordCollection) {
            structuredTextList.add({
              'text': word.text,
              'left': word.bounds.left.round(),
              'top': word.bounds.top.round(),
              'right': word.bounds.right.round(),
              'bottom': word.bounds.bottom.round(),
              'pageIndex': pageIndex,
              'source': 'pdf',
            });
          }
        }
      }

      // Dispose the document
      document.dispose();

      return structuredTextList;
    } catch (e) {
      throw Exception(
          'Error processing PDF: ${e.toString()}. Please ensure the PDF is not password-protected and contains selectable text.');
    }
  }

  /// Extracts text from image files
  Future<List<Map<String, dynamic>>> _extractFromImage(
      PlatformFile file) async {
    final inputImage = mlkit.InputImage.fromFilePath(file.path!);
    final mlkit.RecognizedText recognizedText =
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
            'source': 'image',
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
