import 'package:flutter/material.dart';
import '/features/auth/domain/user_entity.dart';
import '/l10n/app_localizations.dart';
import 'profile_tokens.dart';

/// Left-hand (desktop) / top (mobile) card: who the user is.
///
/// Avatar, full name, email, and — when available — the account role as a
/// small chip. No photo-upload system exists anywhere in the codebase, so
/// the avatar is initials-based, matching the "icon in a tinted circle"
/// language already used across Home's feature cards.
class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({super.key, required this.user});

  final UserEntity user;

  String get _displayName {
    final first = user.name?.trim() ?? '';
    final last = user.lastName?.trim() ?? '';
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');
    if (full.isNotEmpty) return full;
    // Same silent fallback already used by the Home Page header.
    return user.email.isNotEmpty ? user.email.split('@').first : '';
  }

  String get _initials {
    final first = user.name?.trim() ?? '';
    final last = user.lastName?.trim() ?? '';
    final firstLetter = first.isNotEmpty ? first[0] : '';
    final lastLetter = last.isNotEmpty ? last[0] : '';
    final combined = (firstLetter + lastLetter).toUpperCase();
    if (combined.isNotEmpty) return combined;
    // Fallback to the first letter of the email local-part so the avatar
    // is never empty, mirroring the name fallback above.
    if (user.email.isNotEmpty) return user.email[0].toUpperCase();
    return '?';
  }

  String? _roleLabel(AppLocalizations l10n) {
    switch (user.role) {
      case 'director':
        return l10n.roleDirector;
      case 'supervisor':
        return l10n.roleSupervisor;
      case 'teacher':
        return l10n.roleTeacher;
      case 'student':
        return l10n.roleStudent;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final roleLabel = _roleLabel(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: ProfileTokens.card(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: _displayName,
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: ProfileTokens.primaryBlue,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _displayName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: ProfileTokens.darkNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              color: ProfileTokens.mutedText,
            ),
          ),
          if (roleLabel != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ProfileTokens.chipBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ProfileTokens.chipBorder),
              ),
              child: Text(
                roleLabel,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: ProfileTokens.primaryBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
