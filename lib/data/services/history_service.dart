import 'package:hive_flutter/hive_flutter.dart';
import '../models/medical_report.dart';

class HistoryService {
  static const String _boxName = 'medical_reports';
  
  /// Get all saved medical reports
  static Future<List<MedicalReport>> getAllReports() async {
    try {
      final box = await Hive.openBox<MedicalReport>(_boxName);
      final reports = box.values.toList();
      
      // Sort by date (newest first)
      reports.sort((a, b) => b.reportDate.compareTo(a.reportDate));
      
      return reports;
    } catch (e) {
      throw Exception('Failed to load reports: $e');
    }
  }
  
  /// Save a new medical report
  static Future<void> saveReport(MedicalReport report) async {
    try {
      final box = await Hive.openBox<MedicalReport>(_boxName);
      await box.put(report.id, report);
    } catch (e) {
      throw Exception('Failed to save report: $e');
    }
  }
  
  /// Delete a medical report by ID
  static Future<void> deleteReport(String reportId) async {
    try {
      final box = await Hive.openBox<MedicalReport>(_boxName);
      await box.delete(reportId);
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }
  
  /// Get a specific report by ID
  static Future<MedicalReport?> getReportById(String reportId) async {
    try {
      final box = await Hive.openBox<MedicalReport>(_boxName);
      return box.get(reportId);
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }
  
  /// Clear all reports (use with caution)
  static Future<void> clearAllReports() async {
    try {
      final box = await Hive.openBox<MedicalReport>(_boxName);
      await box.clear();
    } catch (e) {
      throw Exception('Failed to clear reports: $e');
    }
  }
  
  /// Get the count of saved reports
  static Future<int> getReportsCount() async {
    try {
      final box = await Hive.openBox<MedicalReport>(_boxName);
      return box.length;
    } catch (e) {
      return 0;
    }
  }
  
  /// Check if a report exists
  static Future<bool> reportExists(String reportId) async {
    try {
      final box = await Hive.openBox<MedicalReport>(_boxName);
      return box.containsKey(reportId);
    } catch (e) {
      return false;
    }
  }
}
