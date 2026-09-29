import 'package:flutter/material.dart';
import 'package:segdude_app/shared/widgets/desktop_required_card.dart';

/// Reusable navigation guard.
///
/// Wraps any action that requires a larger screen (creating a schedule,
/// signing in, etc.). It checks the current viewport width and either
/// runs the requested navigation or blocks it and shows
/// [DesktopRequiredCard] instead.
///
/// While the card is visible it keeps observing the viewport: as soon as
/// the width becomes supported again, the card dismisses itself and
/// [onAllowed] is invoked automatically — no extra tap required.
///
/// This is the single place responsible for deciding whether navigation
/// into screen-size-sensitive parts of the app is allowed — call it from
/// any `onPressed` / `onTap` instead of duplicating the width check.
///
/// Usage:
/// ```dart
/// onPressed: () => NavigationGuard.run(context, () => context.go('/create')),
/// ```
class NavigationGuard {
  const NavigationGuard._();

  /// Whether the current viewport is wide enough to use screen-size
  /// sensitive features. Backed by [kDesktopRequiredBreakpoint], the same
  /// constant used by [DesktopRequiredCard].
  static bool isSupportedWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= kDesktopRequiredBreakpoint;
  }

  /// Runs [onAllowed] if the viewport is wide enough; otherwise blocks
  /// navigation and shows [DesktopRequiredCard] until the viewport grows
  /// enough, at which point [onAllowed] runs automatically.
  static void run(BuildContext context, VoidCallback onAllowed) {
    if (isSupportedWidth(context)) {
      onAllowed();
      return;
    }
    showDesktopRequiredCard(context, onResized: onAllowed);
  }

  /// Shows [DesktopRequiredCard] as a full-screen overlay.
  ///
  /// If [onResized] is provided, the card keeps watching the viewport
  /// width and, once it reaches [kDesktopRequiredBreakpoint], dismisses
  /// itself and calls [onResized] — resuming the original navigation
  /// automatically.
  static Future<void> showDesktopRequiredCard(
    BuildContext context, {
    VoidCallback? onResized,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (context, _, _) => onResized == null
          ? const DesktopRequiredCard()
          : _AutoResumingDesktopGate(onResized: onResized),
    );
  }
}

/// Wraps [DesktopRequiredCard] and watches [MediaQuery] for width changes.
/// Flutter already rebuilds this widget whenever the viewport metrics it
/// depends on change (via `MediaQuery.sizeOf`), so no polling/timers are
/// needed. As soon as the width is supported again, it pops itself and
/// invokes [onResized] exactly once.
class _AutoResumingDesktopGate extends StatefulWidget {
  const _AutoResumingDesktopGate({required this.onResized});

  final VoidCallback onResized;

  @override
  State<_AutoResumingDesktopGate> createState() =>
      _AutoResumingDesktopGateState();
}

class _AutoResumingDesktopGateState extends State<_AutoResumingDesktopGate> {
  bool _resuming = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (!_resuming && width >= kDesktopRequiredBreakpoint) {
      _resuming = true;
      // Defer to after this frame: pop mid-build is unsafe, and the
      // navigation callback may itself trigger navigation/rebuilds.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pop();
        widget.onResized();
      });
    }
    return const DesktopRequiredCard();
  }
}
