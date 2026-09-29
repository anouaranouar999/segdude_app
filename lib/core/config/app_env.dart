import 'package:segdude_app/core/errors/app_exception.dart';

/// Development + Production only, resolved via --dart-define, not a bundled
/// .env asset.
class AppEnv {
  AppEnv._();

  static const _envName = String.fromEnvironment('ENV', defaultValue: 'dev');
  static bool get isProd => _envName == 'prod';
  static bool get isDev => !isProd;

  static const scheduleApiBaseUrl = String.fromEnvironment('SCHEDULE_API_BASE_URL');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const chariApiUrl = String.fromEnvironment('CHARI_API_URL');
  static const chariApiKey = String.fromEnvironment('CHARI_API_KEY');
  static const companyRib = String.fromEnvironment('COMPANY_RIB');
  static const companyBeneficiaryName = String.fromEnvironment('COMPANY_BENEFICIARY_NAME');

  static void assertConfigured() {
    final missing = <String>[
      if (scheduleApiBaseUrl.isEmpty) 'SCHEDULE_API_BASE_URL',
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
    if (missing.isNotEmpty) {
      throw AppException(
        'Missing required --dart-define value(s): ${missing.join(', ')}.',
      );
    }
  }
}