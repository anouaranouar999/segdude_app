import 'package:flutter/material.dart';

/// A reusable styled container used in CreateSubject to highlight level rows.
///
/// Signature matches call site in create_subject.dart:
///   customContainer(color, isNotSelected, child: widget)
///
/// [color]         — background tint colour
/// [isNotSelected] — when true the row is shown at reduced opacity (greyed out)
/// [child]         — content widget (typically a ListTile)
Widget customContainer(
  Color color,
  bool isNotSelected, {
  required Widget child,
}) {
  return AnimatedOpacity(
    opacity: isNotSelected ? 0.55 : 1.0,
    duration: const Duration(milliseconds: 180),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNotSelected ? Colors.white : color,
        border: Border.all(
          color: isNotSelected
              ? const Color(0xFFDDE3EC)
              : const Color(0xFF2A6FDB).withAlpha(35),
          width: isNotSelected ? 1 : 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isNotSelected
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF2A6FDB).withAlpha(10),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    ),
  );
}
