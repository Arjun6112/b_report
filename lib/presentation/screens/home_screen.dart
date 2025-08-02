import 'package:bloodsage/data/models/report_parameter.dart';
import 'package:bloodsage/data/models/medical_report.dart';
import 'package:bloodsage/presentation/cubit/report_cubit.dart';
import 'package:bloodsage/presentation/cubit/report_state.dart';
import 'package:bloodsage/presentation/widgets/parameter_card.dart';
import 'package:bloodsage/presentation/widgets/history_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BloodSage'),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/ai-stars.png',
              width: 32,
              height: 32,
            ),
            onPressed: () {
              _showDiagnosisBottomSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              _showHistoryDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<ReportCubit, ReportState>(
        listener: (context, state) {
          // Remove snackbar listeners
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Welcome Back', style: textTheme.bodyMedium),
              Text(
                'Your Health Summary',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: state is ReportLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_file_outlined),
                label: Text(
                  state is ReportLoading
                      ? 'Processing...'
                      : 'Upload New Report',
                ),
                onPressed: state is ReportLoading
                    ? null
                    : () => context.read<ReportCubit>().processNewReport(),
              ),
              const SizedBox(height: 24),
              _buildReportContent(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, ReportState state) {
    if (state is ReportSuccess) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Report Results',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...state.parameters.map((param) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ParameterCard(parameter: param),
              )),
        ],
      );
    }
    if (state is ReportInitial) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.file_present_rounded, size: 50, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Upload a report to see your results.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    // Loading and Failure states are handled by the button and listener
    return const SizedBox.shrink();
  }

  void _showDiagnosisBottomSheet(BuildContext context) {
    final reportState = context.read<ReportCubit>().state;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DiagnosisBottomSheet(
        parameters: reportState is ReportSuccess ? reportState.parameters : [],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => HistoryDialog(
        onReportSelected: (report) {
          // Load the selected report into the cubit
          context.read<ReportCubit>().loadReportParameters(report.parameters);
        },
      ),
    );
  }
}

// Custom bottom sheet widget for diagnosis
class DiagnosisBottomSheet extends StatefulWidget {
  final List<ReportParameter> parameters;

  const DiagnosisBottomSheet({super.key, required this.parameters});

  @override
  State<DiagnosisBottomSheet> createState() => _DiagnosisBottomSheetState();
}

class _DiagnosisBottomSheetState extends State<DiagnosisBottomSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/icons/ai-stars.png',
                    width: 28,
                    height: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Analysis',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'AI-powered insights from your results',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              enableFeedback: true,
              controller: _tabController,
              indicator: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Diagnosis'),
                Tab(text: 'Advice'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context),
                _buildDiagnosisTab(context),
                _buildRecommendationsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.parameters.isEmpty) {
      return _buildNoDataView(context);
    }

    final abnormalParameters = widget.parameters
        .where((p) => p.status != ParameterStatus.normal)
        .toList();
    final normalParameters = widget.parameters
        .where((p) => p.status == ParameterStatus.normal)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Tests',
                  value: widget.parameters.length.toString(),
                  color: colorScheme.primary,
                  icon: Icons.assessment,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Normal',
                  value: normalParameters.length.toString(),
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Abnormal',
                  value: abnormalParameters.length.toString(),
                  color: Colors.orange,
                  icon: Icons.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Abnormal Parameters
          if (abnormalParameters.isNotEmpty) ...[
            Text(
              'Parameters Requiring Attention',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...abnormalParameters.map((param) => _buildParameterTile(param)),
            const SizedBox(height: 24),
          ],

          // Normal Parameters
          if (normalParameters.isNotEmpty) ...[
            Text(
              'Normal Parameters',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...normalParameters.map((param) => _buildParameterTile(param)),
          ],
        ],
      ),
    );
  }

  Widget _buildDiagnosisTab(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (widget.parameters.isEmpty) {
      return _buildNoDataView(context);
    }

    final diagnosis = _generateDiagnosis();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[50]!,
                  Colors.blue[100]!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.blue[700], size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'AI Analysis',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  diagnosis,
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Risk Factors
          _buildDiagnosisSection(
            title: 'Identified Risk Factors',
            icon: Icons.warning_amber,
            color: Colors.orange,
            content: _getRiskFactors(),
          ),
          const SizedBox(height: 20),

          // Possible Conditions
          _buildDiagnosisSection(
            title: 'Conditions to Monitor',
            icon: Icons.visibility,
            color: Colors.red,
            content: _getPossibleConditions(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab(BuildContext context) {
    if (widget.parameters.isEmpty) {
      return _buildNoDataView(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecommendationSection(
            title: 'Immediate Actions',
            icon: Icons.priority_high,
            color: Colors.red,
            recommendations: _getImmediateRecommendations(),
          ),
          const SizedBox(height: 24),
          _buildRecommendationSection(
            title: 'Lifestyle Changes',
            icon: Icons.favorite,
            color: Colors.green,
            recommendations: _getLifestyleRecommendations(),
          ),
          const SizedBox(height: 24),
          _buildRecommendationSection(
            title: 'Follow-up Care',
            icon: Icons.schedule,
            color: Colors.blue,
            recommendations: _getFollowUpRecommendations(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.file_present_rounded,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No Report Data Available',
              style: textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a medical report to see AI-powered health analysis and recommendations.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterTile(ReportParameter parameter) {
    final Color statusColor;
    final IconData statusIcon;

    switch (parameter.status) {
      case ParameterStatus.high:
        statusColor = Colors.red;
        statusIcon = Icons.arrow_upward;
        break;
      case ParameterStatus.low:
        statusColor = Colors.blue;
        statusIcon = Icons.arrow_downward;
        break;
      case ParameterStatus.normal:
        statusColor = Colors.green;
        statusIcon = Icons.check;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parameter.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${parameter.value} ${parameter.units}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            parameter.status.name.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisSection({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> recommendations,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recommendations.map((rec) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec,
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  String _generateDiagnosis() {
    final abnormalParams = widget.parameters
        .where((p) => p.status != ParameterStatus.normal)
        .toList();

    if (abnormalParams.isEmpty) {
      return 'Excellent news! All your test parameters are within normal ranges. This indicates good overall health. Continue maintaining your current healthy lifestyle and regular check-ups.';
    }

    final lowParams =
        abnormalParams.where((p) => p.status == ParameterStatus.low).toList();
    final highParams =
        abnormalParams.where((p) => p.status == ParameterStatus.high).toList();

    String diagnosis =
        'Based on your test results, here\'s what the data suggests:\n\n';

    if (highParams.isNotEmpty) {
      diagnosis +=
          'Elevated levels detected in: ${highParams.map((p) => p.name).join(', ')}. ';
    }

    if (lowParams.isNotEmpty) {
      diagnosis +=
          'Lower than normal levels found in: ${lowParams.map((p) => p.name).join(', ')}. ';
    }

    diagnosis +=
        '\n\nThese variations from normal ranges may indicate the need for further evaluation or lifestyle modifications. The combination of these results suggests monitoring and potentially addressing underlying factors that could be affecting these parameters.';

    return diagnosis;
  }

  String _getRiskFactors() {
    final abnormalParams = widget.parameters
        .where((p) => p.status != ParameterStatus.normal)
        .toList();

    if (abnormalParams.isEmpty) {
      return 'No significant risk factors identified from current test results. Maintain healthy lifestyle practices for continued wellness.';
    }

    List<String> risks = [];

    for (var param in abnormalParams) {
      final name = param.name.toLowerCase();
      if (name.contains('glucose') || name.contains('sugar')) {
        if (param.status == ParameterStatus.high) {
          risks.add('Increased risk for diabetes or metabolic syndrome');
        }
      } else if (name.contains('cholesterol')) {
        if (param.status == ParameterStatus.high) {
          risks.add('Elevated cardiovascular risk due to high cholesterol');
        }
      } else if (name.contains('hemoglobin') || name.contains('hb')) {
        if (param.status == ParameterStatus.low) {
          risks.add('Risk of anemia and associated fatigue');
        }
      }
    }

    if (risks.isEmpty) {
      risks.add(
          'General health monitoring recommended due to abnormal parameter values');
    }

    return risks.join('\n• ');
  }

  String _getPossibleConditions() {
    final abnormalParams = widget.parameters
        .where((p) => p.status != ParameterStatus.normal)
        .toList();

    if (abnormalParams.isEmpty) {
      return 'No conditions of immediate concern based on current results. Continue regular health monitoring.';
    }

    List<String> conditions = [];

    for (var param in abnormalParams) {
      final name = param.name.toLowerCase();
      if (name.contains('glucose') && param.status == ParameterStatus.high) {
        conditions.add('Pre-diabetes or Type 2 Diabetes');
      } else if (name.contains('cholesterol') &&
          param.status == ParameterStatus.high) {
        conditions.add('Hyperlipidemia or Cardiovascular Disease Risk');
      } else if (name.contains('hemoglobin') &&
          param.status == ParameterStatus.low) {
        conditions.add('Iron Deficiency Anemia');
      }
    }

    if (conditions.isEmpty) {
      conditions
          .add('Requires further evaluation to determine underlying causes');
    }

    return conditions.join('\n• ');
  }

  List<String> _getImmediateRecommendations() {
    final abnormalParams = widget.parameters
        .where((p) => p.status != ParameterStatus.normal)
        .toList();

    if (abnormalParams.isEmpty) {
      return ['Schedule routine follow-up with your healthcare provider'];
    }

    List<String> recommendations = [
      'Consult your healthcare provider to discuss these results',
      'Do not make drastic changes without medical supervision',
    ];

    for (var param in abnormalParams) {
      final name = param.name.toLowerCase();
      if (name.contains('glucose') && param.status == ParameterStatus.high) {
        recommendations.add('Monitor blood sugar levels more frequently');
      } else if (name.contains('cholesterol') &&
          param.status == ParameterStatus.high) {
        recommendations.add('Consider cardiovascular risk assessment');
      }
    }

    return recommendations;
  }

  List<String> _getLifestyleRecommendations() {
    return [
      'Maintain a balanced, nutrient-rich diet',
      'Engage in regular physical activity (150 minutes/week)',
      'Ensure adequate sleep (7-9 hours nightly)',
      'Manage stress through meditation or relaxation techniques',
      'Stay hydrated and limit alcohol consumption',
      'Avoid smoking and limit processed foods',
    ];
  }

  List<String> _getFollowUpRecommendations() {
    return [
      'Schedule follow-up testing in 3-6 months',
      'Keep a health diary to track symptoms',
      'Regular monitoring of key parameters',
      'Annual comprehensive health check-ups',
      'Discuss family history with your doctor',
      'Consider nutritionist consultation if needed',
    ];
  }
}
