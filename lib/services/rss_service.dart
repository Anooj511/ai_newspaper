import 'package:http/http.dart' as http;
import 'package:webfeed_revised/webfeed_revised.dart';
import 'package:intl/intl.dart';
import '../models/article_model.dart';
import '../models/outlet_model.dart';

class RssService {
  static Future<List<ArticleModel>> fetchFromOutlet(OutletModel outlet) async {
    try {
      final response = await http
          .get(
            Uri.parse(outlet.rssUrl),
            headers: {'User-Agent': 'Mozilla/5.0 (compatible; DailyDigest/1.0)'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return [];

      final feed = RssFeed.parse(response.body);
      final articles = <ArticleModel>[];

      for (final item in feed.items ?? []) {
        if (item.title == null || item.title!.isEmpty) continue;

        final publishedAt = _parseDate(item.pubDate);

        articles.add(ArticleModel(
          title: item.title ?? '',
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

      return articles;
    } catch (e) {
      return [];
    }
  }

  static Future<List<ArticleModel>> fetchFromOutlets(
    List<OutletModel> outlets,
  ) async {
    final futures = outlets.map((o) => fetchFromOutlet(o));
    final results = await Future.wait(futures);
    final allArticles = results.expand((list) => list).toList();
    allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return allArticles;
  }

  // Handles multiple RSS date formats
  static DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();

    // Try standard ISO format
    try {
      return DateTime.parse(dateStr);
    } catch (_) {}

    // Try RFC 822 format (most RSS feeds)
    // e.g. "Thu, 12 Mar 2026 10:00:00 +0000"
    try {
      final fmt = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z', 'en_US');
      return fmt.parse(dateStr);
    } catch (_) {}

    // Try without timezone
    try {
      final fmt = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US');
      return fmt.parse(dateStr);
    } catch (_) {}

    // Try short format
    try {
      final fmt = DateFormat('dd MMM yyyy HH:mm:ss Z', 'en_US');
      return fmt.parse(dateStr);
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
        .replaceAll('\n\n', '\n')
        .trim();
  }
}