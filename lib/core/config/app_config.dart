import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  const AppConfig._();

  static bool _supabaseInitialized = false;
  static Future<void>? _supabaseInitialization;

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://wtnegfrmbrhvukrtonah.supabase.co',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_oLedvRpO5BUcWANNuyc-4Q_IwDpsTwy',
  );

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  static bool get isSupabaseReady => hasSupabaseConfig && _supabaseInitialized;

  static SupabaseClient? get supabaseClientOrNull {
    if (!isSupabaseReady) {
      return null;
    }
    return Supabase.instance.client;
  }

  static Future<void> initializeSupabase() {
    if (!hasSupabaseConfig) {
      return Future.value();
    }

    return _supabaseInitialization ??=
        Supabase.initialize(
          url: supabaseUrl,
          publishableKey: supabasePublishableKey,
        ).then((_) {
          _supabaseInitialized = true;
        });
  }

  static Future<bool> ensureSupabaseReady() async {
    if (!hasSupabaseConfig) {
      return false;
    }

    await initializeSupabase();
    return isSupabaseReady;
  }
}
