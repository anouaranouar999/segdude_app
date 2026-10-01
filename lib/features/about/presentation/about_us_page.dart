import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

// ── UI Tokens (mirrors home_page.dart design system — unchanged) ───────────
const _pageBg = Color(0xFFF4F7FB);
const _primaryBlue = Color(0xFF2A6FDB);
const _darkNavy = Color(0xFF1A2E4A);
const _mutedText = Color(0xFF5A6A85);
const _cardBg = Colors.white;
const _cardBorder = Color(0xFFDDE3EC);
const _chipBg = Color(0xFFE8F0FE);
const _chipBorder = Color(0xFFADC8FF);

// ── Social links (project owner request) ────────────────────────────────────
const _youtubeUrl = 'https://www.youtube.com/@seg-dude26';
const _instagramUrl =
    'https://www.instagram.com/seg_dude?igsh=MWZvOWk1OTkya2FnMw==';

// ── Shared layout constants ─────────────────────────────────────────────────
const double _sectionVPadding = 88;
const double _sectionVPaddingMobile = 56;
const double _appBarFadeDistance = 140;

double _hPad(double width) {
  if (width >= 900) return 80;
  if (width >= 600) return 40;
  return 24;
}

// ─────────────────────────────────────────────────────────────────────────────
// AboutUsPage — Static informational page describing Seg-Dude, its mission,
// current features, roadmap, values, and social channels. Content and section
// order are unchanged; this pass focuses purely on polish: stronger hero
// branding, better icon/title alignment in Mission & Vision, matched-quality
// social cards with real platform icons, and tighter, more consistent
// spacing — all reusing the app's existing color palette, card language,
// gradients, and animation style.
// ─────────────────────────────────────────────────────────────────────────────
class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with TickerProviderStateMixin {
  late final AnimationController _revealController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  final ValueNotifier<double> _appBarProgress = ValueNotifier(0);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(() {
      final progress = (_scrollController.offset / _appBarFadeDistance).clamp(
        0.0,
        1.0,
      );
      if (progress != _appBarProgress.value) {
        _appBarProgress.value = progress;
      }
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    _appBarProgress.dispose();
    super.dispose();
  }

  Widget _reveal(int index, Widget child) {
    final start = (index * 0.1).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _revealController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _pageBg,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Material(
                color: Colors.white.withValues(alpha: 0.1),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  onPressed: () => context.go('/'),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _primaryBlue,
                  ),
                  tooltip: l10n.aboutHomeTooltip,
                ),
              ),
            ),
            title: ValueListenableBuilder<double>(
              valueListenable: _appBarProgress,
              builder: (context, value, child) =>
                  Opacity(opacity: value, child: child),
              child: Text(
                l10n.aboutAppBarTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            flexibleSpace: ValueListenableBuilder<double>(
              valueListenable: _appBarProgress,
              builder: (context, value, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: _darkNavy.withValues(alpha: value),
                    boxShadow: value > 0.98
                        ? const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                );
              },
            ),
          ),

          SliverToBoxAdapter(
            child: _AboutHeroSection(pulseAnimation: _pulseAnimation),
          ),
          SliverToBoxAdapter(child: _reveal(0, const _WhoWeAreSection())),
          SliverToBoxAdapter(child: _reveal(1, const _MissionSection())),
          SliverToBoxAdapter(child: _reveal(2, const _WhatWeOfferSection())),
          SliverToBoxAdapter(child: _reveal(3, const _ComingSoonSection())),
          const SliverToBoxAdapter(child: _VisionSection()),
          SliverToBoxAdapter(child: _reveal(4, const _ValuesSection())),
          SliverToBoxAdapter(child: _reveal(5, const _FollowUsSection())),
          SliverToBoxAdapter(child: _reveal(6, const _ContactUsSection())),
          const SliverToBoxAdapter(child: _AboutFooter()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section — logo now carries real visual weight. On desktop the title
// and subtitle sit left, with a large logo (with a soft glow) anchoring the
// right side. On mobile the logo leads, larger than before, above the text.
// ─────────────────────────────────────────────────────────────────────────────
class _AboutHeroSection extends StatelessWidget {
  const _AboutHeroSection({required this.pulseAnimation});
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2E4A), Color(0xFF2A4A7F), Color(0xFF2A6FDB)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -70,
            child: _DecorativeCircle(size: 300, opacity: 0.07),
          ),
          Positioned(
            bottom: -90,
            left: -50,
            child: _DecorativeCircle(size: 340, opacity: 0.05),
          ),
          Positioned(
            bottom: 60,
            left: isWide ? 90 : 20,
            child: _DecorativeCircle(size: 44, opacity: 0.1),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              _hPad(width),
              isWide ? 48 : 32,
              _hPad(width),
              isWide ? 72 : 60,
            ),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _HeroText(
                          isWide: isWide,
                          pulseAnimation: pulseAnimation,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        flex: 5,
                        child: Center(child: _HeroLogo(size: 260)),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const _HeroLogo(size: 148),
                      const SizedBox(height: 28),
                      _HeroText(
                        isWide: isWide,
                        pulseAnimation: pulseAnimation,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _cardBg.withValues(alpha: 0.9)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large, prominent brand mark with a soft glow behind it — the strongest
/// visual anchor of the hero, as requested.
class _HeroLogo extends StatelessWidget {
  const _HeroLogo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft glow behind the mark.
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(size * 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            padding: EdgeInsets.all(size * 0.12),
            child: Image.asset(
              'images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: size * 0.38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({
    required this.isWide,
    required this.pulseAnimation,
    required this.crossAxisAlignment,
    required this.textAlign,
  });

  final bool isWide;
  final Animation<double> pulseAnimation;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Text(
            l10n.aboutHeroChip,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          l10n.aboutHeroTitle,
          textAlign: textAlign,
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 46 : 32,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 420 : 560),
          child: Text(
            l10n.aboutHeroSubtitle,
            textAlign: textAlign,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 17,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 48),
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, pulseAnimation.value),
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Text(
                l10n.aboutScrollToExplore,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white.withValues(alpha: 0.6),
                size: 22,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section header: eyebrow chip + title (+ optional accent underline)
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.chipLabel,
    required this.title,
    this.icon,
    this.subtitle,
  });

  final String chipLabel;
  final String title;
  final IconData? icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _chipBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _chipBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13, color: _primaryBlue),
                const SizedBox(width: 6),
              ],
              Text(
                chipLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _primaryBlue,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _darkNavy,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: 44,
          height: 4,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primaryBlue, Color(0xFF1A4A9F)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                color: _mutedText,
                height: 1.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Who We Are Section
// ─────────────────────────────────────────────────────────────────────────────
class _WhoWeAreSection extends StatelessWidget {
  const _WhoWeAreSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      color: _cardBg,
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(width),
        vertical: isWide ? _sectionVPadding : _sectionVPaddingMobile,
      ),
      child: Column(
        children: [
          _SectionHeader(
            chipLabel: l10n.aboutWhoWeAreChip,
            title: l10n.aboutWhoWeAreTitle,
            icon: Icons.groups_2_rounded,
          ),
          const SizedBox(height: 28),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Text(
              l10n.aboutWhoWeAreDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15.5,
                color: _mutedText,
                height: 1.75,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Our Mission Section — icon sits beside the title on wide screens, with the
// paragraph flowing naturally underneath, instead of a centered icon
// floating above a text block.
// ─────────────────────────────────────────────────────────────────────────────
class _MissionSection extends StatelessWidget {
  const _MissionSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final isRowLayout = width >= 680;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      color: _pageBg,
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(width),
        vertical: isWide ? _sectionVPadding : _sectionVPaddingMobile,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 48 : 28,
              vertical: isWide ? 44 : 32,
            ),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _cardBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F1A2E4A),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: isRowLayout
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _MissionIcon(),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.aboutOurMissionTitle,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: _darkNavy,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.aboutOurMissionDescription,
                              style: const TextStyle(
                                fontSize: 15.5,
                                color: _mutedText,
                                height: 1.75,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      const _MissionIcon(),
                      const SizedBox(height: 22),
                      Text(
                        l10n.aboutOurMissionTitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _darkNavy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.aboutOurMissionDescription,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15.5,
                          color: _mutedText,
                          height: 1.75,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _MissionIcon extends StatelessWidget {
  const _MissionIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A6FDB), Color(0xFF1A4A9F)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332A6FDB),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.flag_rounded, color: Colors.white, size: 28),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// What We Offer Section
// ─────────────────────────────────────────────────────────────────────────────
class _WhatWeOfferSection extends StatelessWidget {
  const _WhatWeOfferSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final isTablet = width >= 600 && width < 900;
    final l10n = AppLocalizations.of(context)!;

    final items = [
      _IconTextItem(
        icon: Icons.people_alt_rounded,
        iconColor: _primaryBlue,
        title: l10n.aboutFeatureTeacherManagementTitle,
        description: l10n.aboutFeatureTeacherManagementDesc,
      ),
      _IconTextItem(
        icon: Icons.calendar_month_rounded,
        iconColor: Color(0xFFFFB300),
        title: l10n.aboutFeatureClassSchedulingTitle,
        description: l10n.aboutFeatureClassSchedulingDesc,
      ),
      _IconTextItem(
        icon: Icons.auto_awesome_rounded,
        iconColor: Color(0xFF8B5CF6),
        title: l10n.aboutFeatureSimpleInterfaceTitle,
        description: l10n.aboutFeatureSimpleInterfaceDesc,
      ),
      _IconTextItem(
        icon: Icons.speed_rounded,
        iconColor: Color(0xFFE53935),
        title: l10n.aboutFeatureFastWorkflowTitle,
        description: l10n.aboutFeatureFastWorkflowDesc,
      ),
    ];

    final columns = isWide ? 4 : (isTablet ? 2 : 1);
    const spacing = 20.0;
    final cardWidth =
        (width - (_hPad(width) * 2) - (spacing * (columns - 1))) / columns;

    return Container(
      width: double.infinity,
      color: _cardBg,
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(width),
        vertical: isWide ? _sectionVPadding : _sectionVPaddingMobile,
      ),
      child: Column(
        children: [
          _SectionHeader(
            chipLabel: l10n.aboutWhatWeOfferChip,
            title: l10n.aboutWhatWeOfferTitle,
            icon: Icons.widgets_rounded,
          ),
          const SizedBox(height: 44),
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: items
                .map(
                  (item) => SizedBox(
                    width: cardWidth,
                    child: _FeatureLikeCard(item: item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _IconTextItem {
  _IconTextItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
  IconData icon;
  final Color iconColor;
  final String title;
  final String description;
}

class _FeatureLikeCard extends StatefulWidget {
  const _FeatureLikeCard({required this.item});
  final _IconTextItem item;

  @override
  State<_FeatureLikeCard> createState() => _FeatureLikeCardState();
}

class _FeatureLikeCardState extends State<_FeatureLikeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minHeight: 190),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFF0F6FF) : _cardBg,
          border: Border.all(
            color: _hovered ? _primaryBlue.withValues(alpha: 0.4) : _cardBorder,
            width: _hovered ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? _primaryBlue.withValues(alpha: 0.12)
                  : const Color(0x0A1A2E4A),
              blurRadius: _hovered ? 22 : 10,
              offset: Offset(0, _hovered ? 10 : 6),
            ),
          ],
        ),
        transform: _hovered
            ? (Matrix4.identity()..translateByDouble(0.0, -3.0, 0, 0))
            : Matrix4.identity(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: widget.item.iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                widget.item.icon,
                color: widget.item.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              widget.item.title,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: _darkNavy,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.description,
              style: const TextStyle(
                fontSize: 13,
                color: _mutedText,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coming Soon Section
// ─────────────────────────────────────────────────────────────────────────────
class _ComingSoonSection extends StatelessWidget {
  const _ComingSoonSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final isTablet = width >= 600 && width < 900;
    final l10n = AppLocalizations.of(context)!;

    final items = [
      _IconTextItem(
        icon: Icons.groups_rounded,
        iconColor: _primaryBlue,
        title: l10n.aboutComingSoonStudentManagementTitle,
        description: l10n.aboutComingSoonStudentManagementDesc,
      ),
      _IconTextItem(
        icon: Icons.fact_check_rounded,
        iconColor: Color(0xFF16A34A),
        title: l10n.aboutComingSoonAttendanceTitle,
        description: l10n.aboutComingSoonAttendanceDesc,
      ),
      _IconTextItem(
        icon: Icons.grade_rounded,
        iconColor: Color(0xFFFFB300),
        title: l10n.aboutComingSoonGradeManagementTitle,
        description: l10n.aboutComingSoonGradeManagementDesc,
      ),
      _IconTextItem(
        icon: Icons.family_restroom_rounded,
        iconColor: Color(0xFF8B5CF6),
        title: l10n.aboutComingSoonParentPortalTitle,
        description: l10n.aboutComingSoonParentPortalDesc,
      ),
      _IconTextItem(
        icon: Icons.notifications_active_rounded,
        iconColor: Color(0xFFE53935),
        title: l10n.aboutComingSoonNotificationsTitle,
        description: l10n.aboutComingSoonNotificationsDesc,
      ),
      _IconTextItem(
        icon: Icons.auto_fix_high_rounded,
        iconColor: Color(0xFF2A6FDB),
        title: l10n.aboutComingSoonAiToolsTitle,
        description: l10n.aboutComingSoonAiToolsDesc,
      ),
    ];

    final columns = isWide ? 3 : (isTablet ? 2 : 1);
    const spacing = 20.0;
    final cardWidth =
        (width - (_hPad(width) * 2) - (spacing * (columns - 1))) / columns;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_pageBg, Color(0xFFEDF2FC)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(width),
        vertical: isWide ? _sectionVPadding : _sectionVPaddingMobile,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_primaryBlue, Color(0xFF1A4A9F)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x332A6FDB),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.rocket_launch_rounded,
                  size: 13,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.aboutComingSoonChip,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.aboutWhatsNextTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _darkNavy,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              l10n.aboutComingSoonIntro,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                color: _mutedText,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 44),
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: items
                .map(
                  (item) => SizedBox(
                    width: cardWidth,
                    child: _ComingSoonCard(item: item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 44),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              l10n.aboutComingSoonFooter,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: _mutedText,
                height: 1.7,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComingSoonCard extends StatefulWidget {
  const _ComingSoonCard({required this.item});
  final _IconTextItem item;

  @override
  State<_ComingSoonCard> createState() => _ComingSoonCardState();
}

class _ComingSoonCardState extends State<_ComingSoonCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.item.iconColor;
    final l10n = AppLocalizations.of(context)!;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minHeight: 176),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? color.withValues(alpha: 0.45) : _cardBorder,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? color.withValues(alpha: 0.16)
                  : const Color(0x0A1A2E4A),
              blurRadius: _hovered ? 22 : 10,
              offset: Offset(0, _hovered ? 10 : 6),
            ),
          ],
        ),
        transform: _hovered
            ? (Matrix4.identity()..translateByDouble(0.0, -3.0, 0, 0))
            : Matrix4.identity(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.item.icon, color: color, size: 22),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _chipBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _chipBorder),
                        ),
                        child: Text(
                          l10n.aboutSoonBadge,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: _primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _darkNavy,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: _mutedText,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Our Vision Section — icon sits beside the title on wide screens, matching
// the Mission section's row-based composition, with the paragraph flowing
// underneath rather than a single icon centered above the text block.
// ─────────────────────────────────────────────────────────────────────────────
class _VisionSection extends StatelessWidget {
  const _VisionSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final isRowLayout = width >= 680;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A4A7F), Color(0xFF1A2E4A)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _hPad(width),
              vertical: isWide ? _sectionVPadding : _sectionVPaddingMobile,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: isRowLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _VisionIcon(),
                          const SizedBox(width: 28),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.aboutOurVisionTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  l10n.aboutOurVisionDescription,
                                  style: const TextStyle(
                                    color: Color(0xD9FFFFFF),
                                    fontSize: 15.5,
                                    height: 1.75,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const _VisionIcon(),
                          const SizedBox(height: 22),
                          Text(
                            l10n.aboutOurVisionTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            l10n.aboutOurVisionDescription,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xD9FFFFFF),
                              fontSize: 15.5,
                              height: 1.75,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisionIcon extends StatelessWidget {
  const _VisionIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: const Icon(
        Icons.visibility_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Our Values Section
// ─────────────────────────────────────────────────────────────────────────────
class _ValuesSection extends StatelessWidget {
  const _ValuesSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final isTablet = width >= 600 && width < 900;
    final l10n = AppLocalizations.of(context)!;

    final items = [
      _IconTextItem(
        icon: Icons.lightbulb_rounded,
        iconColor: Color(0xFFFFB300),
        title: l10n.aboutValueInnovationTitle,
        description: l10n.aboutValueInnovationDesc,
      ),
      _IconTextItem(
        icon: Icons.filter_center_focus_rounded,
        iconColor: _primaryBlue,
        title: l10n.aboutValueSimplicityTitle,
        description: l10n.aboutValueSimplicityDesc,
      ),
      _IconTextItem(
        icon: Icons.verified_rounded,
        iconColor: Color(0xFF16A34A),
        title: l10n.aboutValueReliabilityTitle,
        description: l10n.aboutValueReliabilityDesc,
      ),
      _IconTextItem(
        icon: Icons.shield_rounded,
        iconColor: Color(0xFF8B5CF6),
        title: l10n.aboutValueSecurityTitle,
        description: l10n.aboutValueSecurityDesc,
      ),
    ];

    final columns = isWide ? 4 : (isTablet ? 2 : 1);
    const spacing = 20.0;
    final cardWidth =
        (width - (_hPad(width) * 2) - (spacing * (columns - 1))) / columns;

    return Container(
      width: double.infinity,
      color: _cardBg,
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(width),
        vertical: isWide ? _sectionVPadding : _sectionVPaddingMobile,
      ),
      child: Column(
        children: [
          _SectionHeader(
            chipLabel: l10n.aboutOurValuesChip,
            title: l10n.aboutOurValuesTitle,
            icon: Icons.diamond_rounded,
          ),
          const SizedBox(height: 44),
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: items
                .map(
                  (item) => SizedBox(
                    width: cardWidth,
                    child: _ValueCard(item: item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatefulWidget {
  const _ValueCard({required this.item});
  final _IconTextItem item;

  @override
  State<_ValueCard> createState() => _ValueCardState();
}

class _ValueCardState extends State<_ValueCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.item.iconColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minHeight: 232),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFFAFCFF) : _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered ? color.withValues(alpha: 0.35) : _cardBorder,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? color.withValues(alpha: 0.14)
                  : const Color(0x0A1A2E4A),
              blurRadius: _hovered ? 24 : 10,
              offset: Offset(0, _hovered ? 12 : 6),
            ),
          ],
        ),
        transform: _hovered
            ? (Matrix4.identity()..translateByDouble(0.0, -4.0, 0.0, 0.0))
            : Matrix4.identity(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.item.icon, color: color, size: 30),
            ),
            const SizedBox(height: 20),
            Text(
              widget.item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _darkNavy,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 28,
              height: 3,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.item.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: _mutedText,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Follow Us / Connect With Us Section — real platform brand icons (FontAwesome)
// for instant recognition. Both cards share identical layout, spacing, sizing,
// and typography; only the icon tile treatment differs to reflect each
// platform's own branding.
// ─────────────────────────────────────────────────────────────────────────────
class _FollowUsSection extends StatelessWidget {
  const _FollowUsSection();

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final isTablet = width >= 600 && width < 900;
    final isMultiColumn = isWide || isTablet;
    final l10n = AppLocalizations.of(context)!;

    final cards = [
      _SocialLinkCard(
        iconTile: _BrandIconTile(
          faIcon: FontAwesomeIcons.youtube,
          background: Color(0xFFE53935),
        ),
        accentColor: const Color(0xFFE53935),
        platform: l10n.aboutYouTubePlatform,
        actionLabel: l10n.aboutYouTubeActionLabel,
        description: l10n.aboutYouTubeDescription,
        onTap: () => _openLink(_youtubeUrl),
      ),
      _SocialLinkCard(
        iconTile: _BrandIconTile(
          faIcon: FontAwesomeIcons.instagram,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFDC80),
              Color(0xFFFA7E1E),
              Color(0xFFD62976),
              Color(0xFF962FBF),
              Color(0xFF4F5BD5),
            ],
          ),
        ),
        accentColor: const Color(0xFFD62976),
        platform: l10n.aboutInstagramPlatform,
        actionLabel: l10n.aboutInstagramActionLabel,
        description: l10n.aboutInstagramDescription,
        onTap: () => _openLink(_instagramUrl),
      ),
    ];

    return Container(
      width: double.infinity,
      color: _pageBg,
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(width),
        vertical: isWide ? _sectionVPadding : _sectionVPaddingMobile,
      ),
      child: Column(
        children: [
          _SectionHeader(
            chipLabel: l10n.aboutStayConnectedChip,
            title: l10n.aboutConnectWithUsTitle,
            icon: Icons.favorite_rounded,
            subtitle: l10n.aboutConnectWithUsSubtitle,
          ),
          const SizedBox(height: 44),
          if (isMultiColumn)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 20),
                  Expanded(child: cards[1]),
                ],
              ),
            )
          else
            Column(children: [cards[0], const SizedBox(height: 20), cards[1]]),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact Us Section
// ─────────────────────────────────────────────────────────────────────────────
class _ContactUsSection extends StatelessWidget {
  const _ContactUsSection();

  Future<void> _openEmail() async {
    final uri = Uri.parse('mailto:abdoullouahd@gmail.com');
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      color: _cardBg,
      padding: EdgeInsets.symmetric(
        horizontal: _hPad(width),
        vertical: isWide ? _sectionVPadding : _sectionVPaddingMobile,
      ),
      child: Column(
        children: [
          _SectionHeader(
            chipLabel: l10n.supportTitle,
            title: l10n.supportTitle,
            icon: Icons.email_rounded,
            subtitle: l10n.supportSubtitle,
          ),
          const SizedBox(height: 44),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _SocialLinkCard(
                iconTile: _BrandIconTile(
                  icon: Icons.mail_rounded,
                  background: _primaryBlue,
                ),
                accentColor: _primaryBlue,
                platform: l10n.emailUs,
                actionLabel: 'abdoullouahd@gmail.com',
                description: l10n.sendUsEmailMessage,
                onTap: _openEmail,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A consistently-sized icon tile (56x56, 15 radius) that can be filled with
/// either a flat brand color or a brand gradient, keeping both social cards
/// at identical visual weight while honoring each platform's own identity.
///
/// Accepts either a Flutter [IconData] via [icon] or a Font Awesome
/// [FaIconData] via [faIcon]. Exactly one must be provided.
class _BrandIconTile extends StatelessWidget {
  const _BrandIconTile({this.icon, this.faIcon, this.background, this.gradient})
    : assert(background != null || gradient != null),
      assert(
        (icon != null) != (faIcon != null),
        'Provide exactly one of icon or faIcon',
      );

  final IconData? icon;
  final FaIconData? faIcon;
  final Color? background;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final iconColor = gradient != null ? Colors.white : background;
    return Container(
      alignment: Alignment.center,
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: background?.withAlpha(12),
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
      ),
      child: faIcon != null
          ? FaIcon(faIcon, color: iconColor, size: 35)
          : Icon(icon, color: iconColor, size: 35),
    );
  }
}

class _SocialLinkCard extends StatefulWidget {
  const _SocialLinkCard({
    required this.iconTile,
    required this.accentColor,
    required this.platform,
    required this.actionLabel,
    required this.description,
    required this.onTap,
  });

  final Widget iconTile;
  final Color accentColor;
  final String platform;
  final String actionLabel;
  final String description;
  final VoidCallback onTap;

  @override
  State<_SocialLinkCard> createState() => _SocialLinkCardState();
}

class _SocialLinkCardState extends State<_SocialLinkCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minHeight: 200),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered ? color.withValues(alpha: 0.4) : _cardBorder,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _hovered
                  ? color.withValues(alpha: 0.16)
                  : const Color(0x0A1A2E4A),
              blurRadius: _hovered ? 26 : 12,
              offset: Offset(0, _hovered ? 12 : 6),
            ),
          ],
        ),
        transform: _hovered
            ? (Matrix4.identity()..translateByDouble(0.0, -4.0, 0, 0))
            : Matrix4.identity(),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            splashColor: color.withValues(alpha: 0.08),
            highlightColor: color.withValues(alpha: 0.04),
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.iconTile,
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.platform,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _darkNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _mutedText,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              widget.actionLabel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_outward_rounded,
                              size: 15,
                              color: color,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────────────────────
class _AboutFooter extends StatelessWidget {
  const _AboutFooter();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      color: _darkNavy,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 24, vertical: 24),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.aboutCopyright,
                  style: const TextStyle(
                    color: Color(0xFF5A6A85),
                    fontSize: 13,
                  ),
                ),
                _FooterBackLink(onTap: () => context.go('/')),
              ],
            )
          : Column(
              children: [
                Text(
                  l10n.aboutCopyright,
                  style: const TextStyle(
                    color: Color(0xFF5A6A85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                _FooterBackLink(onTap: () => context.go('/')),
              ],
            ),
    );
  }
}

class _FooterBackLink extends StatefulWidget {
  const _FooterBackLink({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_FooterBackLink> createState() => _FooterBackLinkState();
}

class _FooterBackLinkState extends State<_FooterBackLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            color: _hovered ? Colors.white : const Color(0xFF5A6A85),
            fontSize: 13,
          ),
          child: Text(l10n.aboutBackToHome),
        ),
      ),
    );
  }
}
