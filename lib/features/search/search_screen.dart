import 'package:flutter/material.dart';
import 'package:hote_v2/core/services/app_services.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/features/home/map_screen.dart';
import 'package:hote_v2/features/search/search_results_screen.dart';
import 'package:hote_v2/shared/components/kh_search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _provinces = const <String>[];
  List<String> _searchHistory = const <String>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final List<String> provinces = await AppServices.hotels.fetchCities();
    final List<String> history = await AppServices.hotels.fetchSearchHistory();
    if (!mounted) {
      return;
    }

    final Set<String> provinceIndex =
        provinces.map((String value) => value.toLowerCase()).toSet();

    setState(() {
      _provinces = provinces;
      _searchHistory = history
          .where((String value) => provinceIndex.contains(value.toLowerCase()))
          .toList(growable: false);
      _isLoading = false;
    });
  }

  String? _matchingProvince(String query) {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    for (final String province in _provinces) {
      if (province.toLowerCase() == trimmed.toLowerCase()) {
        return province;
      }
    }

    final List<String> partialMatches = _provinces
        .where(
          (String province) =>
              province.toLowerCase().contains(trimmed.toLowerCase()),
        )
        .toList(growable: false);
    if (partialMatches.length == 1) {
      return partialMatches.first;
    }

    return null;
  }

  Future<void> _submitSearch([String? rawValue]) async {
    final String value = (rawValue ?? _searchController.text).trim();
    if (value.isEmpty) {
      return;
    }

    final String? matchedProvince = _matchingProvince(value);
    if (matchedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Search by a Cambodian province name only.'),
        ),
      );
      return;
    }

    await AppServices.hotels.saveSearch(matchedProvince, city: matchedProvince);
    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchResultsScreen(initialCity: matchedProvince),
      ),
    );
  }

  Future<void> _openProvince(String province) async {
    await AppServices.hotels.saveSearch(province, city: province);
    if (!mounted) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchResultsScreen(initialCity: province),
      ),
    );
  }

  Future<void> _removeSearch(String value) async {
    await AppServices.hotels.removeSearch(value);
    if (!mounted) {
      return;
    }

    setState(() {
      _searchHistory = _searchHistory
          .where((String entry) => entry.toLowerCase() != value.toLowerCase())
          .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Search',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Browse provinces, revisit your recent searches, and jump back into hotel discovery.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              KhSearchBar(
                hint: 'Search province in Cambodia',
                controller: _searchController,
                onSubmitted: (String value) => _submitSearch(value),
              ),
              const SizedBox(height: 22),
              const Text(
                'Browse provinces',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _provinces.map((String province) {
                    return OutlinedButton(
                      onPressed: () => _openProvince(province),
                      child: Text(province),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  const Text(
                    'Recent searches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_searchHistory.isNotEmpty)
                    Text(
                      '${_searchHistory.length} items',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _searchHistory.isEmpty
                    ? const Center(
                        child: Text(
                          'No recent searches yet.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _searchHistory.length,
                        padding: const EdgeInsets.only(bottom: 16),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final String value = _searchHistory[index];
                          return Material(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(22),
                            child: InkWell(
                              onTap: () => _submitSearch(value),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: AppTheme.border),
                                  boxShadow: AppTheme.cardShadow,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceSoft,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.history_rounded,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeSearch(value),
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, MapScreen.routeName),
                    icon:
                        const Icon(Icons.map_outlined, color: AppTheme.primary),
                    label: const Text('Open Map'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
