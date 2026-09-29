import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:segdude_app/l10n/app_localizations.dart';

/// Minimum supported viewport width. Below this, screen-size-sensitive
/// features are gated behind [DesktopRequiredCard] — see
/// `lib/shared/navigation_guard.dart`, the single place that reads this
/// constant to decide whether navigation is allowed.
const double kDesktopRequiredBreakpoint = 800;

/// Which copy/icon [DesktopRequiredCard] should show. The visual design
/// (card, animations, layout) is always identical — only the strings and
/// icon change — so narrow-window pages get on-brand messaging without a
/// second widget to maintain.
enum DesktopRequiredCardVariant {
  /// Default: viewport is too small in general (used by [NavigationGuard]).
  desktopRequired,

  /// User is already on a desktop/laptop, but the *browser window* is too
  /// narrow for the current page (used by `ResponsiveWidthGuard`).
  narrowWindow,
}

/// Full-screen informational card shown when the user tries to use a
/// feature that requires a viewport of at least [kDesktopRequiredBreakpoint]
/// (or, with [DesktopRequiredCardVariant.narrowWindow], a page-specific
/// minimum width). Unlike a blocking global gate, it is shown on demand by
/// `NavigationGuard` / `ResponsiveWidthGuard` rather than automatically on
/// every page.
///
/// Self-contained on purpose: it does not depend on the project's
/// generated `AppLocalizations`, so it can be dropped in (or removed)
/// without touching the localization pipeline or any feature module.
class DesktopRequiredCard extends StatefulWidget {
  const DesktopRequiredCard({
    super.key,
    this.variant = DesktopRequiredCardVariant.desktopRequired,
  });

  final DesktopRequiredCardVariant variant;

  @override
  State<DesktopRequiredCard> createState() => _DesktopRequiredCardState();
}

class _DesktopRequiredCardState extends State<DesktopRequiredCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _DesktopRequiredStrings _strings(BuildContext context) {
    final languageCode = Localizations.maybeLocaleOf(context)?.languageCode;
    if (widget.variant == DesktopRequiredCardVariant.narrowWindow) {
      switch (languageCode) {
        case 'fr':
          return const _DesktopRequiredStrings(
            title: 'Fenêtre plus large requise',
            description:
                'Cette page nécessite une fenêtre de navigateur plus large '
                'pour s\'afficher correctement. Veuillez agrandir ou '
                'maximiser votre fenêtre.',
            secondary:
                'Cette section est optimisée pour les fenêtres de '
                'navigateur plus larges.',
            helperTitle: 'Déjà sur un grand écran ?',
            helperBody:
                'La page redeviendra disponible automatiquement dès que '
                'la fenêtre sera assez large.',
          );
        case 'ar':
          return const _DesktopRequiredStrings(
            title: 'يلزم نافذة متصفح أوسع',
            description:
                'تحتاج هذه الصفحة إلى نافذة متصفح أوسع لعرضها بشكل صحيح. '
                'يرجى تكبير نافذة المتصفح أو تعظيمها.',
            secondary: 'هذا القسم مُحسَّن لنوافذ المتصفح الأوسع.',
            helperTitle: 'هل أنت بالفعل على شاشة كبيرة؟',
            helperBody:
                'ستصبح الصفحة متاحة تلقائيًا بمجرد أن تصبح نافذة المتصفح '
                'واسعة بما يكفي.',
          );
        case 'en':
        default:
          return const _DesktopRequiredStrings(
            title: 'Wider Window Required',
            description:
                'This page needs a wider browser window to display '
                'properly. Please enlarge or maximize your browser window.',
            secondary: 'This section is optimized for wider browser windows.',
            helperTitle: 'Already on a wide screen?',
            helperBody:
                'The page will become available automatically once your '
                'browser window is wide enough.',
          );
      }
    }

    switch (languageCode) {
      case 'fr':
        return const _DesktopRequiredStrings(
          title: 'Écran plus grand requis',
          description:
              'Veuillez utiliser un écran plus grand ou agrandir la '
              'fenêtre de votre navigateur.',
          secondary:
              'Certaines fonctionnalités sont disponibles uniquement sur '
              'les grands écrans.',
          helperTitle: 'Vous utilisez déjà un ordinateur ?',
          helperBody: 'Agrandissez simplement la fenêtre de votre navigateur.',
        );
      case 'ar':
        return const _DesktopRequiredStrings(
          title: 'يلزم استخدام شاشة أكبر',
          description: 'يرجى استخدام شاشة أكبر أو تكبير نافذة المتصفح.',
          secondary: 'بعض الميزات متاحة فقط على الشاشات الكبيرة.',
          helperTitle: 'هل تستخدم جهاز كمبيوتر بالفعل؟',
          helperBody: 'ما عليك سوى تكبير نافذة المتصفح.',
        );
      case 'en':
      default:
        return const _DesktopRequiredStrings(
          title: 'Bigger Screen Required',
          description:
              'Please use a bigger screen or enlarge your browser window.',
          secondary: 'Some features are available only on larger screens.',
          helperTitle: 'Already using a computer?',
          helperBody:
              'Simply maximize your browser window for the best experience.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final strings = _strings(context);
    final isRtl = Localizations.maybeLocaleOf(context)?.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dimmed, blurred backdrop. Absorbs every tap so the hidden
            // UI behind it can never be reached or dismissed.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(color: colorScheme.scrim.withAlpha(6)),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        elevation: 24,
                        shadowColor: colorScheme.shadow.withAlpha(35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(48, 56, 48, 48),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  context.pop();
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.close,
                                ),
                              ),
                              _DecoratedIcon(
                                colorScheme: colorScheme,
                                icon:
                                    widget.variant ==
                                        DesktopRequiredCardVariant.narrowWindow
                                    ? Icons.aspect_ratio_rounded
                                    : Icons.desktop_windows_rounded,
                              ),
                              const SizedBox(height: 32),
                              Text(
                                strings.title,
                                textAlign: TextAlign.center,
                                style:
                                    theme.textTheme.headlineMedium?.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                      height: 1.2,
                                      letterSpacing: -0.5,
                                    ) ??
                                    TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                      height: 1.2,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                width: 44,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 460,
                                ),
                                child: Text(
                                  strings.description,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: const Color(0xFF334155),
                                    height: 1.6,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _InfoBox(
                                text: strings.secondary,
                                colorScheme: colorScheme,
                                theme: theme,
                              ),
                              const SizedBox(height: 36),
                              Divider(
                                color: colorScheme.outlineVariant.withAlpha(6),
                                thickness: 1,
                                height: 1,
                              ),
                              const SizedBox(height: 28),
                              _HelperTip(
                                title: strings.helperTitle,
                                body: strings.helperBody,
                                colorScheme: colorScheme,
                                theme: theme,
                                isRtl: isRtl,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Large monitor icon on a soft circular backdrop, surrounded by a few
/// subtle decorative shapes (dots and plus marks) for visual texture.
class _DecoratedIcon extends StatelessWidget {
  const _DecoratedIcon({required this.colorScheme, required this.icon});

  final ColorScheme colorScheme;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 108,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 4,
            top: 4,
            child: _Dot(color: colorScheme.primary.withAlpha(22), size: 8),
          ),
          Positioned(
            right: 2,
            top: 14,
            child: _Plus(color: colorScheme.primary.withAlpha(28), size: 12),
          ),
          Positioned(
            right: 10,
            bottom: 6,
            child: _Dot(color: colorScheme.primary.withAlpha(18), size: 6),
          ),
          Positioned(
            left: 12,
            bottom: 2,
            child: _Plus(color: colorScheme.primary.withAlpha(18), size: 10),
          ),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 34, color: colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Plus extends StatelessWidget {
  const _Plus({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final thickness = size / 5;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: thickness,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(thickness),
            ),
          ),
          Container(
            width: thickness,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(thickness),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern info-alert style box replacing the plain secondary text line.
class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.text,
    required this.colorScheme,
    required this.theme,
  });

  final String text;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withAlpha(06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.primary.withAlpha(18), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.start,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom helper section styled as a friendly tip: an icon on one side and
/// a bold headline plus supporting body copy on the other.
class _HelperTip extends StatelessWidget {
  const _HelperTip({
    required this.title,
    required this.body,
    required this.colorScheme,
    required this.theme,
    required this.isRtl,
  });

  final String title;
  final String body;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final bool isRtl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lightbulb_outline_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                textAlign: TextAlign.start,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF475569),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopRequiredStrings {
  const _DesktopRequiredStrings({
    required this.title,
    required this.description,
    required this.secondary,
    required this.helperTitle,
    required this.helperBody,
  });

  final String title;
  final String description;
  final String secondary;
  final String helperTitle;
  final String helperBody;
}
