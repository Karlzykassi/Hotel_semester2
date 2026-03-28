import 'package:flutter/material.dart';
import 'package:hote_v2/core/theme/app_theme.dart';
import 'package:hote_v2/features/booking/booking_screen.dart';
import 'package:hote_v2/features/home/home_screen.dart';
import 'package:hote_v2/features/profile/profile_screen.dart';
import 'package:hote_v2/features/search/search_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  static const routeName = '/shell';
  final int initialIndex;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _index;
  final GlobalKey<BookingScreenState> _bookingScreenKey =
      GlobalKey<BookingScreenState>();

  List<Widget> get _screens => <Widget>[
        HomeScreen(onSearchTap: _openSearch),
        const SearchScreen(),
        BookingScreen(key: _bookingScreenKey),
        const ProfileScreen(),
      ];

  void _openSearch() {
    setState(() => _index = 1);
  }

  void _openBookings() {
    setState(() => _index = 2);
    _bookingScreenKey.currentState?.refreshBookings(silent: true);
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _BottomItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _BottomItem(
                icon: Icons.search_rounded,
                label: 'Search',
                selected: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
              _BottomItem(
                icon: Icons.calendar_month_rounded,
                label: 'Booking',
                selected: _index == 2,
                onTap: _openBookings,
              ),
              _BottomItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: _index == 3,
                onTap: () => setState(() => _index = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
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
                size: selected ? 30 : 25,
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
