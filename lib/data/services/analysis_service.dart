// lib/data/services/analysis_service.dart
import 'dart:convert';
import 'package:bloodsage/data/models/report_parameter.dart'; // Keep your data model
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AnalysisService {
  final GenerativeModel _model;

  AnalysisService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash', // A powerful model for this task
          apiKey: dotenv.env['GEMINI_API_KEY']!,
          generationConfig: GenerationConfig(
            temperature: 0.1,
            responseMimeType: 'application/json',
          ),
        );

  /// Sends the entire structured text to the LLM for parsing.
  Future<List<ReportParameter>> parseReportWithLlm(
      List<Map<String, dynamic>> structuredText) async {
    try {
      final prompt = _createParsingPrompt(jsonEncode(structuredText));
      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null) {
        throw Exception('Received null response from Gemini API');
      }

      debugPrint("🤖 Gemini Full Report JSON Response: ${response.text}");

      final Map<String, dynamic> jsonResponse = jsonDecode(response.text!);
      final List<dynamic> results = jsonResponse['results'] ?? [];

      return results.map((item) => ReportParameter.fromJson(item)).toList();
    } catch (e) {
      debugPrint("Error parsing report with LLM: $e");
      return []; // Return an empty list on error
    }
  }

  String _createParsingPrompt(String structuredTextJson) {
    return '''
    You are an expert medical report data extractor and analyzer. Your task is to analyze the provided JSON data, which contains text elements and their x,y coordinates from an OCR scan of a medical lab report.
    
    Identify only the primary medical test results. Ignore all patient details (name, age, gender), doctor names, addresses, headers, footers, page numbers, and other metadata.
    
    The data is structured as an array of objects, where each object has 'text', 'left', 'top', 'right', and 'bottom' keys. Use the coordinates to understand the table structure. Text elements with similar 'top' values are on the same line. Text elements with similar 'left' values are in the same column.
    
    Your response MUST be a single valid JSON object. This object must contain a single key: "results". The value of "results" should be an array of JSON objects, where each object represents a single medical test and has the following exact keys:
    - "name": The name of the test (e.g., "Hemoglobin").
    - "value": The measured value of the test (e.g., "12.0" or "Negative").
    - "units": The units for the value (e.g., "g/dL" or "%"). If no units are present, use "N/A".
    - "range": The reference range for the test (e.g., "13.5 - 17.5"). If no range is present, use "N/A".
    - "status": Analyze the value against the range and determine if it's "low", "normal", "high", or "unknown". For non-numeric values like "Negative/Positive", use "normal" for negative and "high" for positive results.
    - "summary": Provide a brief 1-2 sentence medical explanation of what this test measures and what the current result indicates. Keep it simple and patient-friendly.

    For the status determination:
    - Compare numeric values against the provided range
    - For text values like "Negative", "Positive", "Absent", "Present" - use your medical knowledge
    - If no range is available, use "unknown"

    Do not include any tests that do not have a clear value. Do not invent any data.

    Here is the structured OCR data:
    $structuredTextJson
    ''';
  }
}
