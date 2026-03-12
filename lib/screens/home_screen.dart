import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart';
import '../models/outlet_model.dart';
import '../services/rss_service.dart';
import '../services/groq_service.dart';
import '../utils/outlets_data.dart';
import '../utils/theme.dart';
import '../utils/date_helper.dart';
import '../widgets/masthead_widget.dart';
import '../widgets/article_card_widget.dart';
import '../widgets/section_divider_widget.dart';
import 'outlet_picker_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ArticleModel> _articles = [];
  List<OutletModel> _selectedOutlets = [];
  DateTime _selectedDate = DateHelper.today();
  String _language = 'english';
  String _apiKey = '';
  String _model = 'llama3-8b-8192';

  bool _isLoading = false;
  bool _isSummarizing = false;
  int _summarizeProgress = 0;
  int _summarizeTotal = 0;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList('selected_outlets') ?? [];
    setState(() {
      _apiKey = prefs.getString('groq_api_key') ?? '';
      _model = prefs.getString('groq_model') ?? 'llama3-8b-8192';
      _language = prefs.getString('language') ?? 'english';
      _selectedOutlets = savedIds.isEmpty
          ? availableOutlets.toList()
          : availableOutlets.where((o) => savedIds.contains(o.id)).toList();
    });
  }

  Future<void> _generateNewspaper() async {
    if (_apiKey.isEmpty) {
      _showSnack('Please add your Groq API key in Settings first!');
      return;
    }
    if (_selectedOutlets.isEmpty) {
      _showSnack('Please select at least one outlet!');
      return;
    }

    setState(() {
      _isLoading = true;
      _articles = [];
      _statusMessage = 'Fetching news from ${_selectedOutlets.length} outlets...';
    });

    // Step 1: Fetch RSS feeds
    final fetched = await RssService.fetchFromOutlets(_selectedOutlets);

// Filter by selected date
    final filtered = fetched.where((a) =>
      DateHelper.isSameDay(a.publishedAt, _selectedDate)
    ).toList();

    // Use filtered if available, otherwise use all fetched
    // Increased limit to 50 articles
    final toSummarize = filtered.isNotEmpty
        ? filtered.take(50).toList()
        : fetched.take(50).toList();

    // Show message if date filter returned nothing
    if (filtered.isEmpty && fetched.isNotEmpty) {
      _showSnack('No articles found for selected date — showing latest available.');
    }

    setState(() {
      _isLoading = false;
      _isSummarizing = true;
      _summarizeTotal = toSummarize.length;
      _statusMessage = 'AI is writing your newspaper...';
    });

    // Step 2: Summarize with Groq
    final summarized = await GroqService.summarizeAll(
      articles: toSummarize,
      apiKey: _apiKey,
      model: _model,
      language: _language,
      onProgress: (current, total) {
        setState(() {
          _summarizeProgress = current;
          _statusMessage = 'Summarizing article $current of $total...';
        });
      },
    );

    setState(() {
      _articles = summarized;
      _isSummarizing = false;
      _statusMessage = '';
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.sourceSans3()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openOutletPicker() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (_) => const OutletPickerScreen()),
    );
    if (result != null) {
      setState(() {
        _selectedOutlets = availableOutlets
            .where((o) => result.contains(o.id))
            .toList();
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateHelper.today(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // Group articles by category
  Map<String, List<ArticleModel>> get _grouped {
    final map = <String, List<ArticleModel>>{};
    for (final article in _articles) {
      map.putIfAbsent(article.category, () => []).add(article);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppTheme.darkInk : AppTheme.lightInk;
    final accentColor = isDark ? AppTheme.darkAccent : AppTheme.lightAccent;
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'The Daily Digest',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w900),
        ),
        actions: [
          // Date picker
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20),
            tooltip: 'Pick Date',
            onPressed: _pickDate,
          ),
          // Outlets
          IconButton(
            icon: const Icon(Icons.newspaper, size: 20),
            tooltip: 'Select Outlets',
            onPressed: _openOutletPicker,
          ),
          // Dark mode toggle
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              size: 20,
            ),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings, size: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ).then((_) => _loadPreferences()),
          ),
        ],
      ),

      body: Column(
        children: [
          // Masthead
          MastheadWidget(selectedDate: _selectedDate),

          // Status bar during loading
          if (_isLoading || _isSummarizing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: accentColor.withOpacity(0.1),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accentColor,
                      value: _isSummarizing && _summarizeTotal > 0
                          ? _summarizeProgress / _summarizeTotal
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _statusMessage,
                    style: GoogleFonts.sourceSans3(
                      fontSize: 13,
                      color: inkColor,
                    ),
                  ),
                ],
              ),
            ),

          // Articles list
          Expanded(
            child: _articles.isEmpty && !_isLoading && !_isSummarizing
                ? _buildEmptyState(inkColor, accentColor)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ..._grouped.entries.map((entry) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionDividerWidget(title: entry.key),
                          // First article in category is featured
                          ...entry.value.asMap().entries.map((e) =>
                            ArticleCardWidget(
                              article: e.value,
                              isFeatured: e.key == 0,
                              language: _language,
                            ),
                          ),
                        ],
                      )),
                    ],
                  ),
          ),
        ],
      ),

      // Generate button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading || _isSummarizing ? null : _generateNewspaper,
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_awesome),
        label: Text(
          _isLoading || _isSummarizing ? 'Generating...' : 'Generate',
          style: GoogleFonts.sourceSans3(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color inkColor, Color accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📰',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 24),
            Text(
              'Your newspaper awaits.',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: inkColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap Generate to fetch the latest news\nfrom your selected outlets.',
              textAlign: TextAlign.center,
              style: GoogleFonts.libreBaskerville(
                fontSize: 14,
                color: inkColor.withOpacity(0.6),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_selectedOutlets.length} outlets selected · ${DateHelper.formatShortDate(_selectedDate)}',
              style: GoogleFonts.sourceSans3(
                fontSize: 12,
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}