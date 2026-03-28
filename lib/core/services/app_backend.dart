import 'package:hote_v2/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppBackend {
  AppBackend._();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || !AppConfig.hasSupabase) {
      return;
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    _initialized = true;
  }

  static bool get isEnabled => _initialized && AppConfig.hasSupabase;

  static SupabaseClient? get client =>
      isEnabled ? Supabase.instance.client : null;

  static Session? get currentSession => client?.auth.currentSession;

  static User? get currentUser => client?.auth.currentUser;

  static String? get accessToken => currentSession?.accessToken;

  static String? get currentUserId => currentUser?.id;
}
