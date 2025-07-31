// lib/presentation/cubit/report_cubit.dart
import 'package:bloodsage/data/services/analysis_service.dart';
import 'package:bloodsage/data/services/ocr_service.dart';
import 'package:bloodsage/presentation/cubit/report_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportCubit extends Cubit<ReportState> {
  final OcrService _ocrService;
  final AnalysisService _analysisService;

  ReportCubit(this._ocrService, this._analysisService) : super(ReportInitial());

  Future<void> processNewReport() async {
    try {
      emit(ReportLoading());

      // 1. Pick a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg'],
      );

      if (result != null) {
        final file = result.files.first;

        // --- New Workflow ---

        // 2. Extract structured text with coordinates from the report
        final structuredText = await _ocrService.extractStructuredText(file);

        if (structuredText.isEmpty) {
          throw Exception("OCR could not find any text in the document.");
        }

        // 3. Send the entire structured text to the LLM for parsing in one call
        final analyzedParameters =
            await _analysisService.parseReportWithLlm(structuredText);

        if (analyzedParameters.isEmpty) {
          throw Exception(
              "The report could not be analyzed. Please try a clearer image.");
        }

        // 4. Emit success with the list of parameters returned by the LLM
        emit(ReportSuccess(analyzedParameters));
      } else {
        // User canceled the picker
        emit(ReportInitial());
      }
    } catch (e) {
      emit(ReportFailure("Failed to process report: ${e.toString()}"));
    }
  }
}
