import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class GroqService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  // Summarize a single article
  static Future<ArticleModel> summarizeArticle({
    required ArticleModel article,
    required String apiKey,
    required String model,
    required String language, // 'english', 'malayalam', 'both'
  }) async {
    try {
      String englishSummary = '';
      String malayalamSummary = '';

      // Get English summary
      if (language == 'english' || language == 'both') {
        englishSummary = await _callGroq(
          apiKey: apiKey,
          model: model,
          prompt: _buildEnglishPrompt(article.title, article.originalDescription),
        );
      }

      // Get Malayalam summary
      if (language == 'malayalam' || language == 'both') {
        malayalamSummary = await _callGroq(
          apiKey: apiKey,
          model: model,
          prompt: _buildMalayalamPrompt(article.title, article.originalDescription),
        );
      }

      // Return updated article
      return ArticleModel(
        title: article.title,
        originalDescription: article.originalDescription,
        aiSummary: englishSummary,
        aiSummaryMalayalam: malayalamSummary,
        sourceName: article.sourceName,
        sourceId: article.sourceId,
        url: article.url,
        category: article.category,
        publishedAt: article.publishedAt,
        isSummarized: true,
      );
    } catch (e) {
      return article; // Return original if summarization fails
    }
  }

  // Summarize multiple articles
  static Future<List<ArticleModel>> summarizeAll({
    required List<ArticleModel> articles,
    required String apiKey,
    required String model,
    required String language,
    Function(int current, int total)? onProgress,
  }) async {
    final summarized = <ArticleModel>[];

    for (int i = 0; i < articles.length; i++) {
      onProgress?.call(i + 1, articles.length);
      final result = await summarizeArticle(
        article: articles[i],
        apiKey: apiKey,
        model: model,
        language: language,
      );
      summarized.add(result);
    }

    return summarized;
  }

  // Core API call to Groq
  static Future<String> _callGroq({
    required String apiKey,
    required String model,
    required String prompt,
  }) async {
    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'max_tokens': 800,
            'temperature': 0.7,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].toString().trim();
    }
    return '';
  }

  // English newspaper style prompt
  static String _buildEnglishPrompt(String title, String description) {
    return '''
You are a professional newspaper journalist. Write a full newspaper-style article based on the following news:

Title: $title
Details: $description

Write exactly 4 paragraphs:
- Paragraph 1: Strong opening that captures the key news event (who, what, when, where)
- Paragraph 2: Background context and why this matters
- Paragraph 3: Impact, reactions, or consequences
- Paragraph 4: Outlook, what happens next, or closing thought

Use formal newspaper tone. No bullet points. No headings. Just flowing paragraphs.
''';
  }

  // Malayalam newspaper style prompt
  static String _buildMalayalamPrompt(String title, String description) {
    return '''
നിങ്ങൾ ഒരു പ്രൊഫഷണൽ മലയാളം പത്രലേഖകൻ ആണ്. താഴെ കൊടുത്തിരിക്കുന്ന വാർത്തയുടെ അടിസ്ഥാനത്തിൽ ഒരു പൂർണ്ണ പത്ര ലേഖനം മലയാളത്തിൽ എഴുതുക:

തലക്കെട്ട്: $title
വിവരങ്ങൾ: $description

കൃത്യം 4 ഖണ്ഡികകൾ എഴുതുക:
- ഖണ്ഡിക 1: പ്രധാന വാർത്ത (ആര്, എന്ത്, എന്ന്, എവിടെ)
- ഖണ്ഡിക 2: പശ്ചാത്തലവും പ്രസക്തിയും
- ഖണ്ഡിക 3: പ്രത്യാഘാതങ്ങൾ, പ്രതികരണങ്ങൾ
- ഖണ്ഡിക 4: ഭാവി സാധ്യതകൾ

ഔദ്യോഗിക പത്ര ശൈലിയിൽ എഴുതുക. ബുള്ളറ്റ് പോയിന്റുകൾ വേണ്ട. തലക്കെട്ടുകൾ വേണ്ട.
''';
  }
}