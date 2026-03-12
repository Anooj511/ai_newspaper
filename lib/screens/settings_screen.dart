import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  String _selectedModel = 'llama3-8b-8192';
  String _selectedLanguage = 'english';
  bool _obscureKey = true;
  bool _saved = false;

  final List<Map<String, String>> _models = [
    {'value': 'llama3-8b-8192', 'label': 'LLaMA 3 8B — Fast'},
    {'value': 'mixtral-8x7b-32768', 'label': 'Mixtral 8x7B — Smart'},
    {'value': 'llama3-70b-8192', 'label': 'LLaMA 3 70B — Best'},
  ];

  final List<Map<String, String>> _languages = [
    {'value': 'english', 'label': 'English'},
    {'value': 'malayalam', 'label': 'Malayalam (മലയാളം)'},
    {'value': 'both', 'label': 'Both'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString('groq_api_key') ?? '';
      _selectedModel = prefs.getString('groq_model') ?? 'llama3-8b-8192';
      _selectedLanguage = prefs.getString('language') ?? 'english';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('groq_api_key', _apiKeyController.text.trim());
    await prefs.setString('groq_model', _selectedModel);
    await prefs.setString('language', _selectedLanguage);
    setState(() => _saved = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _saved = false);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppTheme.darkInk : AppTheme.lightInk;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final accentColor = isDark ? AppTheme.darkAccent : AppTheme.lightAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── API KEY ──
            _sectionTitle('Groq API Key', inkColor),
            const SizedBox(height: 8),
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureKey,
              style: GoogleFonts.sourceSans3(color: inkColor),
              decoration: InputDecoration(
                hintText: 'gsk_...',
                hintStyle: GoogleFonts.sourceSans3(
                  color: inkColor.withOpacity(0.4),
                ),
                filled: true,
                fillColor: surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: inkColor.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: inkColor.withOpacity(0.3)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureKey ? Icons.visibility : Icons.visibility_off,
                    color: inkColor.withOpacity(0.5),
                  ),
                  onPressed: () => setState(() => _obscureKey = !_obscureKey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get your free API key at console.groq.com',
              style: GoogleFonts.sourceSans3(
                fontSize: 12,
                color: accentColor,
              ),
            ),

            const SizedBox(height: 32),

            // ── MODEL ──
            _sectionTitle('AI Model', inkColor),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: inkColor.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedModel,
                  isExpanded: true,
                  dropdownColor: surfaceColor,
                  style: GoogleFonts.sourceSans3(color: inkColor),
                  items: _models.map((m) {
                    return DropdownMenuItem(
                      value: m['value'],
                      child: Text(m['label']!),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedModel = v!),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── LANGUAGE ──
            _sectionTitle('Summary Language', inkColor),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: inkColor.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLanguage,
                  isExpanded: true,
                  dropdownColor: surfaceColor,
                  style: GoogleFonts.sourceSans3(color: inkColor),
                  items: _languages.map((l) {
                    return DropdownMenuItem(
                      value: l['value'],
                      child: Text(l['label']!),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedLanguage = v!),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // ── SAVE BUTTON ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  _saved ? '✓ Saved!' : 'Save Settings',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, Color color) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.sourceSans3(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: color,
      ),
    );
  }
}