import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/outlet_model.dart';
import '../utils/outlets_data.dart';
import '../utils/theme.dart';

class OutletPickerScreen extends StatefulWidget {
  const OutletPickerScreen({super.key});

  @override
  State<OutletPickerScreen> createState() => _OutletPickerScreenState();
}

class _OutletPickerScreenState extends State<OutletPickerScreen> {
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadSelected();
  }

  Future<void> _loadSelected() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('selected_outlets') ?? [];
    setState(() {
      _selectedIds.addAll(saved);
      // Default: select all if nothing saved
      if (_selectedIds.isEmpty) {
        _selectedIds.addAll(availableOutlets.map((o) => o.id));
      }
    });
  }

  Future<void> _saveSelected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selected_outlets', _selectedIds.toList());
    if (mounted) Navigator.pop(context, _selectedIds.toList());
  }

  void _toggleOutlet(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() => _selectedIds.addAll(availableOutlets.map((o) => o.id)));
  }

  void _clearAll() {
    setState(() => _selectedIds.clear());
  }

  // Group outlets by category
  Map<String, List<OutletModel>> get _grouped {
    final map = <String, List<OutletModel>>{};
    for (final outlet in availableOutlets) {
      map.putIfAbsent(outlet.category, () => []).add(outlet);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppTheme.darkInk : AppTheme.lightInk;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final accentColor = isDark ? AppTheme.darkAccent : AppTheme.lightAccent;
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Outlets',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: _selectAll,
            child: Text(
              'All',
              style: GoogleFonts.sourceSans3(
                color: bgColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _clearAll,
            child: Text(
              'Clear',
              style: GoogleFonts.sourceSans3(
                color: bgColor.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Selected count banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: surfaceColor,
            child: Text(
              '${_selectedIds.length} of ${availableOutlets.length} outlets selected',
              style: GoogleFonts.sourceSans3(
                fontSize: 13,
                color: inkColor.withOpacity(0.7),
              ),
            ),
          ),

          // Outlet list grouped by category
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: GoogleFonts.sourceSans3(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: accentColor,
                        ),
                      ),
                    ),
                    Divider(color: inkColor.withOpacity(0.2), height: 1),
                    const SizedBox(height: 8),

                    // Outlet chips
                    ...entry.value.map((outlet) {
                      final isSelected = _selectedIds.contains(outlet.id);
                      return InkWell(
                        onTap: () => _toggleOutlet(outlet.id),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? accentColor.withOpacity(0.1) : surfaceColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isSelected
                                  ? accentColor
                                  : inkColor.withOpacity(0.15),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(outlet.emoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      outlet.name,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: inkColor,
                                      ),
                                    ),
                                    Text(
                                      outlet.language,
                                      style: GoogleFonts.sourceSans3(
                                        fontSize: 11,
                                        color: inkColor.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? accentColor
                                    : inkColor.withOpacity(0.3),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),

          // Done button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedIds.isEmpty ? null : _saveSelected,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'Done — Use ${_selectedIds.length} Outlets',
                  style: GoogleFonts.sourceSans3(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}