import 'package:flutter/material.dart';
import 'profile_tokens.dart';

/// A single read-only "label + value" row, icon-prefixed to match the
/// visual language of [AuthTextField] (icon-prefixed inputs) without
/// looking like an editable field — this is display-only data.
class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1FC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: ProfileTokens.primaryBlue),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ProfileTokens.mutedText,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: ProfileTokens.darkNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
