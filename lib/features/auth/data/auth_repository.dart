import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:segdude_app/features/auth/domain/user_entity.dart';

/// Repository responsible for handling authentication logic using Supabase .
class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal(
    Supabase.instance.client,
  );

  factory AuthRepository(SupabaseClient client) => _instance;
  AuthRepository._internal(this._supabase);
  final SupabaseClient _supabase;

  // AuthRepository(this._supabase);

  /// Stream of [AuthState] changes (sign-in, sign-out, session refresh).
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Retrieves the currently authenticated [UserEntity], or null if not signed in.
  UserEntity? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['full_name'],
      lastName: user.userMetadata?['last_name'],
      role: user.userMetadata?['role'],
      phone: user.userMetadata?['phone'],
      institution: user.userMetadata?['institution'],
    );
  }

  /// Signs in a user using email and password.
  /// Returns a message indicating "success" or "e.g. Invalid credentials".
  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      return 'success';
    } on AuthException catch (e) {
      return e.message;
    }
  }

  /// Registers a new user with email and password.
  /// Returns a message indicating "success" or "e.g. Email already in use".
  Future<String> signUp({
    required String email,
    required String password,
    required String name,
    required String lastName,
    required String role,
    String? phone,
    String? institution,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'last_name': lastName,
          'role': role,
          'phone': phone,
          'institution': institution,
        },
      );
      return 'success';
    } on AuthException catch (e) {
      return e.message;
    }
  }

  /// Sends a password-reset email to the given address.
  /// Returns a message indicating "success" or e.g. "Invalid email".
  Future<String> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return 'success';
    } on AuthException catch (e) {
      return e.message;
    }
  }

  /// get user from database
  Future<String> createUserTable() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return 'no user';
      final response = await _supabase.from('users').select().eq('id', user.id);
      if (response.isEmpty) {
        await _supabase.from('users').insert({
          'id': user.id,
          'email': user.email,
        });
      }
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
