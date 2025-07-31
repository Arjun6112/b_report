import 'package:hive_flutter/hive_flutter.dart';
import '../models/medical_report.dart';
import '../models/report_parameter.dart';
import '../services/history_service.dart';

/// Repository class that handles all medical report data operations
/// This provides a clean abstraction layer over the Hive storage
class ReportRepository {
  static const String _boxName = 'medical_reports';

  /// Get all saved medical reports
  /// Returns a list sorted by date (newest first)
  Future<List<MedicalReport>> getAllReports() async {
    try {
      return await HistoryService.getAllReports();
    } catch (e) {
      throw ReportException('Failed to fetch reports: $e');
    }
  }

  /// Save a new medical report
  /// Throws ReportException if save operation fails
  Future<void> saveReport(MedicalReport report) async {
    try {
      await HistoryService.saveReport(report);
    } catch (e) {
      throw ReportException('Failed to save report: $e');
    }
  }

  /// Delete a medical report by ID
  /// Throws ReportException if delete operation fails
  Future<void> deleteReport(String reportId) async {
    try {
      await HistoryService.deleteReport(reportId);
    } catch (e) {
      throw ReportException('Failed to delete report: $e');
    }
  }

  /// Get a specific report by ID
  /// Returns null if report is not found
  Future<MedicalReport?> getReportById(String reportId) async {
    try {
      return await HistoryService.getReportById(reportId);
    } catch (e) {
      throw ReportException('Failed to get report: $e');
    }
  }

  /// Update an existing medical report
  /// If the report doesn't exist, it will be created
  Future<void> updateReport(MedicalReport report) async {
    try {
      await HistoryService.saveReport(report);
    } catch (e) {
      throw ReportException('Failed to update report: $e');
    }
  }

  /// Clear all reports (use with caution)
  /// This operation cannot be undone
  Future<void> clearAllReports() async {
    try {
      await HistoryService.clearAllReports();
    } catch (e) {
      throw ReportException('Failed to clear all reports: $e');
    }
  }

  /// Get the count of saved reports
  Future<int> getReportsCount() async {
    try {
      return await HistoryService.getReportsCount();
    } catch (e) {
      return 0;
    }
  }

  /// Check if a report exists
  Future<bool> reportExists(String reportId) async {
    try {
      return await HistoryService.reportExists(reportId);
    } catch (e) {
      return false;
    }
  }

  /// Get reports within a date range
  Future<List<MedicalReport>> getReportsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allReports = await getAllReports();
      return allReports.where((report) {
        return report.reportDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            report.reportDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw ReportException('Failed to get reports by date range: $e');
    }
  }

  /// Get reports by lab name
  Future<List<MedicalReport>> getReportsByLabName(String labName) async {
    try {
      final allReports = await getAllReports();
      return allReports.where((report) {
        return report.labName.toLowerCase().contains(labName.toLowerCase());
      }).toList();
    } catch (e) {
      throw ReportException('Failed to get reports by lab name: $e');
    }
  }

  /// Search reports by any text (lab name, parameter names, etc.)
  Future<List<MedicalReport>> searchReports(String searchTerm) async {
    try {
      final allReports = await getAllReports();
      final searchTermLower = searchTerm.toLowerCase();

      return allReports.where((report) {
        // Search in lab name
        if (report.labName.toLowerCase().contains(searchTermLower)) {
          return true;
        }

        // Search in parameter names and values
        for (final parameter in report.parameters) {
          if (parameter.name.toLowerCase().contains(searchTermLower) ||
              parameter.value.toLowerCase().contains(searchTermLower) ||
              parameter.units.toLowerCase().contains(searchTermLower)) {
            return true;
          }
        }

        return false;
      }).toList();
    } catch (e) {
      throw ReportException('Failed to search reports: $e');
    }
  }

  /// Get the latest report
  Future<MedicalReport?> getLatestReport() async {
    try {
      final reports = await getAllReports();
      return reports.isNotEmpty ? reports.first : null;
    } catch (e) {
      throw ReportException('Failed to get latest report: $e');
    }
  }

  /// Backup all reports to a list (useful for export)
  Future<List<Map<String, dynamic>>> exportReports() async {
    try {
      final reports = await getAllReports();
      return reports.map((report) {
        return {
          'id': report.id,
          'reportDate': report.reportDate.toIso8601String(),
          'labName': report.labName,
          'parameters': report.parameters.map((param) {
            return {
              'name': param.name,
              'value': param.value,
              'units': param.units,
              'normalRange': param.normalRange,
              'status': param.status.name,
              'aiSummary': param.aiSummary,
            };
          }).toList(),
        };
      }).toList();
    } catch (e) {
      throw ReportException('Failed to export reports: $e');
    }
  }

  /// Import reports from backup (useful for restore)
  Future<void> importReports(List<Map<String, dynamic>> reportsData) async {
    try {
      for (final reportData in reportsData) {
        final report = MedicalReport(
          id: reportData['id'],
          reportDate: DateTime.parse(reportData['reportDate']),
          labName: reportData['labName'],
          parameters: (reportData['parameters'] as List).map((paramData) {
            return ReportParameter(
              name: paramData['name'],
              value: paramData['value'],
              units: paramData['units'] ?? 'N/A',
              normalRange: paramData['normalRange'],
              aiSummary: paramData['aiSummary'] ?? 'No analysis available',
              status: ParameterStatus.values.firstWhere(
                (status) => status.name == paramData['status'],
                orElse: () => ParameterStatus.normal,
              ),
            );
          }).toList(),
        );

        await saveReport(report);
      }
    } catch (e) {
      throw ReportException('Failed to import reports: $e');
    }
  }

  /// Initialize the repository (call this on app startup)
  Future<void> initialize() async {
    try {
      await Hive.openBox<MedicalReport>(_boxName);
    } catch (e) {
      throw ReportException('Failed to initialize repository: $e');
    }
  }

  /// Close the repository (call this on app shutdown)
  Future<void> close() async {
    try {
      final box = Hive.box<MedicalReport>(_boxName);
      await box.close();
    } catch (e) {
      // Ignore errors when closing
    }
  }
}

/// Custom exception class for report operations
class ReportException implements Exception {
  final String message;

  const ReportException(this.message);

  @override
  String toString() => 'ReportException: $message';
}
