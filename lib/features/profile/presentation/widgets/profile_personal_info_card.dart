import 'package:flutter/material.dart';
import '/features/auth/domain/user_entity.dart';
import '/l10n/app_localizations.dart';
import 'profile_info_row.dart';
import 'profile_tokens.dart';

/// Right-hand (desktop) / bottom (mobile) card: the user's personal and
/// account information.
///
/// Phone and Institution are optional at Sign Up and are stored as empty
/// strings (not `null`) when left blank — see `AuthRepository.signUp`,
/// which always passes `.trim()`'d controller text. Both conditions are
/// checked here so an unset optional field never renders as an empty or
/// "missing-looking" row — it is simply omitted, exactly like the rest of
/// the app stays silent about absent-but-normal data (e.g. the Home Page
/// header's silent name -> email fallback).
class ProfilePersonalInfoCard extends StatelessWidget {
  const ProfilePersonalInfoCard({super.key, required this.user});

  final UserEntity user;

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final hasPhone = _hasValue(user.phone);
    final hasInstitution = _hasValue(user.institution);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: ProfileTokens.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.personalInformation,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ProfileTokens.darkNavy,
            ),
          ),
          const SizedBox(height: 22),

          // ---- First Name / Last Name ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ProfileInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: l10n.firstName,
                  value: (user.name?.trim().isNotEmpty ?? false)
                      ? user.name!.trim()
                      : '—',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ProfileInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: l10n.lastName,
                  value: (user.lastName?.trim().isNotEmpty ?? false)
                      ? user.lastName!.trim()
                      : '—',
                ),
              ),
            ],
          ),
          _rowDivider(),

          // ---- Email (always present / required) ----
          ProfileInfoRow(
            icon: Icons.mail_outline_rounded,
            label: l10n.email,
            value: user.email,
          ),

          // ---- Phone (optional — omitted entirely when unset) ----
          if (hasPhone) ...[
            _rowDivider(),
            ProfileInfoRow(
              icon: Icons.phone_outlined,
              label: l10n.phone,
              value: user.phone!.trim(),
            ),
          ],

          // ---- Institution (optional — omitted entirely when unset) ----
          if (hasInstitution) ...[
            _rowDivider(),
            ProfileInfoRow(
              icon: Icons.apartment_outlined,
              label: l10n.institution,
              value: user.institution!.trim(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rowDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Divider(height: 1, thickness: 1, color: ProfileTokens.cardBorder),
    );
  }
}
