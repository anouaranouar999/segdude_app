import 'dart:ui';

import 'package:flutter/material.dart';

/// Full-page decorative background for the authentication pages.
///
/// Wrap the whole page body with this widget so the soft gradient,
/// blurred shapes, dotted patterns, and abstract curved lines flow behind
/// both the branding panel AND the auth card — the card simply floats
/// above it as an opaque white surface. Everything here is intentionally
/// subtle so it never competes with the content.
class AuthPageBackground extends StatelessWidget {
  final Widget child;
  const AuthPageBackground({super.key, required this.child});

  static const Color _tint = Color(0xFF2A6FDB);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEFF3FA), Color(0xFFE6ECF9)],
            ),
          ),
        ),

        // ---- large soft blurred ambient shapes ----
        Positioned(
          top: -130,
          left: -110,
          child: _blurredCircle(300, _tint.withAlpha(10)),
        ),
        Positioned(
          bottom: -150,
          right: -130,
          child: _blurredCircle(340, _tint.withAlpha(08)),
        ),

        // ---- crisper mid-size circles for definition ----
        Positioned(
          top: -60,
          right: -40,
          child: _decorCircle(180, _tint.withAlpha(08)),
        ),
        Positioned(
          bottom: -70,
          left: -50,
          child: _decorCircle(210, _tint.withAlpha(06)),
        ),

        // ---- small accent circles scattered for texture ----
        Positioned(
          top: 150,
          left: 90,
          child: _decorCircle(44, _tint.withAlpha(06)),
        ),
        Positioned(
          bottom: 240,
          right: 300,
          child: _decorCircle(30, _tint.withAlpha(08)),
        ),
        Positioned(
          top: 320,
          right: 60,
          child: _ringCircle(70, _tint.withAlpha(14)),
        ),
        Positioned(
          bottom: 90,
          left: 260,
          child: _ringCircle(46, _tint.withAlpha(12)),
        ),

        // ---- dotted patterns ----
        Positioned(top: 110, right: 140, child: _dotGrid()),
        Positioned(bottom: 100, left: 150, child: _dotGrid()),

        // ---- abstract curved lines, very faint ----
        const Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _CurvedLinesPainter()),
          ),
        ),

        child,
      ],
    );
  }

  static Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  /// A large, soft blurred circle used for ambient ("light blurred shapes")
  /// depth in the corners of the page.
  static Widget _blurredCircle(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  /// An outlined (ring) circle for a lighter, more geometric accent.
  static Widget _ringCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.4),
      ),
    );
  }

  static Widget _dotGrid() {
    return SizedBox(
      width: 60,
      height: 40,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 15,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: _tint.withAlpha(12),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Very subtle abstract curved lines drawn across the whole page for extra
/// visual texture. Kept faint (low opacity, thin stroke) so they read as
/// texture rather than as distinct shapes.
class _CurvedLinesPainter extends CustomPainter {
  const _CurvedLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x122A6FDB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final topCurve = Path()
      ..moveTo(-40, size.height * 0.26)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.04,
        size.width * 0.80,
        size.height * 0.20,
      );
    canvas.drawPath(topCurve, paint);

    final bottomCurve = Path()
      ..moveTo(size.width * 0.10, size.height + 40)
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.84,
        size.width + 40,
        size.height * 0.94,
      );
    canvas.drawPath(bottomCurve, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvedLinesPainter oldDelegate) => false;
}
