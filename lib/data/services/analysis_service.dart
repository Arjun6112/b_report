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

      // Convert to ReportParameter objects and apply secondary validation
      final parameters = results.map((item) => ReportParameter.fromJson(item)).toList();
      
      // Apply secondary validation to ensure accurate status determination
      final validatedParameters = parameters.map((param) => _validateParameterStatus(param)).toList();

      return validatedParameters;
    } catch (e) {
      debugPrint("Error parsing report with LLM: $e");
      return []; // Return an empty list on error
    }
  }

  /// Secondary validation to ensure accurate status determination
  ReportParameter _validateParameterStatus(ReportParameter param) {
    // If the range is available and the value is numeric, double-check the status
    if (param.normalRange != 'N/A' && param.normalRange.isNotEmpty) {
      final correctedStatus = _determineStatusFromRange(param.value, param.normalRange);
      if (correctedStatus != null && correctedStatus != param.status) {
        debugPrint("🔧 Correcting status for ${param.name}: ${param.status.name} -> ${correctedStatus.name}");
        return ReportParameter(
          name: param.name,
          value: param.value,
          units: param.units,
          normalRange: param.normalRange,
          aiSummary: param.aiSummary,
          status: correctedStatus,
        );
      }
    }
    return param;
  }

  /// Determine status by parsing numeric ranges and values
  ParameterStatus? _determineStatusFromRange(String value, String range) {
    try {
      // Try to parse the value as a number
      final numericValue = double.tryParse(value.replaceAll(RegExp(r'[^\d.-]'), ''));
      if (numericValue == null) return null;

      // Parse range formats like "13.5 - 17.5", "< 10", "> 5", "13.5-17.5", etc.
      if (range.contains('-')) {
        final rangeParts = range.split('-');
        if (rangeParts.length == 2) {
          final lowerBound = double.tryParse(rangeParts[0].replaceAll(RegExp(r'[^\d.]'), ''));
          final upperBound = double.tryParse(rangeParts[1].replaceAll(RegExp(r'[^\d.]'), ''));
          
          if (lowerBound != null && upperBound != null) {
            if (numericValue < lowerBound) return ParameterStatus.low;
            if (numericValue > upperBound) return ParameterStatus.high;
            return ParameterStatus.normal;
          }
        }
      }
      
      // Handle ranges like "< 10" or "<10"
      if (range.contains('<')) {
        final upperBound = double.tryParse(range.replaceAll(RegExp(r'[^\d.]'), ''));
        if (upperBound != null) {
          return numericValue <= upperBound ? ParameterStatus.normal : ParameterStatus.high;
        }
      }
      
      // Handle ranges like "> 5" or ">5"
      if (range.contains('>')) {
        final lowerBound = double.tryParse(range.replaceAll(RegExp(r'[^\d.]'), ''));
        if (lowerBound != null) {
          return numericValue >= lowerBound ? ParameterStatus.normal : ParameterStatus.low;
        }
      }
    } catch (e) {
      debugPrint("Error parsing range: $e");
    }
    
    return null; // Could not determine status from range
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
    - "status": CRITICALLY IMPORTANT - Analyze the value against the range and determine if it's "low", "normal", "high", or "unknown". 
    - "summary": Provide a brief 1-2 sentence medical explanation of what this test measures and what the current result indicates. Keep it simple and patient-friendly.

    For the status determination, be VERY careful and precise:
    - For numeric values: Compare the exact number against the range bounds
      * If value < lower bound = "low"
      * If value > upper bound = "high" 
      * If value is within bounds = "normal"
      * Example: Value 14.5 with range "13.5 - 17.5" = "normal" (NOT high)
    - For text values: 
      * "Negative", "Absent", "Not Detected" = "normal"
      * "Positive", "Present", "Detected" = "high"
    - If no range is available or you cannot determine, use "unknown"
    
    DOUBLE-CHECK your status determination. A value of 14.5 in a range of 13.5-17.5 is NORMAL, not high.

    Do not include any tests that do not have a clear value. Do not invent any data.

    Here is the structured OCR data:
    $structuredTextJson
    ''';
  }
}
