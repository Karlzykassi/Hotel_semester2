class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://iqhlnrtobqjuihxagrmw.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_P79tXpzOlg5qqddS6PPO3A_0t0GHkbp',
  );

  static bool get hasSupabase =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  static Uri restUri(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return Uri.parse('$supabaseUrl/rest/v1/$path').replace(
      queryParameters: _normalizedQueryParameters(queryParameters),
    );
  }

  static Map<String, String>? _normalizedQueryParameters(
    Map<String, dynamic>? values,
  ) {
    if (values == null || values.isEmpty) {
      return null;
    }

    final Map<String, String> normalized = <String, String>{};
    values.forEach((String key, dynamic value) {
      if (value == null) {
        return;
      }
      normalized[key] = '$value';
    });
    return normalized.isEmpty ? null : normalized;
  }
}
