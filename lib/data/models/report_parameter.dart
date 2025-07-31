// lib/data/models/report_parameter.dart
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'report_parameter.g.dart';

// No changes needed to the enum itself for now, the parsing is handled in the fromJson
@HiveType(typeId: 2)
enum ParameterStatus {
  @HiveField(0)
  low,
  @HiveField(1)
  normal,
  @HiveField(2)
  high,
  @HiveField(3)
  unknown
}

@HiveType(typeId: 1)
class ReportParameter extends Equatable {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String value;
  @HiveField(2)
  final String normalRange;
  @HiveField(3)
  final ParameterStatus status;
  @HiveField(4)
  final String aiSummary;
  @HiveField(5) // Add new field for units
  final String units;

  const ReportParameter({
    required this.name,
    required this.value,
    required this.normalRange,
    required this.status,
    required this.aiSummary,
    required this.units,
  });

  @override
  List<Object> get props =>
      [name, value, normalRange, status, aiSummary, units];

  /// ✨ Factory constructor to create a ReportParameter from JSON
  factory ReportParameter.fromJson(Map<String, dynamic> json) {
    // Helper function to parse status from LLM text
    ParameterStatus parseStatus(String? status) {
      switch (status?.toLowerCase()) {
        case 'low':
          return ParameterStatus.low;
        case 'high':
        case 'positive': // Treat 'positive' as high for coloring/icons
          return ParameterStatus.high;
        case 'normal':
        case 'negative': // Treat 'negative' as normal
          return ParameterStatus.normal;
        default:
          return ParameterStatus.unknown;
      }
    }

    return ReportParameter(
      name: json['name'] ?? 'Unknown',
      value: json['value'] ?? 'N/A',
      units: json['units'] ?? 'N/A',
      normalRange: json['range'] ?? 'N/A',
      // Now using the AI-provided summary and status
      aiSummary: json['summary'] ?? 'No analysis available.',
      status: parseStatus(json['status']),
    );
  }
}
