import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:webfeed_revised/webfeed_revised.dart';
import '../models/article_model.dart';
import '../models/outlet_model.dart';

class RssService {
  static Future<List<ArticleModel>> fetchFromOutlet(OutletModel outlet) async {
    try {
      log('Fetching: ${outlet.name} → ${outlet.rssUrl}');

      final response = await http.get(
        Uri.parse(outlet.rssUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; DailyDigest/1.0)',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      ).timeout(const Duration(seconds: 15));

      log('${outlet.name} status: ${response.statusCode}');

      if (response.statusCode != 200) {
        log('${outlet.name} failed with status ${response.statusCode}');
        return [];
      }

      final feed = RssFeed.parse(response.body);
      final items = feed.items ?? [];
      log('${outlet.name} got ${items.length} items');

      final articles = <ArticleModel>[];

      for (final item in items) {
        if (item.title == null || item.title!.isEmpty) continue;

        final publishedAt = _parseDate(item.pubDate);

        articles.add(ArticleModel(
          title: item.title!.trim(),
          originalDescription: _cleanHtml(
            item.description ?? item.content?.value ?? '',
          ),
          sourceName: outlet.name,
          sourceId: outlet.id,
          url: item.link ?? '',
          category: outlet.category,
          publishedAt: publishedAt,
        ));
      }

      log('${outlet.name} parsed ${articles.length} articles');
      return articles;

    } catch (e) {
      log('${outlet.name} ERROR: $e');
      return [];
    }
  }

  static Future<List<ArticleModel>> fetchFromOutlets(
    List<OutletModel> outlets,
  ) async {
    final results = <List<ArticleModel>>[];

    // Fetch one by one so failures don't block others
    for (final outlet in outlets) {
      final articles = await fetchFromOutlet(outlet);
      results.add(articles);
    }

    final allArticles = results.expand((list) => list).toList();
    log('Total articles fetched: ${allArticles.length}');

    allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return allArticles;
  }

  // Handles all common RSS date formats
  static DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();

    // Remove day name prefix if present e.g. "Thu, "
    String cleaned = dateStr.trim();

    // Try ISO 8601
    try {
      return DateTime.parse(cleaned);
    } catch (_) {}

    // Try RFC 822: "12 Mar 2026 10:00:00 +0000"
    try {
      final parts = cleaned.split(' ');
      // Remove weekday if present
      if (parts[0].endsWith(',')) {
        cleaned = parts.sublist(1).join(' ');
      }
      // Normalize timezone
      cleaned = cleaned
          .replaceAll('GMT', '+0000')
          .replaceAll('UTC', '+0000')
          .replaceAll('EST', '-0500')
          .replaceAll('PST', '-0800')
          .replaceAll('IST', '+0530');

      // Manual parse: "12 Mar 2026 10:00:00 +0530"
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
        'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
        'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };

      final p = cleaned.split(' ');
      if (p.length >= 4) {
        final day = int.parse(p[0]);
        final month = months[p[1]] ?? 1;
        final year = int.parse(p[2]);
        final timeParts = p[3].split(':');
        final hour = int.parse(timeParts[0]);
        final minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
        final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;
        return DateTime(year, month, day, hour, minute, second);
      }
    } catch (_) {}

    return DateTime.now();
  }

  static String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('\n\n', '\n')
        .trim();
  }
}