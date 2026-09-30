import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '/features/auth/domain/user_entity.dart';
import '/features/auth/providers/auth_provider.dart';
import '/l10n/app_localizations.dart';
import '/shared/widgets/app_confirmation_dialog.dart';
import 'widgets/profile_identity_card.dart';
import 'widgets/profile_logout_section.dart';
import 'widgets/profile_personal_info_card.dart';
import 'widgets/profile_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProfilePage — V1
//
// Scope is intentionally narrow: identity, personal/account information,
// and logout. Nothing else (no settings, no editing) — see the design
// analysis for the full rationale.
//
// Data source: `userProvider` (Riverpod) — the exact same provider already
// used by the Home Page header. No second source of truth is introduced.
// ─────────────────────────────────────────────────────────────────────────────
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await AppConfirmationDialog.show(
      context,
      title: l10n.confirmLogoutTitle,
      message: l10n.confirmLogoutMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.logout,
      icon: Icons.logout_rounded,
      confirmButtonColor: Colors.red,
    );

    if (!confirmed) return;

    await ref.read(authRepositoryProvider).signOut();

    // Explicit navigation instead of relying on the router's redirect: once
    // signed out, `/profile` is a protected route, so falling through to
    // the redirect would bounce the user to `/login?from=/profile` — a
    // confusing destination right after a voluntary logout. Sending them
    // to the public Home Page is the friendlier outcome.
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: ProfileTokens.pageBg,
      appBar: AppBar(
        // Blends into the flat page background instead of creating a hard,
        // differently-colored strip — same convention as Sign In / Reset
        // Password.
        backgroundColor: ProfileTokens.appBarBg,
        elevation: 0,
        centerTitle: true,
        title: Text(l10n.profile),
        // No custom `leading`: relies on GoRouter/Navigator's automatic
        // back button, exactly like Sign In and Reset Password.
      ),
      // A user landing here without a session is transiently possible
      // right after sign-out (the router redirect hasn't run yet) — guard
      // against a null-user crash with a tiny, silent loading state
      // instead of building the page with null data.
      body: user == null
          ? const SizedBox.shrink()
          : SafeArea(
              child: _ProfileBody(
                user: user,
                onLogout: () => _handleLogout(context, ref),
              ),
            ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user, required this.onLogout});

  final UserEntity user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Same breakpoint philosophy as the Home Page (`isWide = width >= 900`).
        final isWide = width >= 900;
        final horizontalPadding = isWide ? 40.0 : 24.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isWide ? 40 : 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isWide)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 300,
                            child: ProfileIdentityCard(user: user),
                          ),
                          const SizedBox(width: 24),
                          Expanded(child: ProfilePersonalInfoCard(user: user)),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfileIdentityCard(user: user),
                        const SizedBox(height: 20),
                        ProfilePersonalInfoCard(user: user),
                      ],
                    ),
                  const SizedBox(height: 28),
                  ProfileLogoutSection(onLogout: onLogout),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
