import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseClient? _client;

  // Get Supabase client instance
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  // Check if Supabase is initialized
  static bool get isInitialized => _client != null;

  // Initialize Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      print('SupabaseService: Initialized successfully');
    } catch (e) {
      print('SupabaseService: Initialization error: $e');
      rethrow;
    }
  }
}
