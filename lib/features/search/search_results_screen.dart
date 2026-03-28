import 'package:flutter/material.dart';
import 'package:hote_v2/core/services/app_services.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/search_result_item.dart';
import 'package:hote_v2/features/booking/hotel_details_screen.dart';
import 'package:hote_v2/features/shell/main_shell_screen.dart';
import 'package:hote_v2/shared/components/hotel_image.dart';
import 'package:hote_v2/shared/components/kh_search_bar.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({
    super.key,
    this.initialCity,
    this.initialQuery,
  });

  final String? initialCity;
  final String? initialQuery;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _searchController;

  List<String> _provinces = const <String>[];
  List<SearchResultItem> _results = const <SearchResultItem>[];
  bool _isLoading = true;
  String? _selectedProvince;

  String get _provinceQuery => _searchController.text.trim();
  int get _resultCount => _results.length;

  @override
  void initState() {
    super.initState();
    _selectedProvince =
        _normalize(widget.initialCity) ?? _normalize(widget.initialQuery);
    _searchController = TextEditingController(text: _selectedProvince ?? '');
    _loadResults(saveSearch: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? _normalize(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _loadResults({bool saveSearch = true}) async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    final String? province = _selectedProvince;

    if (saveSearch && province != null) {
      await AppServices.hotels.saveSearch(province, city: province);
    }

    final List<String> provinces = await AppServices.hotels.fetchCities();
    final List<SearchResultItem> results =
        await AppServices.hotels.searchHotels(
      city: province,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _provinces = provinces;
      _results = results;
      _isLoading = false;
    });
  }

  String? _matchingProvince(String rawValue) {
    final String normalized = _normalize(rawValue) ?? '';
    if (normalized.isEmpty) {
      return null;
    }

    for (final String province in _provinces) {
      if (province.toLowerCase() == normalized.toLowerCase()) {
        return province;
      }
    }

    final List<String> partialMatches = _provinces
        .where(
          (String province) =>
              province.toLowerCase().contains(normalized.toLowerCase()),
        )
        .toList(growable: false);
    if (partialMatches.length == 1) {
      return partialMatches.first;
    }
    return null;
  }

  void _openProvince(String? province) {
    if (province == _selectedProvince) {
      return;
    }

    setState(() {
      _selectedProvince = province;
      _searchController.text = province ?? '';
    });
    _loadResults();
  }

  void _submitSearch(String value) {
    final String? province = _matchingProvince(value);
    if (province == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Search by a Cambodian province name only.'),
        ),
      );
      return;
    }

    setState(() {
      _selectedProvince = province;
      _searchController.text = province;
    });
    _loadResults();
  }

  void _clearSearch() {
    if (_provinceQuery.isEmpty && _selectedProvince == null) {
      return;
    }

    setState(() {
      _selectedProvince = null;
      _searchController.clear();
    });
    _loadResults();
  }

  void _openShellTab(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => MainShellScreen(initialIndex: index),
      ),
      (Route<dynamic> route) => false,
    );
  }

  String _resultHeading() {
    if (_selectedProvince != null) {
      return 'Hotels in $_selectedProvince';
    }
    return 'All Hotels by Province';
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
              Row(
                children: <Widget>[
                  Expanded(
                    child: KhSearchBar(
                      hint: 'Search province in Cambodia',
                      controller: _searchController,
                      onSubmitted: (String value) => _submitSearch(value),
                    ),
                  ),
                  if (_provinceQuery.isNotEmpty ||
                      _selectedProvince != null) ...<Widget>[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Clear search',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    _CityChip(
                      label: 'All',
                      isSelected: _selectedProvince == null,
                      onTap: () => _openProvince(null),
                    ),
                    const SizedBox(width: 8),
                    ..._provinces.map((String province) {
                      final bool isSelected = province == _selectedProvince;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: province == _provinces.last ? 0 : 8,
                        ),
                        child: _CityChip(
                          label: province,
                          isSelected: isSelected,
                          onTap: () => _openProvince(province),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _resultHeading(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '$_resultCount results',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isEmpty
                        ? const Center(
                            child: Text(
                              'No hotels matched your search yet.',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _results.length,
                            padding: const EdgeInsets.only(bottom: 18),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 14),
                            itemBuilder: (BuildContext context, int index) {
                              final SearchResultItem result = _results[index];
                              return _SearchResultCard(
                                result: result,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => HotelDetailsScreen(
                                      bookingFlow:
                                          BookingFlowData.fromResult(result),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _BottomNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: false,
                onTap: () => _openShellTab(0),
              ),
              _BottomNavItem(
                icon: Icons.search_rounded,
                label: 'Search',
                selected: true,
                onTap: () => _openShellTab(1),
              ),
              _BottomNavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Booking',
                selected: false,
                onTap: () => _openShellTab(2),
              ),
              _BottomNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: false,
                onTap: () => _openShellTab(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primary : AppTheme.surface,
        foregroundColor: isSelected ? Colors.white : AppTheme.textSecondary,
        side:
            BorderSide(color: isSelected ? AppTheme.primary : AppTheme.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({
    required this.result,
    required this.onTap,
  });

  final SearchResultItem result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 112,
                  height: 116,
                  child: HotelImage(
                    source: result.imageUrl,
                    fallbackColor: result.imageColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      result.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.locationLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.star_rounded,
                                size: 22,
                                color: Color(0xFFFFC44D),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                result.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${result.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 16 : 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected ? const Color(0x26FFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                color: Colors.white,
                size: selected ? 22 : 20,
              ),
              if (selected) ...<Widget>[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
