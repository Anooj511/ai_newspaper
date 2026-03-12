import 'package:http/http.dart' as http;
import 'package:webfeed_revised/webfeed_revised.dart';
import '../models/article_model.dart';
import '../models/outlet_model.dart';

class RssService {
  // Fetch articles from a single outlet
  static Future<List<ArticleModel>> fetchFromOutlet(OutletModel outlet) async {
    try {
      final response = await http
          .get(Uri.parse(outlet.rssUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final feed = RssFeed.parse(response.body);
      final articles = <ArticleModel>[];

      for (final item in feed.items ?? []) {
        // Skip if no title
        if (item.title == null || item.title!.isEmpty) continue;

        // Parse publish date
        DateTime publishedAt;
        try {
          publishedAt = item.pubDate != null
              ? DateTime.parse(item.pubDate!)
              : DateTime.now();
        } catch (_) {
          publishedAt = DateTime.now();
        }

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
      // If this outlet fails, return empty list and continue
      return [];
    }
  }

  // Fetch from multiple outlets at once
  static Future<List<ArticleModel>> fetchFromOutlets(
    List<OutletModel> outlets,
  ) async {
    final futures = outlets.map((o) => fetchFromOutlet(o));
    final results = await Future.wait(futures);

    // Flatten all results into one list
    final allArticles = results.expand((list) => list).toList();

    // Sort by newest first
    allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return allArticles;
  }

  // Remove HTML tags from description
  static String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '') // remove tags
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('\n\n', '\n')
        .trim();
  }
}