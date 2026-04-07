// /// App-wide configuration constants.
// /// ⚠️ Add your Gemini API key here.
// /// Get a FREE key at: https://aistudio.google.com/app/apikey
// /// This file should be added to .gitignore in production.
// class AppConfig {
//   // Replace with your actual Gemini API key
//   static const String geminiApiKey = '';

//   // Gemini model to use (gemini-1.5-flash is fast and free-tier friendly)
//   static const String geminiModel = 'gemini-1.5-flash';

//   // Whether AI features are enabled (set to false if no API key)
//   static bool get isAiEnabled =>
//       geminiApiKey.isNotEmpty && geminiApiKey != '';
// }

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? '';

  static const String geminiModel = 'gemini-2.5-flash';

  static bool get isAiEnabled => geminiApiKey.isNotEmpty;
}