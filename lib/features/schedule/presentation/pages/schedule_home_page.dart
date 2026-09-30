import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/features/schedule/data/load_saved_data.dart';
import 'package:segdude_app/core/providers/locale_provider.dart';
import 'package:segdude_app/core/providers/shared_prefs_provider.dart';
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/auth/providers/auth_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';
import 'package:segdude_app/shared/widgets/app_confirmation_dialog.dart';
import 'package:segdude_app/shared/widgets/navigation_guard.dart';

// ── UI Tokens ────────────────────────────────────────────────────────────────
const _pageBg = Color(0xFFF4F7FB);
const _primaryBlue = Color(0xFF2A6FDB);
const _darkNavy = Color(0xFF1A2E4A);
const _sectionHeader = Color(0xFF2A4A7F);
const _mutedText = Color(0xFF5A6A85);
const _cardBg = Colors.white;
const _cardBorder = Color(0xFFDDE3EC);
const _chipBg = Color(0xFFE8F0FE);
const _chipBorder = Color(0xFFADC8FF);

// ─────────────────────────────────────────────────────────────────────────────
// HomePage — Landing page that presents the app and prompts the user to start
// creating a schedule.
//
// Uses ConsumerStatefulWidget so animations are properly disposed.
// ─────────────────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

bool _hasCheckedStartupSchedule = false;

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // ── Animation controller for the hero CTA button pulse ───────────────────
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Subtle repeating scale pulse on the CTA button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (!_hasCheckedStartupSchedule) {
      _hasCheckedStartupSchedule = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkStartupSchedule();
      });
    }
  }

  Future<void> _checkStartupSchedule() async {
    final prefsService = SharedPreferencesService();
    final scheduleJson = await prefsService.getString(
      'last_generated_schedule',
    );
    if (scheduleJson != null &&
        scheduleJson.isNotEmpty &&
        scheduleJson != 'null') {
      // Only auto-navigate away from the Home Page on supported widths.
      // On narrow screens the Home Page must stay accessible; the user
      // can still load the saved schedule manually via the CTA, which is
      // guarded by NavigationGuard.
      if (mounted && NavigationGuard.isSupportedWidth(context)) {
        await loadSavedScheduleAndNavigate(context, prefsService);
      }
    }
  }

  @override
  void dispose() {
    // Properly release the animation controller to avoid memory leaks
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: _pageBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Hero Section ─────────────────────────────────────────────────
            _HeroSection(isWide: isWide, pulseAnimation: _pulseAnimation),

            // ── Features Strip ───────────────────────────────────────────────
            const _FeaturesSection(),

            // ── How It Works ─────────────────────────────────────────────────
            const _HowItWorksSection(),

            // ── Bottom CTA Banner ────────────────────────────────────────────
            _BottomCtaBanner(pulseAnimation: _pulseAnimation),

            // ── Footer ───────────────────────────────────────────────────────
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────
class _HeroSection extends ConsumerWidget {
  const _HeroSection({required this.isWide, required this.pulseAnimation});

  final bool isWide;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.read(sharedPrefsProvider);
    final user = ref.watch(userProvider);
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        // Clean light gradient matching the app's overall aesthetics
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF3FA), Color(0xFFE6ECF9)],
        ),
      ),
      child: Stack(
        children: [
          // ── Decorative background circles ────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: _DecorativeCircle(size: 280, opacity: 0.05),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: _DecorativeCircle(size: 320, opacity: 0.04),
          ),
          Positioned(
            top: 80,
            right: 200,
            child: _DecorativeCircle(size: 80, opacity: 0.06),
          ),
          // ── Content ──────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 40 : 24,
              vertical: isWide ? 40 : 56,
            ),
            child: isWide
                ? _HeroWideLayout(pulseAnimation: pulseAnimation)
                : _HeroNarrowLayout(pulseAnimation: pulseAnimation),
          ),
          // ── Language selector & User Account ─────────────────────────────
          Positioned(
            top: 20,
            right: ref.watch(localeProvider).languageCode == 'ar' ? null : 20,
            left: ref.watch(localeProvider).languageCode == 'ar' ? 20 : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── User Sign in or Profile Menu (Refreshes on Auth changes) ──
                user == null
                    ? TextButton(
                        onPressed: () => context.go('/login?from=/'),
                        child: Text(
                          l10n?.signIn ?? 'Sign in',
                          style: const TextStyle(
                            color: _primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : PopupMenuButton<String>(
                        tooltip: user.email,
                        offset: const Offset(0, 38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: _cardBorder),
                        ),
                        onSelected: (action) async {
                          if (action == 'profile') {
                            context.push('/profile');
                          } else if (action == 'logout') {
                            final loc = AppLocalizations.of(context)!;
                            final confirmed = await AppConfirmationDialog.show(
                              context,
                              title: loc.confirmLogoutTitle,
                              message: loc.confirmLogoutMessage,
                              cancelLabel: loc.cancel,
                              confirmLabel: loc.logout,
                              icon: Icons.logout_rounded,
                              confirmButtonColor: Colors.red,
                            );
                            if (!confirmed) return;
                            await ref.read(authRepositoryProvider).signOut();
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem<String>(
                            enabled: false,
                            child: Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _mutedText,
                              ),
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'profile',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  size: 18,
                                  color: _darkNavy,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n?.profile ?? 'Profile',
                                  style: const TextStyle(
                                    color: _darkNavy,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'logout',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.logout,
                                  size: 18,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n?.logout ?? 'Logout',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _cardBorder),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x08000000),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.account_circle,
                                color: _primaryBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 140,
                                ),
                                child: Text(
                                  (user.name != null && user.name!.isNotEmpty)
                                      ? user.name!
                                      : (user.email.isNotEmpty
                                            ? user.email.split('@').first
                                            : 'User'),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _darkNavy,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: _mutedText,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.language, color: _primaryBlue),
                  onSelected: (sel) {
                    prefs.saveString('locale', sel);
                    ref.read(localeProvider.notifier).setLocale(Locale(sel));
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem<String>(
                      value: 'ar',
                      child: Text('العربية'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'en',
                      child: Text('English'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'fr',
                      child: Text('français'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wide (desktop/tablet) hero layout: text on left, schedule preview on right
class _HeroWideLayout extends StatelessWidget {
  const _HeroWideLayout({required this.pulseAnimation});
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left — headline + CTA
        Expanded(flex: 5, child: _HeroText(pulseAnimation: pulseAnimation)),
        const SizedBox(width: 60),
        // Right — mini schedule card preview. Whichever side this lands
        // on (it swaps with the language/account controls under RTL,
        // since both follow the same Row-reordering / isArabic logic),
        // the extra top clearance keeps it from sitting under the
        // absolutely-positioned language/account row above it. The
        // offset is constant because that row's height doesn't change
        // with viewport width, so this stays correct at every width
        // that uses this layout.
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(top: 44),
            child: _SchedulePreviewCard(),
          ),
        ),
      ],
    );
  }
}

/// Narrow (mobile) hero layout: text stacked above preview
class _HeroNarrowLayout extends StatelessWidget {
  const _HeroNarrowLayout({required this.pulseAnimation});
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _HeroText(pulseAnimation: pulseAnimation),
        const SizedBox(height: 40),
        _SchedulePreviewCard(),
      ],
    );
  }
}

/// Headline, subtitle, and CTA button for the hero
class _HeroText extends ConsumerWidget {
  _HeroText({required this.pulseAnimation});
  final Animation<double> pulseAnimation;
  final prefsService = SharedPreferencesService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main headline ───────────────────────────────────────────────────
        Text(
          l10n.homeHeroTitle,
          style: const TextStyle(
            color: _darkNavy,
            fontSize: 46,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 20),

        // ── Subtitle ────────────────────────────────────────────────────────
        Text(
          l10n.homeHeroSubtitle,
          style: const TextStyle(color: _mutedText, fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 20),

        // ── Institutional Notice ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _primaryBlue.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: _primaryBlue,
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  l10n.homeInstitutionNotice,
                  style: const TextStyle(
                    color: _primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // --------------------------------------------------------------- CTA Button
        ScaleTransition(
          scale: pulseAnimation,
          child: BigAddButton(
            label: l10n.homeCtaButton,
            l10n.clickToCreateNewSchedule,

            // icon: Icons.add_circle_outline_rounded,
            // isDarkBackground: false,
            onPressed: () {
              context.go('/create?from=/');
            },
          ),
        ),

        const SizedBox(height: 16),

        // ── Social proof strip ───────────────────────────────────────────────
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
            const SizedBox(width: 6),
            Text(
              l10n.homeSocialProof,
              style: const TextStyle(color: _mutedText, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

/// --------------------------------------------Big Add Button used in the home page to add clients to the database
class BigAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final String? subtitle;
  const BigAddButton(
    this.subtitle, {
    super.key,
    required this.onPressed,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 60,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        gradient: LinearGradient(
          colors: [Colors.pinkAccent, Colors.deepOrangeAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 20, 20, 20),
            blurRadius: 5.0, // soften the shadow
            spreadRadius: 1.0, //extend the shadow
            offset: Offset(
              2.0, // Move to right 5  horizontally
              2.0, // Move to bottom 5 Vertically
            ),
          ),
        ],
      ),

      child: MaterialButton(
        onPressed: onPressed,
        color: Colors.transparent,
        hoverColor: const Color.fromARGB(22, 0, 0, 0),
        splashColor: const Color.fromARGB(255, 248, 213, 108),
        child: ListTile(
          titleAlignment: .center,
          mouseCursor: SystemMouseCursors.click,
          leading: const Icon(
            Icons.add_circle_outline_rounded,
            color: Colors.white,
            size: 30,
          ),
          title: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              overflow: .ellipsis,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle ?? '',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              overflow: .ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

/// CTA button reused in hero and bottom banner
class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black38,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Mini schedule table card shown in the hero
class _SchedulePreviewCard extends StatelessWidget {
  // Sample data just to give a visual impression
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  static const _slots = [
    ['Math', 'informatique', 'History', 'Biology', 'ⵜⴰⵥⵓⵔⵉ'],
    ['', '—', 'Chemistry', 'الرياضيات', 'Physics'],
    ['Geography', 'English', 'Math', 'Physics', 'Chemistry'],
    ['علوم', 'Math', 'PE', 'English', '—'],
  ];
  static const _slotColors = [
    Color(0xFFDCEAFF),
    Color(0xFFD5F5E3),
    Color(0xFFFFF3CD),
    Color(0xFFFFDDDD),
    Color(0xFFEDE8FF),
  ];

  const _SchedulePreviewCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Image.asset('images/logo.png', width: 250, height: 250),
        Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF3FB),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: _sectionHeader,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.homeWeeklySchedulePreview,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _sectionHeader,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Day headers
                    Row(
                      children: [
                        const SizedBox(width: 44),
                        ..._days.map(
                          (d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _sectionHeader,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Slot rows
                    ...List.generate(_slots.length, (row) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            // Time label
                            SizedBox(
                              width: 44,
                              child: Text(
                                '${8 + row}:00',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: _mutedText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ..._slots[row].asMap().entries.map(
                              (entry) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  child: AnimatedContainer(
                                    duration: Duration(
                                      milliseconds: 300 + (entry.key * 80),
                                    ),
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: entry.value == '—'
                                          ? const Color(0xFFF4F7FB)
                                          : _slotColors[entry.key %
                                                _slotColors.length],
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _cardBorder.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        entry.value,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: entry.value == '—'
                                              ? _mutedText.withValues(
                                                  alpha: 0.5,
                                                )
                                              : _darkNavy,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    // "Generated in" badge
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Simple decorative filled circle
class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _primaryBlue.withValues(alpha: opacity),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Features Section
// ─────────────────────────────────────────────────────────────────────────────
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    final features = [
      _FeatureItem(
        icon: Icons.bolt_rounded,
        iconColor: const Color(0xFFFFB300),
        title: l10n.homeFeatureInstantGenerationTitle,
        description: l10n.homeFeatureInstantGenerationDesc,
      ),
      _FeatureItem(
        icon: Icons.people_alt_rounded,
        iconColor: _primaryBlue,
        title: l10n.homeFeatureTeacherRoomTitle,
        description: l10n.homeFeatureTeacherRoomDesc,
      ),
      _FeatureItem(
        icon: Icons.tune_rounded,
        iconColor: const Color(0xFF8B5CF6),
        title: l10n.homeFeatureManualOverridesTitle,
        description: l10n.homeFeatureManualOverridesDesc,
      ),
      _FeatureItem(
        icon: Icons.picture_as_pdf_rounded,
        iconColor: const Color(0xFFE53935),
        title: l10n.homeFeatureExportPdfTitle,
        description: l10n.homeFeatureExportPdfDesc,
      ),
    ];

    return Container(
      width: double.infinity,
      color: _cardBg,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 64),
      child: Column(
        children: [
          // Section title
          Text(
            l10n.homeFeaturesTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _darkNavy,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.homeFeaturesSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: _mutedText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          // Feature cards grid
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: features
                .map(
                  (f) => SizedBox(
                    width: isWide
                        ? (width - 160 - 60) / 4
                        : (width >= 600 ? (width - 68) / 2 : width - 48),
                    child: _FeatureCard(feature: f),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.feature});
  final _FeatureItem feature;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFF0F6FF) : _cardBg,
          border: Border.all(
            color: _hovered ? _primaryBlue.withValues(alpha: 0.4) : _cardBorder,
            width: _hovered ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? _primaryBlue.withValues(alpha: 0.1)
                  : const Color(0x0A000000),
              blurRadius: _hovered ? 16 : 6,
              offset: _hovered ? const Offset(0, 4) : const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon in a tinted circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.feature.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.feature.icon,
                color: widget.feature.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.feature.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _darkNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.feature.description,
              style: const TextStyle(
                fontSize: 13,
                color: _mutedText,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// How It Works Section
// ─────────────────────────────────────────────────────────────────────────────
class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width >= 900;

    final steps = [
      _StepItem(
        number: '01',
        title: l10n.homeStep1Title,
        description: l10n.homeStep1Desc,
      ),
      _StepItem(
        number: '02',
        title: l10n.homeStep2Title,
        description: l10n.homeStep2Desc,
      ),
      _StepItem(
        number: '03',
        title: l10n.homeStep3Title,
        description: l10n.homeStep3Desc,
      ),
      _StepItem(
        number: '04',
        title: l10n.homeStep4Title,
        description: l10n.homeStep4Desc,
      ),
    ];

    return Container(
      width: double.infinity,
      color: _pageBg,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24, vertical: 72),
      child: Column(
        children: [
          // Section title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _chipBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _chipBorder),
            ),
            child: Text(
              l10n.homeHowItWorksChip,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _primaryBlue,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.homeHowItWorksTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _darkNavy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 48),
          // Steps
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: steps
                      .asMap()
                      .entries
                      .map(
                        (e) => Expanded(
                          child: _StepCard(
                            step: e.value,
                            isLast: e.key == steps.length - 1,
                          ),
                        ),
                      )
                      .toList(),
                )
              : Column(
                  children: steps
                      .map((s) => _StepCard(step: s, isLast: false))
                      .toList(),
                ),
          const SizedBox(height: 52),

          // ------------------------------------------------------------------ CTA inside "how it works"
          ElevatedButton.icon(
            onPressed: () =>
                NavigationGuard.run(context, () => context.go('/create')),
            icon: const Icon(Icons.rocket_launch_rounded, size: 18),
            label: Text(l10n.homeStartForFree),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem {
  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });
  final String number;
  final String title;
  final String description;
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step, required this.isLast});
  final _StepItem step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, right: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              // Step number circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2A6FDB), Color(0xFF1A4A9F)],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x332A6FDB),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    step.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              // Connector line (only between steps, not after last)
              if (!isLast)
                Container(
                  width: 2,
                  height: 48,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _primaryBlue.withValues(alpha: 0.5),
                        _primaryBlue.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _darkNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    step.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _mutedText,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom CTA Banner
// ─────────────────────────────────────────────────────────────────────────────
class _BottomCtaBanner extends StatelessWidget {
  const _BottomCtaBanner({required this.pulseAnimation});
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEFF3FA), Color(0xFFE6ECF9)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 80 : 24,
              vertical: 64,
            ),
            child: Column(
              children: [
                Text(
                  l10n.homeBottomCtaTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _darkNavy,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.homeBottomCtaSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _darkNavy,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 36),
                ScaleTransition(
                  scale: pulseAnimation,
                  child: _CtaButton(
                    label: l10n.homeBottomCtaButton,
                    icon: Icons.add_circle_outline_rounded,
                    onPressed: () => NavigationGuard.run(
                      context,
                      () => context.go('/create'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────────────────────
class _Footer extends ConsumerWidget {
  const _Footer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      color: const Color(0xFFEEF3FB),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Text(
            l10n.homeCopyright,
            style: const TextStyle(color: _mutedText, fontSize: 13),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 24,
            runSpacing: 8,
            children: [
              _FooterLink(
                label: l10n.createSchedule,
                onTap: () =>
                    NavigationGuard.run(context, () => context.go('/create')),
              ),
              _FooterLink(
                label: l10n.pricing,
                onTap: () => context.push('/pricing'),
              ),
              _FooterLink(
                label: l10n.aboutUs,
                onTap: () => context.push('/about'),
              ),
              if (ref.read(authRepositoryProvider).currentUser == null)
                _FooterLink(
                  // ----------------------- if user is logged in -----------------------
                  label: l10n.signIn,
                  onTap: () => context.go('/login?from=/'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            color: _hovered ? _primaryBlue : _mutedText,
            fontSize: 13,
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
