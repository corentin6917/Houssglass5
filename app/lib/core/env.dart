import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration helper
class Env {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL', fallback: '');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY', fallback: '');
  static String get apiBaseUrl => dotenv.get('API_BASE_URL', fallback: 'http://localhost:8000');
  static String get environment => dotenv.get('ENVIRONMENT', fallback: 'development');

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}
