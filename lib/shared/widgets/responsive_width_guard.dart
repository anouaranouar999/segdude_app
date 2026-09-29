import 'package:flutter/material.dart';
import 'package:segdude_app/shared/widgets/desktop_required_card.dart';

/// Reusable minimum-width guard for pages whose layout cannot be squeezed
/// below a certain browser width without breaking (RenderFlex overflows,
/// unreadable multi-column tables/grids, etc).
///
/// Each page picks its own [minWidth] — there is no single "correct" value,
/// it depends on how many fixed-width columns/panels the page has.
///
/// While the viewport is at least [minWidth] wide, [builder] is used to
/// build the page exactly as before — nothing about the page's UI, logic,
/// or state changes. Below that width, the page is **not built at all**:
/// [builder] is never called, so none of its Rows/Expanded/fixed-width
/// widgets get a chance to overflow. A [DesktopRequiredCard] (narrow-window
/// variant) is shown instead, asking the user to enlarge the window.
///
/// Reacts immediately to browser resize: this widget reads
/// `MediaQuery.sizeOf`, so Flutter rebuilds it automatically whenever the
/// viewport width changes — no polling/timers needed. As soon as the width
/// becomes sufficient again, [builder] starts being called again and the
/// page reappears with no refresh required.
///
/// Usage — wrap the existing `build()` body instead of duplicating it:
/// ```dart
/// @override
/// Widget build(BuildContext context) {
///   return ResponsiveWidthGuard(
///     minWidth: 900,
///     builder: (context) => _buildPage(context), // original build() content
///   );
/// }
/// ```
class ResponsiveWidthGuard extends StatelessWidget {
  const ResponsiveWidthGuard({
    super.key,
    required this.minWidth,
    required this.builder,
  });

  /// The narrowest width (in logical pixels) at which this page's layout
  /// stays clean and usable. Below this, [builder] is not invoked.
  final double minWidth;

  /// Builds the real page. Only called when the viewport is wide enough.
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= minWidth) {
      return builder(context);
    }
    return const Scaffold(
      body: DesktopRequiredCard(
        variant: DesktopRequiredCardVariant.narrowWindow,
      ),
    );
  }
}
