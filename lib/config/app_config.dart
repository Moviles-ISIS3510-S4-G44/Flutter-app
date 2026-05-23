import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get groqApiUrl =>
      dotenv.env['GROQ_API_URL'] ?? 'https://api.groq.com/openai/v1/chat/completions';
}