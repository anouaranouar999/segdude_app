import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single source of the Supabase client -- auth_provider.dart's own
/// duplicate definition is removed by this script (see the auth_provider
/// patch below), so there is exactly one supabaseClientProvider.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});