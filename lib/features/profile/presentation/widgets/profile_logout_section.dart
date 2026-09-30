import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import 'profile_tokens.dart';

/// Logout entry point.
///
/// Deliberately styled as a secondary/outlined action (not a solid blue
/// primary button) so it never competes visually with the identity and
/// personal-information content above it — it is placed last on the page,
/// as requested.
///
/// Confirmation + the actual sign-out call are handled by the caller
/// (`ProfilePage`), reusing the existing `AppConfirmationDialog` — this
/// widget only renders the entry point.
class ProfileLogoutSection extends StatelessWidget {
  const ProfileLogoutSection({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: ProfileTokens.dangerRed,
          side: BorderSide(
            color: ProfileTokens.dangerRed.withValues(alpha: 0.35),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text(
          l10n.logout,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
        ),
      ),
    );
  }
}
