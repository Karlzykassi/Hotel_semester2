import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/data/mock/app_data.dart';
import 'package:hote_v2/data/models/booking_flow_data.dart';
import 'package:hote_v2/data/models/search_result_item.dart';
import 'package:hote_v2/features/booking/hotel_details_screen.dart';
import 'package:hote_v2/features/shell/main_shell_screen.dart';
import 'package:hote_v2/shared/components/kh_search_bar.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.initialCity,
  });

  final String initialCity;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _searchController;

  String get _selectedCity => widget.initialCity;

  List<SearchResultItem> get _results =>
      AppData.searchResultsByCity[_selectedCity] ?? const <SearchResultItem>[];

  int get _resultCount =>
      AppData.searchResultCounts[_selectedCity] ?? _results.length;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _selectedCity);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCity(String city) {
    if (city == _selectedCity) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SearchResultsScreen(initialCity: city),
      ),
    );
  }

  void _openShellTab(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => MainShellScreen(initialIndex: index),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KhSearchBar(
                hint: _selectedCity,
                controller: _searchController,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppData.cities.map((city) {
                    final isSelected = city == _selectedCity;

                    return Padding(
                      padding: EdgeInsets.only(
                        right: city == AppData.cities.last ? 0 : 8,
                      ),
                      child: OutlinedButton(
                        onPressed: () => _openCity(city),
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              isSelected ? AppTheme.primary : Colors.white,
                          foregroundColor:
                              isSelected ? Colors.white : AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          city,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                'Filtered ($_resultCount)',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  padding: const EdgeInsets.only(bottom: 18),
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return _SearchResultCard(
                      result: result,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => HotelDetailsScreen(
                            bookingFlow: BookingFlowData.fromResult(result),
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
      bottomNavigationBar: Container(
        height: 92,
        decoration: const BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home_outlined,
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
              icon: Icons.wallet_membership_outlined,
              label: 'Booking',
              selected: false,
              onTap: () => _openShellTab(2),
            ),
            _BottomNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              selected: false,
              onTap: () => _openShellTab(3),
            ),
          ],
        ),
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

  Widget _buildImage() {
    final source = result.imageUrl;
    if (source == null || source.trim().isEmpty) {
      return Container(color: Color(result.imageColor));
    }

    final uri = Uri.tryParse(source);
    final isNetworkImage = uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');

    if (isNetworkImage) {
      return Image.network(
        source,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Color(result.imageColor));
        },
      );
    }

    return Image.asset(
      source,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(color: Color(result.imageColor));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final starCount = result.rating.round().clamp(1, 5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color.fromARGB(255, 201, 201, 201)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: SizedBox(
          height: 84,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 160,
                  height: 130,
                  child: _buildImage(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.city,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        starCount,
                        (_) => const Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: Color(0xFFFFB800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.bookmark_border_rounded,
                    color: AppTheme.primary,
                  ),
                  Text(
                    '\$${result.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: selected ? 35 : 30),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
