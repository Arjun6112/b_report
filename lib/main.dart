import 'package:bloodsage/core/theme.dart';
import 'package:bloodsage/data/models/medical_report.dart';
import 'package:bloodsage/data/models/report_parameter.dart';
import 'package:bloodsage/data/services/analysis_service.dart';
import 'package:bloodsage/data/services/ocr_service.dart';
import 'package:bloodsage/presentation/cubit/report_cubit.dart';
import 'package:bloodsage/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env"); // Load the .env file

  // Initialize Hive for local storage
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(ReportParameterAdapter());
  Hive.registerAdapter(MedicalReportAdapter());
  Hive.registerAdapter(ParameterStatusAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => OcrService()),
        RepositoryProvider(create: (context) => AnalysisService()),
      ],
      child: BlocProvider(
        create: (context) => ReportCubit(
          context.read<OcrService>(),
          context.read<AnalysisService>(),
        ),
        child: MaterialApp(
          title: 'BloodSage',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
