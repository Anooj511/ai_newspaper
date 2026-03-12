import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';
import '../utils/theme.dart';
import '../utils/date_helper.dart';

class ArticleCardWidget extends StatelessWidget {
  final ArticleModel article;
  final bool isFeatured;
  final String language;

  const ArticleCardWidget({
    super.key,
    required this.article,
    this.isFeatured = false,
    required this.language,
  });

  String get _summaryText {
    if (language == 'malayalam') return article.aiSummaryMalayalam;
    return article.aiSummary.isNotEmpty
        ? article.aiSummary
        : article.originalDescription;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppTheme.darkInk : AppTheme.lightInk;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final accentColor = isDark ? AppTheme.darkAccent : AppTheme.lightAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          left: BorderSide(
            color: isFeatured ? accentColor : inkColor.withOpacity(0.15),
            width: isFeatured ? 4 : 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source + time
          Row(
            children: [
              Text(
                article.sourceName.toUpperCase(),
                style: GoogleFonts.sourceSans3(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: accentColor,
                ),
              ),
              const Spacer(),
              Text(
                DateHelper.timeAgo(article.publishedAt),
                style: GoogleFonts.sourceSans3(
                  fontSize: 10,
                  color: inkColor.withOpacity(0.4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Headline
          Text(
            article.title,
            style: GoogleFonts.playfairDisplay(
              fontSize: isFeatured ? 22 : 16,
              fontWeight: FontWeight.w700,
              color: inkColor,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 10),

          Divider(color: inkColor.withOpacity(0.15), height: 1),

          const SizedBox(height: 10),

          // AI Summary paragraphs
          if (_summaryText.isNotEmpty)
            Text(
              _summaryText,
              style: GoogleFonts.libreBaskerville(
                fontSize: isFeatured ? 14 : 13,
                height: 1.8,
                color: inkColor.withOpacity(0.85),
              ),
            ),

          const SizedBox(height: 12),

          // Read original link
          if (article.url.isNotEmpty)
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(article.url);
                if (await canLaunchUrl(uri)) launchUrl(uri);
              },
              child: Text(
                'Read original →',
                style: GoogleFonts.sourceSans3(
                  fontSize: 12,
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}