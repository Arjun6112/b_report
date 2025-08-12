// lib/presentation/cubit/report_cubit.dart
import 'package:bloodsage/data/models/medical_report.dart';
import 'package:bloodsage/data/models/report_parameter.dart';
import 'package:bloodsage/data/repositories/report_repository.dart';
import 'package:bloodsage/data/services/analysis_service.dart';
import 'package:bloodsage/data/services/ocr_service.dart';
import 'package:bloodsage/presentation/cubit/report_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportCubit extends Cubit<ReportState> {
  final OcrService _ocrService;
  final AnalysisService _analysisService;
  final ReportRepository _reportRepository = ReportRepository();

  ReportCubit(this._ocrService, this._analysisService) : super(ReportInitial());

  Future<void> processNewReport() async {
    try {
      emit(ReportLoading());

      // 1. Pick files (now supports multiple selection)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'png',
          'jpg',
          'jpeg'
        ], // Supports both images and PDFs
        allowMultiple: true, // Enable multiple file selection
      );

      if (result != null) {
        final files = result.files;

        // --- Enhanced Workflow for Multiple Files ---

        // 2. Extract structured text with coordinates from all files
        final structuredText =
            await _ocrService.extractStructuredTextFromFiles(files);

        if (structuredText.isEmpty) {
          throw Exception("OCR could not find any text in the documents.");
        }

        // 3. Send the entire structured text to the LLM for parsing in one call
        final analyzedParameters =
            await _analysisService.parseReportWithLlm(structuredText);

        if (analyzedParameters.isEmpty) {
          throw Exception(
              "The report(s) could not be analyzed. Please try clearer images.");
        }

        // 4. Emit success with the list of parameters returned by the LLM
        emit(ReportSuccess(analyzedParameters));

        // 5. Save the report to history with info about multiple files
        final fileNames = files.map((f) => f.name).join(', ');
        await _saveReportToHistory(analyzedParameters, fileNames);
      } else {
        // User canceled the picker
        emit(ReportInitial());
      }
    } catch (e) {
      emit(ReportFailure("Failed to process report: ${e.toString()}"));
    }
  }

  /// Load parameters from an existing report
  void loadReportParameters(List<ReportParameter> parameters) {
    if (parameters.isNotEmpty) {
      emit(ReportSuccess(parameters));
    } else {
      emit(ReportInitial());
    }
  }

  /// Clear the current report
  void clearReport() {
    emit(ReportInitial());
  }

  /// Save the processed report to history
  Future<void> _saveReportToHistory(
      List<ReportParameter> parameters, String fileName) async {
    try {
      // Create a medical report object
      final report = MedicalReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        reportDate: DateTime.now(),
        labName: _extractLabNameFromFileName(fileName),
        parameters: parameters,
      );

      // Save to repository
      await _reportRepository.saveReport(report);
    } catch (e) {
      // Log error but don't fail the main process
      print('Error saving report to history: $e');
    }
  }

  /// Extract lab name from file name or use default
  String _extractLabNameFromFileName(String fileName) {
    // Remove file extension
    final nameWithoutExtension = fileName.split('.').first;

    // If filename contains common lab names, extract them
    final labNames = ['redcliff', 'pathkind', 'srl', 'metropolis', 'thyrocare'];
    for (final lab in labNames) {
      if (nameWithoutExtension.toLowerCase().contains(lab)) {
        return lab.substring(0, 1).toUpperCase() + lab.substring(1) + ' Labs';
      }
    }

    // Default lab name
    return nameWithoutExtension.isNotEmpty
        ? nameWithoutExtension
        : 'Medical Report';
  }
}
