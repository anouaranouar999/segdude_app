import 'package:segdude_app/core/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:segdude_app/features/auth/data/auth_repository.dart';
import 'package:segdude_app/features/auth/domain/user_entity.dart';

/// Provides the [AuthRepository] instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRepository(supabase);
});

/// Provides a stream of [AuthState] from Supabase.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Provides the current [UserEntity].
///
/// Listens to [authStateProvider] and maps the Supabase user to our domain [UserEntity].
final userProvider = Provider<UserEntity?>((ref) {
  // Watch auth state changes reactively
  final authState = ref.watch(authStateProvider).value;

  // If we haven't received a stream event yet, fallback to current session
  if (authState == null) return ref.read(authRepositoryProvider).currentUser;

  final user = authState.session?.user;
  if (user == null) return null;

  // Map Supabase User to domain UserEntity
  return UserEntity(
    id: user.id,
    email: user.email ?? '',
    name: user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
    lastName: user.userMetadata?['last_name'],
    role: user.userMetadata?['role'],
    phone: user.userMetadata?['phone'],
    institution: user.userMetadata?['institution'],
  );
});
