import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiBaseUrl {
    final raw = dotenv.env['API_BASE_URL'] ?? '';
    return raw.endsWith('/') ? raw.substring(0, raw.length - 1) : raw;
  }

  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get groqApiUrl =>
      dotenv.env['GROQ_API_URL'] ?? 'https://api.groq.com/openai/v1/chat/completions';
}