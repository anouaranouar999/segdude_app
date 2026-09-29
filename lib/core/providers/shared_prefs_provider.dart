import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';

/// Provider for the SharedPreferencesService instance
final sharedPrefsProvider = Provider<SharedPreferencesService>((ref) {
  return SharedPreferencesService();
});
