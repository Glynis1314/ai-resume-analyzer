import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';

/// Service that calls the Google Gemini API to generate AI-powered
/// resume insights: a professional summary, job fit score, and smart suggestions.
class AiService {
  GenerativeModel? _model;

  AiService() {
    if (AppConfig.isAiEnabled) {
      _model = GenerativeModel(
        model: AppConfig.geminiModel,
        apiKey: AppConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 2000,
        ),
      );
    }
  }

  /// Analyzes the given [resumeText] using the Gemini API.
  /// Returns a map with keys: `summary`, `job_fit_score`, `suggestions`.
  /// Returns null if AI is disabled or an error occurs.
  Future<Map<String, dynamic>?> analyzeWithAI(String resumeText) async {
    if (!AppConfig.isAiEnabled || _model == null) return null;

    // Truncate to avoid token overflow (Gemini Flash handles ~30k tokens)
    final trimmedText = resumeText.length > 4000
        ? resumeText.substring(0, 4000)
        : resumeText;

    final prompt = '''You are an expert HR recruiter. Analyze this resume and respond with ONLY this JSON format, no markdown, no code blocks:

Resume: $trimmedText

{"summary":"Brief 2-3 sentence assessment of strengths and immediate improvements needed.","job_fit_score":85,"suggestion_1":"Actionable improvement tip 1","suggestion_2":"Actionable improvement tip 2","suggestion_3":"Actionable improvement tip 3","suggestion_4":"Actionable improvement tip 4","suggestion_5":"Actionable improvement tip 5"}

IMPORTANT:
- Return ONLY the JSON object, nothing else
- No markdown, no code blocks, no explanation
- Keep each suggestion concise (1-2 sentences)
- Focus on: formatting, ATS keywords, achievement metrics, skill clarity
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);
      var rawText = response.text ?? '';

      if (rawText.isEmpty) {
        return {'error': 'Empty response from AI'};
      }

      // Debug info
      print('[AI Response Length] ${rawText.length} chars');

      // Step 1: Remove all markdown formatting
      rawText = rawText.replaceAll(RegExp(r'```[a-z]*'), '').trim();

      // Step 2: Find JSON boundaries - look for first { and last }
      final jsonStart = rawText.indexOf('{');
      final jsonEnd = rawText.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) {
        print('[AI Error] Invalid JSON boundaries. Start: $jsonStart, End: $jsonEnd');
        print('[AI Error] Response text: ${rawText.substring(0, (rawText.length > 300 ? 300 : rawText.length))}');
        return {'error': 'API response does not contain valid JSON'};
      }

      // Step 3: Extract JSON substring
      var jsonString = rawText.substring(jsonStart, jsonEnd + 1);
      
      // Step 4: Remove any newlines/extra whitespace within the JSON to normalize it
      jsonString = jsonString.replaceAll(RegExp(r'\s+'), ' ');
      
      print('[AI JSON Extracted] ${jsonString.substring(0, (jsonString.length > 200 ? 200 : jsonString.length))}...');

      // Step 5: Try to parse as-is first
      try {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        print('[AI Parse Success]');
        return _validateAndReturnResponse(decoded);
      } catch (e) {
        print('[AI Initial parse failed: $e]');
      }

      // Step 6: If parsing fails, try to repair
      print('[AI Attempting JSON repair...]');
      
      // Check for unterminated strings by counting quotes
      int quoteCount = 0;
      for (int i = 0; i < jsonString.length; i++) {
        if (jsonString[i] == '"' && (i == 0 || jsonString[i - 1] != '\\')) {
          quoteCount++;
        }
      }

      // If we have odd number of quotes, add a closing quote
      if (quoteCount % 2 != 0) {
        print('[AI Found unterminated string, attempting to close...]');
        jsonString = jsonString.replaceFirst(RegExp(r',\s*}$'), '}');
        jsonString = jsonString + '"}';
      }

      // Count braces and add missing closing braces
      int openBraces = jsonString.split('{').length - 1;
      int closeBraces = jsonString.split('}').length - 1;
      while (closeBraces < openBraces) {
        jsonString += '}';
        closeBraces++;
      }

      try {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        print('[AI Repair successful]');
        return _validateAndReturnResponse(decoded);
      } catch (repairError) {
        print('[AI Repair failed: $repairError]');
        print('[AI Problem JSON (first 500 chars)]: ${jsonString.substring(0, (jsonString.length > 500 ? 500 : jsonString.length))}');
        return {'error': 'Failed to parse AI response after repair'};
      }
    } on GenerativeAIException catch (e) {
      print('[AI API Error] ${e.message}');
      return {'error': 'Gemini API error: ${e.message}'};
    } catch (e) {
      print('[AI Unexpected Error] $e');
      return {'error': 'Unexpected error processing AI response'};
    }
  }

  /// Validates the response contains required fields and converts flat structure to expected format
  Map<String, dynamic> _validateAndReturnResponse(
      Map<String, dynamic> decoded) {
    final hasSummary = decoded.containsKey('summary');
    final hasScore = decoded.containsKey('job_fit_score');

    if (!hasSummary || !hasScore) {
      print('[AI Validation] Missing required fields');
      return {
        'error': 'AI response missing required fields (summary, job_fit_score)'
      };
    }

    // Convert flat suggestion_1, suggestion_2, etc. to a suggestions list
    final suggestions = <String>[];
    for (int i = 1; i <= 5; i++) {
      final key = 'suggestion_$i';
      if (decoded.containsKey(key) && decoded[key] != null) {
        suggestions.add(decoded[key].toString().trim());
      }
    }

    // Return reformatted response with suggestions as a list
    return {
      'summary': decoded['summary'],
      'job_fit_score': decoded['job_fit_score'],
      'suggestions': suggestions.isNotEmpty ? suggestions : [],
    };
  }
}
