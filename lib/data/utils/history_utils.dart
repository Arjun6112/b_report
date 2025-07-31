import '../models/medical_report.dart';
import '../models/report_parameter.dart';
import '../services/history_service.dart';

class HistoryUtils {
  /// Create and save a sample medical report for testing
  static Future<void> createSampleReport() async {
    final sampleReport = MedicalReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reportDate: DateTime.now(),
      labName: 'Sample Lab',
      parameters: [
        const ReportParameter(
          name: 'Hemoglobin',
          value: '14.5',
          units: 'g/dL',
          normalRange: '12.0-15.5',
          status: ParameterStatus.normal,
          aiSummary: 'Your hemoglobin level is within the normal range.',
        ),
        const ReportParameter(
          name: 'Blood Glucose',
          value: '110',
          units: 'mg/dL',
          normalRange: '70-100',
          status: ParameterStatus.high,
          aiSummary: 'Your blood glucose is slightly elevated. Consider monitoring your diet.',
        ),
      ],
    );
    
    await HistoryService.saveReport(sampleReport);
  }
  
  /// Get a formatted string for report details
  static String formatReportSummary(MedicalReport report) {
    final normalCount = report.parameters.where((p) => p.status == ParameterStatus.normal).length;
    final abnormalCount = report.parameters.length - normalCount;
    
    return 'Lab: ${report.labName}\n'
           'Date: ${_formatDate(report.reportDate)}\n'
           'Parameters: ${report.parameters.length} total\n'
           'Normal: $normalCount, Abnormal: $abnormalCount';
  }
  
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  /// Export reports as formatted text
  static Future<String> exportReportsAsText() async {
    final reports = await HistoryService.getAllReports();
    
    if (reports.isEmpty) {
      return 'No reports found.';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('Medical Reports Export');
    buffer.writeln('Generated on: ${DateTime.now()}');
    buffer.writeln('Total Reports: ${reports.length}');
    buffer.writeln('${'=' * 50}');
    
    for (int i = 0; i < reports.length; i++) {
      final report = reports[i];
      buffer.writeln('\nReport ${i + 1}:');
      buffer.writeln('ID: ${report.id}');
      buffer.writeln('Lab: ${report.labName}');
      buffer.writeln('Date: ${_formatDate(report.reportDate)}');
      buffer.writeln('Parameters (${report.parameters.length}):');
      
      for (final param in report.parameters) {
        buffer.writeln('  • ${param.name}: ${param.value} ${param.units} (${param.status.name})');
        buffer.writeln('    Range: ${param.normalRange}');
        buffer.writeln('    Summary: ${param.aiSummary}');
      }
      buffer.writeln('-' * 30);
    }
    
    return buffer.toString();
  }
}
