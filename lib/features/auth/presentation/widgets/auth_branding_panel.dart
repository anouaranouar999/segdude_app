import 'package:flutter/material.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

/// Left-hand marketing / branding panel shown on the Sign In and Sign Up
/// pages: a large welcome heading, short description, a feature list, and
/// a quote card.
///
/// This widget is purely content — the decorative gradient/circles/dots
/// live in [AuthPageBackground] so they can span the whole page instead of
/// just this panel. The panel sizes itself to its natural content; the
/// parent gives it a fixed width (see sign_in_page.dart / sign_up_page.dart)
/// as part of the no-scroll, FittedBox-based responsive layout.
class AuthBrandingPanel extends StatelessWidget {
  const AuthBrandingPanel({super.key});

  static const Color _brandBlue = Color(0xFF2A6FDB);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ---- title (now the main visual focus of the panel) ----
        Text(
          loc.welcomesegtotimetable,
          style: const TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.bold,
            height: 1.15,
            color: _brandBlue,
          ),
        ),
        const SizedBox(height: 16),

        // ---- description ----
        Text(
          loc.segtimetableDescription,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF5A6A85),
          ),
        ),
        const SizedBox(height: 32),

        // ---- feature list ----
        _FeatureRow(
          icon: Icons.calendar_month_outlined,
          title: loc.featureTimetablesTitle,
          description: loc.featureTimetablesDesc,
        ),
        const SizedBox(height: 18),
        _FeatureRow(
          icon: Icons.shield_outlined,
          title: loc.featureSecureTitle,
          description: loc.featureSecureDesc,
        ),
        const SizedBox(height: 18),
        _FeatureRow(
          icon: Icons.bolt_outlined,
          title: loc.featureSaveTimeTitle,
          description: loc.featureSaveTimeDesc,
        ),
        const SizedBox(height: 18),
        _FeatureRow(
          icon: Icons.auto_awesome_outlined,
          title: loc.featureSimpleTitle,
          description: loc.featureSimpleDesc,
        ),
        const SizedBox(height: 32),

        // ---- quote card ----
        Container(
          width: 420,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDDE3EC)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.format_quote_rounded,
                color: _brandBlue,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.segtimetableDescription,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    color: Color(0xFF3A4A63),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1FC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2A6FDB), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF16213E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 13, color: Color(0xFF5A6A85)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
