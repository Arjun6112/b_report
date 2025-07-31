import 'package:bloodsage/data/models/report_parameter.dart';
import 'package:flutter/material.dart';

class ParameterCard extends StatelessWidget {
  final ReportParameter parameter;

  const ParameterCard({super.key, required this.parameter});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: () => _showParameterDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(parameter.name, style: textTheme.titleMedium),
                  _StatusBadge(status: parameter.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                parameter.value,
                style: textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                'Normal: ${parameter.normalRange}',
                style: textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: Colors.grey[200],
              ),
              const SizedBox(height: 12),
              Text(
                parameter.aiSummary.isNotEmpty
                    ? parameter.aiSummary
                    : 'Analysis not available for this parameter.',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showParameterDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ParameterDetailDialog(parameter: parameter),
    );
  }
}

// A simple badge for showing the status (Low, High, Normal)
class _StatusBadge extends StatelessWidget {
  final ParameterStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String text;
    switch (status) {
      case ParameterStatus.low:
        color = Colors.blue.shade100;
        text = 'Low';
        break;
      case ParameterStatus.high:
        color = Colors.red.shade100;
        text = 'High';
        break;
      case ParameterStatus.normal:
        color = Colors.green.shade100;
        text = 'Normal';
        break;
      default:
        color = Colors.grey.shade200;
        text = 'Info';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// Dialog for showing detailed parameter information
class ParameterDetailDialog extends StatelessWidget {
  final ReportParameter parameter;

  const ParameterDetailDialog({super.key, required this.parameter});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with parameter name and close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        parameter.name,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status and value section
                Card(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Current Value',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            _StatusBadge(status: parameter.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${parameter.value} ${parameter.units}',
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Normal Range: ${parameter.normalRange}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Full AI Summary
                _buildDetailSection(
                  title: 'Analysis Summary',
                  content: parameter.aiSummary.isNotEmpty
                      ? parameter.aiSummary
                      : 'No detailed analysis available for this parameter.',
                  icon: Icons.analytics_outlined,
                  context: context,
                ),
                const SizedBox(height: 16),

                // What causes this section (placeholder for future API data)
                _buildDetailSection(
                  title: 'What Can Affect This Parameter',
                  content: _getPossibleCauses(parameter.name, parameter.status),
                  icon: Icons.help_outline,
                  context: context,
                ),
                const SizedBox(height: 16),

                // Management recommendations section (placeholder for future API data)
                _buildDetailSection(
                  title: 'Recommendations',
                  content:
                      _getRecommendations(parameter.name, parameter.status),
                  icon: Icons.medical_services_outlined,
                  context: context,
                ),
                const SizedBox(height: 24),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required String content,
    required IconData icon,
    required BuildContext context,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Helper method to provide general causes based on parameter name and status
  // This will be replaced with actual API data in the future
  String _getPossibleCauses(String parameterName, ParameterStatus status) {
    final name = parameterName.toLowerCase();

    if (name.contains('hemoglobin') || name.contains('hb')) {
      switch (status) {
        case ParameterStatus.low:
          return 'Low hemoglobin can be caused by iron deficiency, chronic diseases, blood loss, poor nutrition, or certain medications.';
        case ParameterStatus.high:
          return 'High hemoglobin may result from dehydration, smoking, living at high altitudes, or certain medical conditions affecting oxygen levels.';
        default:
          return 'Hemoglobin levels can be affected by diet, hydration, altitude, smoking, and various medical conditions.';
      }
    } else if (name.contains('glucose') || name.contains('sugar')) {
      switch (status) {
        case ParameterStatus.low:
          return 'Low glucose can result from excessive insulin, prolonged fasting, certain medications, or metabolic disorders.';
        case ParameterStatus.high:
          return 'High glucose levels are often associated with diabetes, stress, certain medications, or recent food intake.';
        default:
          return 'Blood glucose is primarily affected by diet, physical activity, stress, medications, and metabolic health.';
      }
    } else if (name.contains('cholesterol')) {
      switch (status) {
        case ParameterStatus.high:
          return 'High cholesterol can be caused by diet high in saturated fats, lack of exercise, genetics, age, and certain medical conditions.';
        default:
          return 'Cholesterol levels are influenced by diet, exercise, genetics, age, and overall metabolic health.';
      }
    }

    return 'Various factors including diet, lifestyle, genetics, medications, and underlying health conditions can affect this parameter. Consult your healthcare provider for personalized information.';
  }

  // Helper method to provide general recommendations based on parameter name and status
  // This will be replaced with actual API data in the future
  String _getRecommendations(String parameterName, ParameterStatus status) {
    final name = parameterName.toLowerCase();

    if (name.contains('hemoglobin') || name.contains('hb')) {
      switch (status) {
        case ParameterStatus.low:
          return 'Consider iron-rich foods (spinach, red meat, beans), vitamin C to enhance iron absorption, and consult your doctor about possible iron supplements.';
        case ParameterStatus.high:
          return 'Stay well-hydrated, avoid smoking, and discuss with your healthcare provider about any underlying conditions.';
        default:
          return 'Maintain a balanced diet rich in iron and folate, stay hydrated, and follow up with your healthcare provider as recommended.';
      }
    } else if (name.contains('glucose') || name.contains('sugar')) {
      switch (status) {
        case ParameterStatus.low:
          return 'Eat regular, balanced meals, avoid skipping meals, and always carry a quick-acting carbohydrate source. Monitor closely and follow your doctor\'s advice.';
        case ParameterStatus.high:
          return 'Follow a diabetes-friendly diet, maintain regular physical activity, monitor blood sugar as directed, and take medications as prescribed by your doctor.';
        default:
          return 'Maintain a balanced diet, regular exercise routine, healthy weight, and follow your healthcare provider\'s monitoring recommendations.';
      }
    } else if (name.contains('cholesterol')) {
      switch (status) {
        case ParameterStatus.high:
          return 'Adopt a heart-healthy diet low in saturated fats, increase physical activity, maintain healthy weight, and discuss medication options with your doctor if needed.';
        default:
          return 'Continue heart-healthy lifestyle choices including balanced diet, regular exercise, and routine monitoring as recommended by your healthcare provider.';
      }
    }

    return 'Follow your healthcare provider\'s specific recommendations, maintain a healthy lifestyle, and schedule regular follow-up appointments for monitoring.';
  }
}
