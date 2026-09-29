import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

class BuyPage extends ConsumerStatefulWidget {
  const BuyPage({super.key});

  @override
  ConsumerState<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends ConsumerState<BuyPage> {
  final bool _isLoading = false;

  void _excuseDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withAlpha(115),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        // Re-fetch localizations from the dialog's own context so it stays
        // correctly localized independent of the page context.
        final dialogL10n = AppLocalizations.of(context)!;
        return _UpgradeExcuseDialog(l10n: dialogL10n, colorScheme: colorScheme);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Helper to translate card text
    String getClassesText(int maxClasses) {
      return l10n.lessThanNClasses(maxClasses);
    }

    String getStudentsText(int approxStudents) {
      return l10n.approxNStudents(approxStudents);
    }

    String getContactText() {
      return l10n.contactUsForAgreement;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(l10n.upgradeToPremium),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.unlockFullPotential,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2E4A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.fullAccessDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF5A6A85),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Responsive grid of 4 license cards using Wrap
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      // Tier 1: 199 MAD
                      _buildPricingCard(
                        context: context,
                        title: l10n.titleSchoolBasic,
                        price: '199 MAD',
                        period: l10n.perEightMonths,
                        features: [
                          getClassesText(25),
                          getStudentsText(1000),
                          l10n.featureRemoveLockedSlots,
                          l10n.featureExportPdf,
                        ],
                        isPromoted: false,
                        buttonText: l10n.upgradeNow,
                        onPressed: _excuseDialog,
                      ),
                      // Tier 2: 299 MAD
                      _buildPricingCard(
                        context: context,
                        title: l10n.titleSchoolStandard,
                        price: '299 MAD',
                        period: l10n.perEightMonths,
                        features: [
                          getClassesText(40),
                          getStudentsText(1600),
                          l10n.featureRemoveLockedSlots,
                          l10n.featureExportPdf,
                          l10n.featureAnyDevice,
                        ],
                        isPromoted: true, // Promoted with a blue gradient
                        badgeText: l10n.badgePopular,
                        buttonText: l10n.upgradeNow,
                        onPressed: _excuseDialog,
                      ),
                      // Tier 3: 499 MAD
                      _buildPricingCard(
                        context: context,
                        title: l10n.titleSchoolPremium,
                        price: '499 MAD',
                        period: l10n.perEightMonths,
                        features: [
                          getClassesText(55),
                          getStudentsText(2200),
                          l10n.featureRemoveLockedSlots,
                          l10n.featureExportPdf,
                          l10n.featureAnyDevice,
                          l10n.featureManualOverrides,
                          l10n.featurePrioritySupport,
                        ],
                        isPromoted: false,
                        buttonText: l10n.upgradeNow,
                        onPressed: _excuseDialog,
                      ),
                      // Tier 4: Contact Us
                      _buildPricingCard(
                        context: context,
                        title: l10n.titleCustomAgreement,
                        price: l10n.priceAgreement,
                        period: '',
                        features: [
                          l10n.featureFlexibleClassCounts,
                          l10n.featureFlexibleStudentCounts,
                          getContactText(),
                          l10n.featurePrioritySupport,
                          l10n.featureExamCorrection,
                          l10n.featureAbsenceManagement,
                          l10n.featureLessonsPlanner,
                        ],
                        isPromoted: false,
                        buttonText: l10n.btnContactUs,
                        onPressed: _excuseDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    child: Text(
                      l10n.maybeLater,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5A6A85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildPricingCard({
    required BuildContext context,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPromoted,
    String? badgeText,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final buttonBgColor = isPromoted ? Colors.white : const Color(0xFF2A6FDB);
    final buttonTextColor = isPromoted ? const Color(0xFF2A6FDB) : Colors.white;

    return Container(
      width: 280,
      height: 480,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: isPromoted ? null : Colors.white,
        gradient: isPromoted
            ? const LinearGradient(
                colors: [Color(0xFF2A6FDB), Color(0xFF1C4C96)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(24),
        border: isPromoted
            ? null
            : Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2E4A).withAlpha(13),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badgeText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ] else
            const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isPromoted
                  ? Colors.white.withAlpha(230)
                  : const Color(0xFF5A6A85),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isPromoted ? Colors.white : const Color(0xFF1A2E4A),
                ),
              ),
              if (period.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 14,
                    color: isPromoted
                        ? Colors.white.withAlpha(179)
                        : const Color(0xFF5A6A85),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: isPromoted ? Colors.white24 : const Color(0xFFE2E8F0)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: isPromoted
                            ? Colors.white
                            : const Color(0xFF2A6FDB),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            color: isPromoted
                                ? Colors.white.withAlpha(230)
                                : const Color(0xFF1A2E4A),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBgColor,
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _isLoading ? null : onPressed,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Polished, production-quality replacement for the plain [AlertDialog]
/// previously shown when a pricing card's CTA is tapped.
///
/// Purely presentational: it preserves the exact same content and the same
/// single action (closing the dialog) as before — only the visuals, layout,
/// animation host, and accessibility semantics have been improved.
class _UpgradeExcuseDialog extends StatelessWidget {
  const _UpgradeExcuseDialog({required this.l10n, required this.colorScheme});

  final AppLocalizations l10n;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxDialogWidth = screenWidth < 420 ? screenWidth * 0.9 : 400.0;

    final surfaceColor = isDark ? const Color(0xFF1E2530) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A2E4A);
    final bodyColor = isDark
        ? Colors.white.withAlpha(196)
        : const Color(0xFF5A6A85);
    final subtleBg = isDark
        ? Colors.white.withAlpha(15)
        : const Color(0xFFF4F7FB);
    final subtleBorder = isDark
        ? Colors.white.withAlpha(31)
        : const Color(0xFFE2E8F0);

    return Semantics(
      label: l10n.dearUser,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxDialogWidth,
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Material(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(28),
            elevation: 24,
            shadowColor: Colors.black.withAlpha(80),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon badge for immediate visual context.
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withAlpha(isDark ? 40 : 24),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_read_rounded,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.dearUser,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.paymentWorkInProgress,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: bodyColor,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Contact info card — visually grouped and easy to scan.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: subtleBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: subtleBorder),
                    ),
                    child: Column(
                      children: [
                        _ContactRow(
                          icon: Icons.email_outlined,
                          text: l10n.contactEmail,
                          color: titleColor,
                        ),
                        const SizedBox(height: 10),
                        _ContactRow(
                          icon: Icons.phone_outlined,
                          text: l10n.contactPhone,
                          color: titleColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.thankYouForUnderstanding,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: bodyColor,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Primary (and only) action — full width for a clear,
                  // generous touch target and strong visual emphasis.
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.close,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

/// A single row inside the contact-info card, pairing an icon with
/// selectable, accessible text.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color.withAlpha(200)),
        const SizedBox(width: 10),
        Flexible(
          child: SelectableText(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
