import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import '../utils/date_helper.dart';

class MastheadWidget extends StatelessWidget {
  final DateTime selectedDate;

  const MastheadWidget({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppTheme.darkInk : AppTheme.lightInk;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;

    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          // Top meta row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateHelper.formatFullDate(selectedDate),
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  color: inkColor.withOpacity(0.6),
                ),
              ),
              Text(
                'AI CURATED',
                style: GoogleFonts.sourceSans3(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: inkColor.withOpacity(0.6),
                ),
              ),
            ],
          ),

          Divider(color: inkColor.withOpacity(0.3)),

          // Main title
          Text(
            'The Daily Digest',
            style: GoogleFonts.playfairDisplay(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: inkColor,
              height: 1,
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            'Your Personal AI-Curated Newspaper',
            style: GoogleFonts.libreBaskerville(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: inkColor.withOpacity(0.6),
            ),
          ),

          Divider(color: inkColor.withOpacity(0.3)),

          // Bottom rule
          Text(
            '— All the news that matters to you —',
            style: GoogleFonts.sourceSans3(
              fontSize: 11,
              letterSpacing: 1,
              color: inkColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}