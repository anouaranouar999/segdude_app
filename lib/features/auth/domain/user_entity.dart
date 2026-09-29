/// Represents a user within the application's domain.
///
/// This entity is decoupled from any specific backend (like Supabase)
/// to ensure the domain layer remains clean.
class UserEntity {
  /// Unique identifier for the user.
  final String id;

  /// The user's email address.
  final String email;

  /// The user's display name, if available.
  final String? name;

  /// The user's last name, if available.
  final String? lastName;

  /// The user's role, if available.
  final String? role;

  /// The user's phone number, if available.
  final String? phone;

  /// The user's institution, if available.
  final String? institution;

  UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.lastName,
    this.role,
    this.phone,
    this.institution,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          lastName == other.lastName &&
          role == other.role &&
          phone == other.phone &&
          institution == other.institution;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      lastName.hashCode ^
      role.hashCode ^
      phone.hashCode ^
      institution.hashCode;
}
