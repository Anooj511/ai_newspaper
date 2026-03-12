class ArticleModel {
  final String title;
  final String originalDescription;
  final String aiSummary;
  final String aiSummaryMalayalam;
  final String sourceName;
  final String sourceId;
  final String url;
  final String category;
  final DateTime publishedAt;
  bool isSummarized;

  ArticleModel({
    required this.title,
    required this.originalDescription,
    this.aiSummary = '',
    this.aiSummaryMalayalam = '',
    required this.sourceName,
    required this.sourceId,
    required this.url,
    required this.category,
    required this.publishedAt,
    this.isSummarized = false,
  });
}