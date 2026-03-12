import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';

class SectionDividerWidget extends StatelessWidget {
  final String title;

  const SectionDividerWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppTheme.darkInk : AppTheme.lightInk;
    final accentColor = isDark ? AppTheme.darkAccent : AppTheme.lightAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 3, color: inkColor),
          const SizedBox(height: 4),
          Container(height: 1, color: inkColor),
          const SizedBox(height: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.sourceSans3(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: inkColor.withOpacity(0.3)),
        ],
      ),
    );
  }
}