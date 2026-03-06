import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static String get url => _readEnv('SUPABASE_URL');
  static String get anonKey => _readEnv('SUPABASE_ANON_KEY');

  static String _readEnv(String key) {
    final String? value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('$key is missing from .env');
    }
    return value;
  }
}
